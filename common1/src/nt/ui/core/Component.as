package nt.ui.core
{
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import nt.lib.util.IDisposable;
	import nt.lib.util.NativeMappedSignalSet;
	import nt.ui.debug.DebugHelper;
	import nt.ui.dnd.DragInfo;
	import nt.ui.dnd.DragProxy;
	import nt.ui.dnd.IDraggable;
	import nt.ui.tooltips.ToolTipManager;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	/**
	 * 组件基类
	 * @author zhanghaocong
	 *
	 */
	public class Component extends LazyRenderable implements IDisposable, IToolTipClient, IDraggable
	{
		/**
		 * 暂存当前 Component 的渲染区域
		 */
		public var renderRect:Rectangle;

		public function Component()
		{
			super();
		}

		protected var sizeChanged:Boolean;

		protected var _height:int;

		/**
		 * 设置或获取测量高度，并不会影响 scaleX 和 scaleY
		 * @return
		 *
		 */
		override public function get height():Number
		{
			return _height;
		}

		override public function set height(value:Number):void
		{
			if (int(value) != _height)
			{
				sizeChanged = true;
				_height = value;
				fireOnResize();
				invalidate();
			}
		}

		protected var _width:int

		/**
		 * 设置或获取测量宽度，并不会影响 scaleX 和 scaleY
		 * @return
		 *
		 */
		override public function get width():Number
		{
			return _width;
		}

		override public function set width(value:Number):void
		{
			if (int(value) != _width)
			{
				sizeChanged = true;
				_width = value;
				fireOnResize();
				invalidate();
			}
		}

		public function setSize(width:int, height:int):void
		{
			if (_width != width && _height != height)
			{
				sizeChanged = true;
				_width = width;
				_height = height;
				fireOnResize();
				invalidate();
			}
		}

		override public function set x(value:Number):void
		{
			super.x = int(value);

			if (_onMove)
			{
				_onMove.dispatch(this);
			}
		}

		override public function set y(value:Number):void
		{
			super.y = int(value);

			if (_onMove)
			{
				_onMove.dispatch(this);
			}
		}

		override public function set visible(value:Boolean):void
		{
			super.visible = value;

			if (_onVisibleChange && value != visible)
			{
				_onVisibleChange.dispatch(this, value);
			}
		}

		private var _showOutline:Boolean = DebugHelper.showOutline;

		public function get showOutline():Boolean
		{
			return _showOutline;
		}

		public function get anchor():Rectangle
		{
			return transform.pixelBounds;
		}

		public function set showOutline(value:Boolean):void
		{
			_showOutline = value;
			invalidate();
		}

		override protected function render():void
		{
			if (sizeChanged)
			{
				sizeChanged = false;

				if (!renderRect)
				{
					renderRect = new Rectangle(0, 0, width, height);
				}
				else
				{
					renderRect.width = width;
					renderRect.height = height;
				}
				scrollRect = renderRect;

				if (showOutline)
				{
					graphics.lineStyle(1, 0xff0000);
					graphics.drawRect(0, 0, width, height);
					graphics.endFill();
				}
			}
		}

		private var lastWidth:int;

		private var lastHeight:int;

		protected function fireOnResize():void
		{
			if (lastWidth != width || lastHeight != height)
			{
				lastWidth = width;
				lastHeight = height;

				if (_onResize)
				{
					_onResize.dispatch(this);
				}
			}
		}

		public function get(path:String):Component
		{
			if (path.indexOf(SLASH) > -1)
			{
				var seg:Vector.<String> = Vector.<String>(path.split(SLASH));
				return getByPath(seg);
			}
			else
			{
				return getChildByName(path) as Component;
			}
		}

		private function getByPath(path:Vector.<String>):Component
		{
			if (path.length == 1)
			{
				return get(path[0]);
			}
			return get(path.shift()).getByPath(path);
		}

		private var longPressProxy:LongPressProxy;

		private var _longPressEnabled:Boolean;

		/**
		 * 设置或获取是否要启用长按功能
		 * @return
		 *
		 */
		public function get longPressEnabled():Boolean
		{
			return _longPressEnabled;
		}

		public function set longPressEnabled(value:Boolean):void
		{
			if (value != _longPressEnabled)
			{
				_longPressEnabled = value;

				if (value)
				{
					longPressProxy = new LongPressProxy(this);
				}
				else
				{
					longPressProxy.dispose();
					longPressProxy = null;
				}
			}
		}

		/**
		 * 长按延迟
		 */
		public function get longPressDelay():uint
		{
			if (!_longPressEnabled)
			{
				throw new IllegalOperationError("longPressEnabled 为 true 时才能使用该属性");
			}
			return longPressProxy.delay;
		}

		public function set longPressDelay(value:uint):void
		{
			if (!_longPressEnabled)
			{
				throw new IllegalOperationError("longPressEnabled 为 true 时才能使用该属性");
			}
			longPressProxy.delay = value;
		}

		/**
		 * 长按间隔
		 */
		public function get longPressingInterval():uint
		{
			if (!_longPressEnabled)
			{
				throw new IllegalOperationError("longPressEnabled 为 true 时才能使用该属性");
			}
			return longPressProxy.interval;
		}

		public function set longPressingInterval(value:uint):void
		{
			if (!_longPressEnabled)
			{
				throw new IllegalOperationError("longPressEnabled 为 true 时才能使用该属性");
			}
			longPressProxy.interval = value;
		}

		private var _buttonMode:Boolean;

		/**
		 * buttonMode 更简单的实现，不会处理 tabIndex 等情况，效率更高
		 *
		 */
		override public function get buttonMode():Boolean
		{
			return _buttonMode;
		}

		override public function set buttonMode(value:Boolean):void
		{
			_buttonMode = value;

			if (value)
			{
				addEventListener(MouseEvent.ROLL_OUT, buttonMode_rollOutHandler);
				addEventListener(MouseEvent.ROLL_OVER, buttonMode_rollOverHandler);
				addEventListener(MouseEvent.MOUSE_DOWN, buttonMode_rollOverHandler);
				addEventListener(MouseEvent.MOUSE_UP, buttonMode_rollOverHandler);
				addEventListener(MouseEvent.CLICK, buttonMode_rollOverHandler);
			}
			else
			{
				removeEventListener(MouseEvent.ROLL_OUT, buttonMode_rollOutHandler);
				removeEventListener(MouseEvent.ROLL_OVER, buttonMode_rollOverHandler);
				removeEventListener(MouseEvent.MOUSE_DOWN, buttonMode_rollOverHandler);
				removeEventListener(MouseEvent.MOUSE_UP, buttonMode_rollOverHandler);
				removeEventListener(MouseEvent.CLICK, buttonMode_rollOverHandler);
			}
		}

		private function buttonMode_rollOverHandler(event:MouseEvent):void
		{
			Mouse.cursor = MouseCursor.BUTTON;
		}

		private function buttonMode_rollOutHandler(event:MouseEvent):void
		{
			Mouse.cursor = MouseCursor.AUTO;
		}

		private var oldMouseChildren:Boolean;

		private var _enabled:Boolean = true;

		public function get enabled():Boolean
		{
			return _enabled;
		}

		public function set enabled(value:Boolean):void
		{
			if (value != _enabled)
			{
				_enabled = value;
				alpha = enabled ? 1 : .5;
				mouseEnabled = value;

				if (!value)
				{
					oldMouseChildren = mouseChildren;
					mouseChildren = false;
				}
				else
				{
					mouseChildren = oldMouseChildren;
				}
			}
		}

		protected var _signals:NativeMappedSignalSet;

		protected function get signals():NativeMappedSignalSet
		{
			return _signals ||= new NativeMappedSignalSet(this);
		}

		/**
		 * Event.ADDED_TO_STAGE
		 * @return
		 *
		 */
		public function get onAdd():ISignal
		{
			return signals.getNativeMappedSignal(Event.ADDED_TO_STAGE);
		}

		protected var _onMove:ISignal;

		public function get onMove():ISignal
		{
			return _onMove ||= new Signal(Component);
		}

		/**
		 * Event.ENTER_FRAME
		 * @return
		 *
		 */
		public function get onEnterFrame():ISignal
		{
			return signals.getNativeMappedSignal(Event.ENTER_FRAME);
		}

		/**
		 * Event.REMOVED_FROM_STAGE
		 * @return
		 *
		 */
		public function get onRemove():ISignal
		{
			return signals.getNativeMappedSignal(Event.REMOVED_FROM_STAGE);
		}

		/**
		 * MouseEvent.CLICK
		 * @return
		 *
		 */
		public function get onClick():ISignal
		{
			return signals.getNativeMappedSignal(MouseEvent.CLICK, MouseEvent);
		}

		/**
		 * MouseEvent.MOUSE_DOWN
		 * @return
		 *
		 */
		public function get onMouseDown():ISignal
		{
			return signals.getNativeMappedSignal(MouseEvent.MOUSE_DOWN, MouseEvent);
		}

		/**
		 * MouseEvent.RIGHT_CLICK
		 * @return
		 *
		 */
		public function get onRightClick():ISignal
		{
//			return signals.getNativeMappedSignal(MouseEvent.RIGHT_CLICK, MouseEvent);
			// modified by weixiao
			return null;
		}

		/**
		 * MouseEvent.ROLL_OUT
		 * @return
		 *
		 */
		public function get onRollOut():ISignal
		{
			return signals.getNativeMappedSignal(MouseEvent.ROLL_OUT, MouseEvent);
		}

		/**
		 * MouseEvent.ROLL_OVER
		 * @return
		 *
		 */
		public function get onRollOver():ISignal
		{
			return signals.getNativeMappedSignal(MouseEvent.ROLL_OVER, MouseEvent);
		}

		protected var _onResize:ISignal;

		/**
		 * 缩放时的 Signal
		 * @return
		 *
		 */
		public function get onResize():ISignal
		{
			return _onResize ||= new Signal(Component);
		}

		protected var _onLongPress:ISignal;

		/**
		 * 长按时的 Signal
		 * @return
		 *
		 */
		public function get onLongPress():ISignal
		{
			return _onLongPress ||= new Signal(Component);
		}

		protected var _onLongPressing:ISignal;

		/**
		 * 长按后持续触发的 Signal
		 * @return
		 *
		 */
		public function get onLongPressing():ISignal
		{
			return _onLongPressing ||= new Signal(Component);
		}

		protected var _onVisibleChange:ISignal;

		public function get onVisibleChange():ISignal
		{
			return _onVisibleChange ||= new Signal(Component, Boolean);
		}

		private var _tipContent:*;

		public function get tipContent():*
		{
			return _tipContent;
		}

		public function set tipContent(value:*):void
		{
			if (value != _tipContent)
			{
				_tipContent = value;

				if (value)
				{
					ToolTipManager.register(this);
				}
				else
				{
					ToolTipManager.unregister(this);
				}
			}
		}

		public function dispose():Boolean
		{
			if (_signals)
			{
				_signals.removeAll();
			}

			if (_onMove)
			{
				_onMove.removeAll();
			}

			if (_onRender)
			{
				_onRender.removeAll();
			}

			if (_onVisibleChange)
			{
				_onVisibleChange.removeAll();
			}

			if (_onResize)
			{
				_onResize.removeAll();
			}

			if (_onLongPress)
			{
				_onLongPress.removeAll();
			}

			if (_onLongPressing)
			{
				_onLongPressing.removeAll();
			}

			if (longPressProxy)
			{
				longPressProxy.dispose();
			}

			if (dragProxy)
			{
				dragProxy.dispose();
			}
			tipContent = null;
			return _isDisposed = true;
		}

		private var _isDisposed:Boolean;

		public function get isDisposed():Boolean
		{
			return _isDisposed;
		}

		private var _onDispose:ISignal;

		public function get onDispose():ISignal
		{
			return _onDispose ||= new Signal(IDisposable);
		}

		public function dragComplete(info:DragInfo):void
		{
			trace("dragComplete");
		}

		public function dragDropOutSide(info:DragInfo):void
		{
			trace("dragDropOutSide");
		}

		public function get dragData():*
		{
			return null;
		}

		private var dragProxy:DragProxy;

		private var _isDraggable:Boolean;

		public function get isDraggable():Boolean
		{
			return _isDraggable;
		}

		public function set isDraggable(value:Boolean):void
		{
			if (value != _isDraggable)
			{
				_isDraggable = value;

				if (value)
				{
					dragProxy = new DragProxy(this);
				}
				else
				{
					dragProxy.dispose();
					dragProxy = null
				}
			}
		}

		/**
		 * 检查 XY 在当前组件上
		 * @return
		 *
		 */
		public function isInside(x:int, y:int):Boolean
		{
			var rect:Rectangle = getRect(stage);
			return rect.x <= x && rect.y <= y && rect.x + _width >= x && rect.y + _height >= y;
		}
	}
}
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;
import flash.utils.getTimer;
import nt.lib.util.IDisposable;
import nt.ui.core.Component;
import org.osflash.signals.ISignal;
import org.osflash.signals.Signal;

