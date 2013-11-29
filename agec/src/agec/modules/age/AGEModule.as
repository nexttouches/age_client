package agec.modules.age
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	import age.AGE;
	import age.data.AvatarInfo;
	import age.data.ObjectInfo;
	import age.data.SceneInfo;
	import age.data.TextureAtlasConfig;
	import age.pad.KeyboardPad;
	import age.renderers.SceneRenender;
	import deng.fzip.FZip;
	import deng.fzip.FZipFile;
	import nt.assets.extensions.ZipAsset;
	import nt.assets.util.URLUtil;
	import nt.lib.util.assert;
	import nt.ui.util.ShortcutUtil;

	/**
	 * AGE 模块
	 * @author zhanghaocong
	 *
	 */
	public class AGEModule
	{
		/**
		 * 唯一的场景渲染器
		 */
		public var sceneRenderer:SceneRenender;

		/**
		 * constructor
		 *
		 */
		public function AGEModule()
		{
		}

		/**
		 * 初始化
		 * @param nativeStage
		 *
		 */
		public function init(nativeStage:Stage):void
		{
			AGE.start(nativeStage, SceneRenender);
			AGE.onStart.addOnce(AGE_onStart);
			ShortcutUtil.init(nativeStage, null);
			nativeStage.addEventListener(Event.RESIZE, onResize);
			initInfos();
		}

		/**
		 * 执行测试代码
		 *
		 */
		private function test():void
		{
			var info:SceneInfo = SceneInfo.get("0").fork("0_copy");
			var me:ObjectInfo = new ObjectInfo();
			me.avatarID = "100";
			me.position.setTo(info.width / 2, 0, info.depth / 2);
			me.pad = new KeyboardPad;
			sceneRenderer.info = info;
			info.charLayer.addObject(me);
		}

		/**
		 * @private
		 *
		 */
		private function initInfos():void
		{
			// 几个关键字
			const KEYWORD_AVATAR:String = "avatars";
			const KEYWORD_SCENE:String = "scenes";
			// 初始化 AvatarInfo 和 SceneInfo
			AvatarInfo.init("avatars");
			SceneInfo.init("scenes");
			// 取出 zip
			const dataAsset:ZipAsset = ZipAsset.get("data0.zip");
			// 期待该文件应该是下载好了的
			assert(dataAsset.isComplete);
			const zip:FZip = dataAsset.content;

			for (var i:int = 0, n:int = zip.getFileCount(); i < n; i++)
			{
				const file:FZipFile = zip.getFileAt(i);
				const path:String = file.filename;
				const filename:String = URLUtil.getFilename(path);
				const ext:String = URLUtil.getExtension(path).toLowerCase();
				var raw:Object;

				// 没有扩展名视为文件夹
				if (ext == "")
				{
					// 不处理
				}
				// 识别为贴图集
				else if (ext == "xml")
				{
					TextureAtlasConfig.addAtlas(path.replace(/\.xml/ig, ""), XML(file.getContentAsString()));
				}
				else if (ext == "txt")
				{
					raw = JSON.parse(file.getContentAsString());
					raw.id = filename;

					if (path.indexOf(KEYWORD_AVATAR) == 0)
					{ // 识别为动作
						AvatarInfo.add(raw);
					}
					else if (path.indexOf(KEYWORD_SCENE) == 0)
					{ // 识别为场景
						SceneInfo.add(raw);
					}
				}
			}
		}

		/**
		 * @private
		 *
		 */
		private function AGE_onStart():void
		{
			// 更新相机
			AGE.camera.scene = sceneRenderer;
			AGE.camera.center = new Point(AGE.stageWidth * 0.5, AGE.stageHeight * 0.5);
			AGE.camera.isLimitBounds = false;
			AGE.isBlockNativeMouseDown = false;
			// 暴露 sceneRenderer 到外面
			sceneRenderer = AGE.s.root as SceneRenender;
			// 跑个小测试
			test();
		}

		/**
		 * @private
		 *
		 */
		protected function onResize(event:Event):void
		{
			AGE.camera.center = new Point(AGE.stageWidth * 0.5, AGE.stageHeight * 0.5);
		}

		/**
		 * 切换网格显示
		 *
		 */
		public function toggleGrid():void
		{
			sceneRenderer.isShowGrid = !sceneRenderer.isShowGrid;
		}
	}
}
