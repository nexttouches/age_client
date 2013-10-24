package age
{
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import age.renderers.Camera2D;
	import age.utils.objectpools.ImagePool;
	import age.utils.objectpools.TextFieldPool;
	import org.osflash.signals.Signal;
	import starling.animation.Juggler;
	import starling.core.Starling;
	import starling.events.Event;
	import starling.events.ResizeEvent;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	public class AGE
	{
		public function AGE()
		{
		}

		/**
		 * AGE 的版本
		 */
		public static const VERSION:String = "0.5.0";

		public static var config:AGEConfig = new AGEConfig();

		public static var paddingTop:Number = 0;

		public static var paddingBottom:Number = 0;

		public static var paddingLeft:Number = 0;

		public static var paddingRight:Number = 0;

		/**
		 * 共享了的 Camera 对象
		 */
		public static var camera:Camera2D = new Camera2D();

		private static var _s:Engine;

		/**
		 * 获得当前 starling 实例
		 * @return
		 *
		 */
		public static function get s():Engine
		{
			return _s;
		}

		/**
		 * 用于做物理计算的 Juggler
		 */
		public static var physicsJuggler:Juggler = new Juggler();

		/**
		 * 用于更新渲染的 Juggler<br>
		 * 总是在 physicsJuggler 执行
		 */
		public static var renderJuggler:Juggler = new Juggler();

		/**
		 * 启动 AE
		 * @param stage Stage 对象
		 * @param rootClass 用于启动 Starling 的 root 类
		 */
		public static function start(stage:Stage, rootClass:Class):void
		{
			if (_s)
			{
				throw new Error("AE 已启动，不可重复启动");
				return;
			}
			config.onIsDebugModeChange.add(onIsDebugModeChange);
			Starling.handleLostContext = true;
			// 禁用多点触摸
			Starling.multitouchEnabled = false;
			// 启动 Starling
			_s = new Engine(rootClass, stage);
			_s.addEventListener(Event.CONTEXT3D_CREATE, function():void
			{
				// 两个池要初始化一下
				ImagePool.init(16, 8);
				TextFieldPool.init(16, 8);
			});
			_s.antiAliasing = 4;
			updateViewport(_s.stage.stageWidth, _s.stage.stageHeight);
			_s.stage.addEventListener(ResizeEvent.RESIZE, function(event:ResizeEvent):void
			{
				updateViewport(event.width, event.height);
				onIsDebugModeChange();
			});
			// 广播启动事件
			_s.addEventListener(Event.ROOT_CREATED, function(event:Event):void
			{
				_s.removeEventListener(Event.ROOT_CREATED, arguments.callee);

				if (_onStart)
				{
					_onStart.dispatch();
				}
			});
			// 添加 Juggler
			// 这保证了 2 个 juggler 的执行顺序
			_s.juggler.add(physicsJuggler);
			_s.juggler.add(renderJuggler);
			// 跑主循环
			_s.start();
			// 鼠标事件 hacking
			isBlockNativeMouseDown = true;
			// 调试模式
			config.isDebugMode = true;
			// 摄像机可能需要自动跟随功能
			_s.juggler.add(camera);
		}

		private static function onIsDebugModeChange():void
		{
			if (config.isDebugMode)
			{
				_s.showStatsAt(HAlign.CENTER, VAlign.BOTTOM);
			}
			else
			{
				_s.showStats = false;
			}
		}

		private static function updateViewport(width:Number, height:Number):void
		{
			const viewport:Rectangle = new Rectangle(paddingLeft, paddingTop, width - paddingLeft - paddingRight, height - paddingTop - paddingBottom);
			_s.stage.stageWidth = viewport.width;
			_s.stage.stageHeight = viewport.height;
			_s.viewPort = viewport;
		}

		protected static function stage_onMouseDown(event:MouseEvent):void
		{
			// 鼠标下有任何原生对象则屏蔽掉 Starling 的触摸事件
			if (s.nativeStage.getObjectsUnderPoint(new Point(s.nativeStage.mouseX, s.nativeStage.mouseY)).length > 0)
			{
				event.stopImmediatePropagation();
			}
		}

		private static var _isBlockNativeMouseDown:Boolean

		public static function get isBlockNativeMouseDown():Boolean
		{
			return _isBlockNativeMouseDown;
		}

		public static function set isBlockNativeMouseDown(value:Boolean):void
		{
			_isBlockNativeMouseDown = value;

			if (value)
			{
				_s.nativeStage.addEventListener(MouseEvent.MOUSE_DOWN, stage_onMouseDown, false, int.MAX_VALUE);
			}
			else
			{
				_s.nativeStage.removeEventListener(MouseEvent.MOUSE_DOWN, stage_onMouseDown, false);
			}
		}

		private static var _now:Number;

		public static function get now():Number
		{
			return _s.now;
		}

		public static function set now(value:Number):void
		{
			_s.now = value;
		}

		/**
		 * 暂停
		 *
		 */
		public static function pause():void
		{
			_s.stop();
		}

		/**
		 * 释放
		 *
		 */
		public static function dispose():void
		{
			_s.dispose();
		}

		public static function get stageWidth():int
		{
			return _s.stage.stageWidth;
		}

		public static function get stageHeight():int
		{
			return _s.stage.stageHeight;
		}

		private static var _onStart:Signal;

		public static function get onStart():Signal
		{
			return _onStart ||= new Signal();
		}
	}
}
