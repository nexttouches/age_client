package 
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.system.Capabilities;
	import flash.utils.getDefinitionByName;
	import game.starter.assets.Loading;

	/**
	 * 在 starter 前使用的简单预加载器
	 * @author zhanghaocong
	 *
	 */
	public class SimplePreloader extends Sprite
	{
		private static var instance:SimplePreloader;

		public static function getInstance():SimplePreloader
		{
			return instance;
		}

		private var loading:Loading;

		private var _percentLoaded:Number = 0;

		/**
		 * 当前已加载的百分比
		 */
		public function get percentLoaded():Number
		{
			return _percentLoaded;
		}

		/**
		 * @private
		 */
		public function set percentLoaded(value:Number):void
		{
			_percentLoaded = value;
			t = 0;
		}

		public var phase:String = "1/2";

		/**
		 * 要显示的加载百分比
		 */
		private var percentDisplay:Number = 0;

		public function SimplePreloader()
		{
			instance = this;
			addEventListener(Event.ADDED_TO_STAGE, onAdd);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			setupStage();
		}

		private function setupStage():void
		{
			stage.color = 0;
			stage.tabChildren = false;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.HIGH;
			stage.frameRate = 60;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(MouseEvent.RIGHT_CLICK, killContextMenu);
			loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, killErrors);
		}

		protected function onProgress(event:ProgressEvent):void
		{
			percentLoaded = stage.loaderInfo.bytesLoaded / stage.loaderInfo.bytesTotal;
		}

		protected function killErrors(event:UncaughtErrorEvent):void
		{
			// 用于捕获奇怪错误的地方
			// 比如说因为在 WIN7 上按 CTRL+ALT+DEL 导致 Context3D 丢失，恢复后可能会报之类的错误
			// Error: Error #3694: 之前已对该对象调用 dispose() 释放了该对象。
		}

		protected function killContextMenu(event:MouseEvent):void
		{
		}

		protected function onRemove(event:Event):void
		{
			removeChild(loading);
			loading = null;
			stage.removeEventListener(Event.RESIZE, positionLoading);
			removeEventListener(Event.ENTER_FRAME, updatePercent);
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
		}

		protected function onAdd(event:Event):void
		{
			if (Capabilities.isDebugger)
			{
				checkSize();
			}
			loading = new Loading();
			addChild(loading);
			stage.addEventListener(Event.RESIZE, positionLoading);
			positionLoading();
			addEventListener(Event.ENTER_FRAME, updatePercent);
			updatePercent();
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
		}

		private var t:int;

		private const d:int = 30;

		protected function updatePercent(event:Event = null):void
		{
			if (t < d)
			{
				t++;
				percentDisplay = percentLoaded * t / d; // c*t/d
				loading.percentField.text = phase + " " + Math.floor(percentDisplay * 100) + "%";

				if (percentDisplay >= 1)
				{
					onLoadComplete();
				}
			}
		}

		public var onLoadComplete:Function = boot;

		private function boot():void
		{
			var classRef:Class = getDefinitionByName("bootstrap") as Class;
			stage.addChild(new classRef());
		}

		protected function positionLoading(event:Event = null):void
		{
			loading.x = stage.stageWidth >> 1;
			loading.y = stage.stageHeight >> 1;
		}

		private const maxSize:int = 30 * 1024;

		/**
		 * 防手贱助手
		 *
		 */
		private function checkSize():void
		{
			if (stage.loaderInfo.bytesTotal > maxSize)
			{
				throw new Error("超过 " + maxSize + "k 了，是不是嵌了奇怪的东西？");
			}
		}
	}
}