/**
 * 长按代理，只有 Component.longPressEnabled 为 true 时才会被创建
 * @author KK
 *
 */
class LongPressProxy implements IDisposable
{
	private var target:Component;

	private var timer:Timer;

	public function LongPressProxy(target:Component):void
	{
		this.target = target;
		timer = new Timer(100);
		timer.addEventListener(TimerEvent.TIMER, longPressTimer_timerHandler);
		target.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
	}

	public function dispose():Boolean
	{
		timer.reset();
		timer.removeEventListener(TimerEvent.TIMER, longPressTimer_timerHandler);
		timer = null;
		target.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		return _disposed = true;
	}

	/**
	 * 记录最后一次关键点
	 */
	private var checkPoint:int;

	/**
	 * 表示当前长按状态
	 */
	public var state:int = LongPressState.NONE;

	/**
	 * 长按延迟
	 */
	public var delay:uint = 300;

	/**
	 * 长按间隔
	 */
	public var interval:uint = 100;

	protected function longPressTimer_timerHandler(event:TimerEvent):void
	{
		traceex("[LongPressProxy] {0} checking: longPressState = {1}", target.name, state);

		if (state == LongPressState.NONE)
		{
			if (getTimer() - checkPoint > delay)
			{
				state = LongPressState.PRESS;
				checkPoint = getTimer();
				target.onLongPress.dispatch(target);
				target.onLongPressing.dispatch(target);
			}
		}
		else if (state == LongPressState.PRESS)
		{
			if (getTimer() - checkPoint > interval)
			{
				checkPoint = getTimer();
				target.onLongPressing.dispatch(target);
			}
		}
	}

	protected function mouseDownHandler(event:MouseEvent):void
	{
		target.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		checkPoint = getTimer();
		timer.start();
	}

	protected function mouseUpHandler(event:MouseEvent):void
	{
		state = LongPressState.NONE;
		target.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		timer.reset();
	}

	private var _disposed:Boolean;

	public function get isDisposed():Boolean
	{
		return _disposed;
	}

	private var _onDispose:ISignal;

	public function get onDispose():ISignal
	{
		return _onDispose ||= new Signal(IDisposable);
	}
}

/**
 * Component 长按状态
 * @author KK
 *
 */
class LongPressState
{
	/**
	 * 没有长按中，这是默认状态
	 */
	public static const NONE:int = 0;

	/**
	 * 长按中
	 */
	public static const PRESS:int = 1;
}

const SLASH:String = ">";
