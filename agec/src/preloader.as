package
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import nt.lib.util.setupStage;

	/**
	 * preloader 是最初的引导程序，负责载入 main<br/>
	 * @author zhanghaocong
	 *
	 */
	[SWF(frameRate="60", width="1000", height="600")]
	public class preloader extends Sprite
	{
		/**
		 * 默认的加载器路径
		 */
		private static const DEFAULT_MAIN_URL:String = "main.swf";

		/**
		 * 默认的皮肤路径
		 */
		private static const DEFAULT_SKIN_URL:String = "skin.swf";

		/**
		 * 加载器的皮肤类
		 */
		public var skin:Sprite;

		/**
		 * @private
		 */
		private var tf:TextField;

		/**
		 * @private
		 */
		private var updateLabelIntervalID:int;

		/**
		 * 加载 main.swf 的 Loader
		 */
		private var mainLoader:Loader;

		/**
		 * 加载 skin 的 Loader
		 */
		private var skinLoader:Loader;

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
		}

		/**
		 * 添加到舞台后初始化
		 * @param event
		 *
		 */
		protected function onAdd(event:Event = null):void
		{
			mainLoader = new Loader();
			mainLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			mainLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			mainLoader.load(new URLRequest(loaderInfo.parameters["main"] ||= DEFAULT_MAIN_URL), new LoaderContext(false, new ApplicationDomain(ApplicationDomain.currentDomain)));
			skinLoader = new Loader();
			skinLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, skinLoader_onComplete);
			skinLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, skinLoader_onError);
			skinLoader.load(new URLRequest(loaderInfo.parameters["skin"] ||= DEFAULT_SKIN_URL), new LoaderContext(false, new ApplicationDomain(ApplicationDomain.currentDomain)));
			tf = new TextField();
			tf.defaultTextFormat = new TextFormat("Arial", "12", 0xffffff, null, null, null, null, null, "center");
			tf.text = "正在加载主程序...";
			tf.autoSize = TextFieldAutoSize.CENTER;
			tf.selectable = false;
			addChild(tf);
			positionTF();
			stage.addEventListener(Event.RESIZE, positionTF);
			updateLabelIntervalID = setInterval(updateTF, 1000);
		}

		/**
		 * @private
		 *
		 */
		protected function skinLoader_onComplete(event:Event):void
		{
			skin = skinLoader.content as Sprite;
			stage.addChild(skin);
		}

		/**
		 * @private
		 *
		 */
		protected function skinLoader_onError(event:IOErrorEvent):void
		{
			trace("皮肤加载出错");
		}

		/**
		 * @private
		 *
		 */
		protected function onError(event:IOErrorEvent):void
		{
			tf.text = "加载错误\n（" + event.text + "）";
			clearInterval(updateLabelIntervalID);
		}

		/**
		 * @private
		 *
		 */
		private function updateTF():void
		{
			tf.text += ".";
		}

		/**
		 * @private
		 *
		 */
		private function positionTF(... ignored):void
		{
			tf.x = stage.stageWidth / 2 - tf.width / 2;
			tf.y = stage.stageHeight / 2 - tf.height / 2;
		}

		/**
		 * 释放本加载器的资源
		 * @param event
		 *
		 */
		protected function onComplete(event:Event):void
		{
			event.currentTarget.content.init(skin);
			tf.text += "完成！";
			clearInterval(updateLabelIntervalID);
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
	}
}
