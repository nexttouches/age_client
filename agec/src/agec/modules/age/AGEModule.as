package agec.modules.age
{
	import flash.debugger.enterDebugger;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	import age.AGE;
	import age.data.AvatarInfo;
	import age.data.SceneInfo;
	import age.data.TextureAtlasConfig;
	import age.renderers.SceneRenender;
	import deng.fzip.FZip;
	import deng.fzip.FZipFile;
	import nt.assets.extensions.ZipAsset;
	import nt.assets.util.URLUtil;
	import nt.lib.util.assert;

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
			nativeStage.addEventListener(Event.RESIZE, onResize);
			initData();
		}

		/**
		 * @private
		 *
		 */
		private function initData():void
		{
			// 几个关键字
			const KEYWORD_AVATAR:String = "avatars/";
			const KEYWORD_SCENE:String = "scenes/";
			// 动作
			var avatars:Object = {};
			// 场景
			var scenes:Object = {};
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

				if (ext == "")
				{
					// 不处理文件夹
				}
				// 识别为贴图集
				else if (ext == "xml")
				{
					TextureAtlasConfig.addAtlas(path, XML(file.getContentAsString()));
				}
				// 识别为动作
				else if (path.indexOf(KEYWORD_AVATAR) == 0)
				{
					// 其中 XML 是贴图集信息
					if (ext == "xml")
					{
					}
					else if (ext == "txt")
					{
					}
					else
					{
						// 忽略
					}
				}
				// 识别为场景
				else if (path.indexOf(KEYWORD_SCENE) == 0);
				{
					trace("x");
				}
			}
			// 初始化动作配置
			// 初始化场景配置
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
