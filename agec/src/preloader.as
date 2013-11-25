package
{
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import agec.preloader.PreloaderConfig;
	import agec.preloader.PreloaderSkin;
	import nt.assets.Asset;
	import nt.assets.AssetConfig;
	import nt.assets.AssetGroup;
	import nt.assets.AssetLoadQueue;
	import nt.assets.AssetLoaderNames;
	import nt.assets.IAsset;
	import nt.assets.IAssetUser;
	import nt.assets.VersionAsset;
	import nt.assets.extensions.LibAsset;
	import nt.assets.extensions.ZipAsset;
	import nt.lib.util.setupStage;

	/**
	 * preloader 是加载器，负责载入进入游戏必须的资源
	 * @author zhanghaocong
	 *
	 */
	[SWF(frameRate="60", width="1000", height="600")]
	public class preloader extends Sprite implements IAssetUser
	{
		/**
		 * 预加载配置文件
		 */
		public var config:PreloaderConfig = new PreloaderConfig;

		/**
		 * 皮肤，默认是 NativePreloaderSkin
		 */
		public var skin:PreloaderSkin = new PreloaderSkin();

		/**
		 * 版本资源
		 */
		public var versionBinAsset:VersionAsset;

		/**
		 * main.swf
		 */
		public var mainAsset:LibAsset;

		/**
		 * 加载完 versionBinAsset 之后，加载该组
		 */
		public var group:AssetGroup;

		/**
		 * 构造函数
		 *
		 */
		public function preloader()
		{
			super();

			// 当前为文档类时才初始化 stage
			if (stage)
			{
				setupStage(stage);
				onAdd();
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, onAdd);
			}
			positionSkin();
			addChild(skin);
			// 从 FlashVars 更新信息
			config.init(loaderInfo.parameters);
			// 初始化 AssetConfig
			AssetConfig.init(config.rootPath);
			// 设置并加载皮肤
			skin.asset = LibAsset.get(config.skinPath);
			// 加载 version.bin
			loadVersionBin();
		}

		/**
		 * 加载 version.bin
		 *
		 */
		private function loadVersionBin():void
		{
			// 版本信息
			versionBinAsset = VersionAsset.get(config.versionPath);
			versionBinAsset.addUser(this);
			versionBinAsset.load(queue);
		}

		/**
		 * 添加到舞台后初始化
		 * @param event
		 *
		 */
		protected function onAdd(event:Event = null):void
		{
			stage.addEventListener(Event.RESIZE, onResize);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
		}

		/**
		 * 从舞台删除后回收资源
		 * @param event
		 *
		 */
		protected function onRemove(event:Event):void
		{
			stage.removeEventListener(Event.RESIZE, onResize);
		}

		/**
		 * 场景缩放后调用
		 * @param event
		 *
		 */
		protected function onResize(event:Event):void
		{
			positionSkin();
		}

		/**
		 * @private
		 *
		 */
		protected function fadeOut(event:Event):void
		{
			alpha -= 0.01;

			if (filters.length)
			{
				const blur:Number = filters[0].blurX + 0.33;
				filters = [ new BlurFilter(blur, blur, BitmapFilterQuality.HIGH)];
			}
			else
			{
				filters = [ new BlurFilter(0.33, 0.33, BitmapFilterQuality.HIGH)];
			}

			if (alpha <= 0)
			{
				alpha = 0;
				removeEventListener(Event.ENTER_FRAME, fadeOut);
				dispose();
			}
		}

		/**
		 * 使皮肤居中
		 *
		 */
		private function positionSkin():void
		{
			skin.x = (stage.stageWidth - skin.width) / 2;
			skin.y = (stage.stageHeight - skin.height) / 2;
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function onAssetDispose(asset:IAsset):void
		{
			throw new IllegalOperationError("[preloader] 逻辑错误：按照设计不应该运行到这里。");
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function onAssetLoadComplete(asset:IAsset):void
		{
			skin.currentProgress = 1;
			skin.currentInfo += "完成！";

			if (asset == versionBinAsset)
			{
				AssetConfig.updateInfos(versionBinAsset.result);
				loadOtherAssets();
			}
			else if (mainAsset.isComplete)
			{
				skin.totalProgress = 1;
				const main:* = new (mainAsset.getClass("main"));
				main.init(stage);
				addEventListener(Event.ENTER_FRAME, fadeOut);
			}
		}

		/**
		 * 加载剩余的其他资源
		 *
		 */
		private function loadOtherAssets():void
		{
			skin.totalProgress = 0;
			mainAsset = LibAsset.get(config.mainPath);
			group = new AssetGroup;
			// main.swf
			group.addAsset(mainAsset);
			// data0.zip
			group.addAsset(ZipAsset.get(config.dataPath));
			// TODO lang.zip
			group.addUser(this);
			group.load(queue);
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function onAssetLoadError(asset:IAsset):void
		{
			trace("[preloader] 加载过程中发生错误，请查看输出日志");
			// TODO 界面应提示用户加载失败并刷新
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function onAssetLoadProgress(asset:IAsset, bytesLoaded:uint, bytesTotal:uint):void
		{
			// 当前加载的资源
			var currentAsset:Asset;

			// 当前加载的是 versionBinAsset
			if (asset == versionBinAsset)
			{
				currentAsset = versionBinAsset;
				skin.totalProgress = 0;
			}
			// 当前加载的是剩余的组
			else if (asset == group)
			{
				if (group.currentLoadings.length > 0)
				{
					// 只取第一项
					currentAsset = group.currentLoadings[0];
				}
				skin.totalProgress = bytesLoaded / bytesTotal;
			}
			skin.currentInfo = "正在加载 " + currentAsset.info.filename + "…";
			skin.currentProgress = currentAsset.bytesLoaded / currentAsset.bytesTotal;
		}

		/**
		 * 释放资源
		 *
		 */
		public function dispose():void
		{
			trace("[preloader] dispose");
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			removeEventListener(Event.ADDED_TO_STAGE, onAdd);
			stage.removeEventListener(Event.RESIZE, onResize);
			versionBinAsset.removeUser(this);
			versionBinAsset = null;
			mainAsset = null;
			parent.removeChild(this);
			group.removeUser(this);
			group.dispose();
			group = null;
			skin.dispose();
		}

		/**
		 * 预加载时使用的队列
		 * @return
		 *
		 */
		public static function get queue():AssetLoadQueue
		{
			return AssetLoadQueue.get(AssetLoaderNames.DoubleThreading);
		}
	}
}
