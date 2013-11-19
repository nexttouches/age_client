package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import agec.preloader.PreloaderConfig;
	import nt.assets.Asset;
	import nt.assets.AssetConfig;
	import nt.assets.AssetGroup;
	import nt.assets.AssetLoadQueue;
	import nt.assets.AssetLoaderNames;
	import nt.assets.IAsset;
	import nt.assets.IAssetUser;
	import nt.assets.extensions.CompressedAMFAsset;
	import nt.assets.extensions.LibAsset;
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
		 * 加载器的皮肤类，默认是 NativePreloaderSkin
		 */
		public var skin:Sprite = new NativePreloaderSkin;

		/**
		 * 加载时使用的组
		 */
		public var group:AssetGroup = new AssetGroup();

		/**
		 * 皮肤资源，将使用独立的进程进行加载
		 */
		public var skinAsset:LibAsset;

		public var versionAsset:Asset;

		/**
		 * constructor
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
			config.fromJSON(loaderInfo.parameters);
			// 初始化 AssetConfig
			AssetConfig.init(config.root);
			// 皮肤资源
			skinAsset = LibAsset.get("preloader/skin.swf");
			// 版本信息
			group.load(queue);
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
		 * 释放本加载器的资源
		 * @param event
		 *
		 */
		protected function onComplete(event:Event):void
		{
			event.currentTarget.content.init(skin);
			addEventListener(Event.ENTER_FRAME, fadeOut);
		}

		/**
		 * @private
		 *
		 */
		protected function fadeOut(event:Event):void
		{
			alpha -= 0.013;

			if (alpha <= 0)
			{
				alpha = 0;
				removeEventListener(Event.ENTER_FRAME, fadeOut);
				parent.removeChild(this);
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
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function onAssetLoadComplete(asset:IAsset):void
		{
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function onAssetLoadError(asset:IAsset):void
		{
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function onAssetLoadProgress(asset:IAsset, bytesLoaded:uint, bytesTotal:uint):void
		{
		}

		/**
		 * 释放资源
		 *
		 */
		public function dispose():void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			removeEventListener(Event.ADDED_TO_STAGE, onAdd);
			stage.removeEventListener(Event.RESIZE, onResize);
			group.removeUser(this);
			group.dispose();
			group = null;
			parent.removeChild(this);
		}

		/**
		 * 当前下载项进度
		 */
		public var currentProgress:Number;

		/**
		 * 当前下载项文字
		 */
		public var currentProgressText:String;

		/**
		 * 总进度
		 */
		public var totalProgress:Number;

		/**
		 * 总进度文字
		 */
		public var totalProgressText:String;

		/**
		 * 本次使用的加载队列
		 * @return
		 *
		 */
		protected function get queue():AssetLoadQueue
		{
			return AssetLoadQueue.get(AssetLoaderNames.DoubleThreading)
		}
	}
}
