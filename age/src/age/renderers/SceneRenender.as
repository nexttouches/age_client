package age.renderers
{
	import flash.errors.IllegalOperationError;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.system.Capabilities;
	import age.data.SceneInfo;
	import org.osflash.signals.Signal;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	/**
	 * 基本的场景渲染器
	 * @author zhanghaocong
	 *
	 */
	public class SceneRenender extends Sprite
	{
		private var layerRendererClass:Class;

		/**
		 * 创建一个新的 SceneRenderer
		 * @param layerRendererClass 要替换的层渲染器 Class
		 *
		 */
		public function SceneRenender(layerRendererClass:Class = null)
		{
			super();
			this.layerRendererClass = layerRendererClass || LayerRenderer;
		}

		private var _info:SceneInfo;

		/**
		 * 设置或获取当前渲染的 SceneInfo
		 * @return
		 *
		 */
		final public function get info():SceneInfo
		{
			return _info;
		}

		public function set info(value:SceneInfo):void
		{
			if (_info)
			{
				removeLayers();
			}
			_info = value;

			if (_info)
			{
				addLayers();
			}
		}

		/**
		 * 根据参数获得指定的图层渲染器
		 * @param n
		 * @return
		 *
		 */
		public function getLayerAt(n:int):LayerRenderer
		{
			return getChildAt(n) as LayerRenderer;
		}

		/**
		 * 删除所有图层
		 *
		 */
		protected function removeLayers():void
		{
			removeChildren(0, -1, true);
		}

		/**
		 * 根据 info，添加图层渲染器
		 *
		 */
		protected function addLayers():void
		{
			for (var i:int = 0, n:int = _info.numLayers; i < n; i++)
			{
				var l:LayerRenderer = new layerRendererClass;
				l.info = _info.layers[i];
				addChild(l);
			}
		}

		/**
		 * 根据 info.charLayer 获得对应的 LayerRenderer
		 * @return
		 *
		 */
		public function get charLayer():LayerRenderer
		{
			if (!_info)
			{
				if (Capabilities.isDebugger)
				{
					throw new IllegalOperationError("获取 charLayer 失败，因为 info 尚未设置");
				}
				return null;
			}
			return getChildAt(_info.charLayerIndex) as LayerRenderer;
		}

		/**
		 * 投影方法
		 * @param y
		 * @param z
		 * @return
		 *
		 */
		public function projectY(y:Number, z:Number):Number
		{
			return _info.height - y - z * 0.5;
		}

		/**
		 * 当前鼠标状态，可用的值在下面
		 * @see MouseEvent.MOUSE_DOWN
		 * @see MouseEvent.MOUSE_UP
		 * @see MouseEvent.ROLL_OVER
		 * @see MouseEvent.ROLL_OUT
		 */
		public var state:String;

		private var _onMouseDown:Signal;

		public function get onMouseDown():Signal
		{
			return _onMouseDown ||= new Signal(SceneRenender);
		}

		private var _onMouseUp:Signal;

		public function get onMouseUp():Signal
		{
			return _onMouseUp ||= new Signal(SceneRenender);
		}

		private var _onRollOver:Signal;

		public function get onRollOver():Signal
		{
			return _onRollOver ||= new Signal(SceneRenender);
		}

		private var _onRollOut:Signal;

		public function get onRollOut():Signal
		{
			return _onRollOut ||= new Signal(SceneRenender);
		}

		override public function set touchable(value:Boolean):void
		{
			super.touchable = value;

			if (value)
			{
				addEventListener(TouchEvent.TOUCH, onTouch);
			}
			else
			{
				removeEventListener(TouchEvent.TOUCH, onTouch);
			}
		}

		/**
		 * 保留原始的 hitTest 方法
		 */
		protected var $hitTest:Function = super.hitTest;

		/**
		 * hitTest 用于获取坐标下的对象<br>
		 * 这里覆盖掉，表示只能只能接收 MouseResponder 对象
		 * @param localPoint
		 * @param forTouch
		 * @return
		 *
		 */
		public override function hitTest(localPoint:Point, forTouch:Boolean = false):DisplayObject
		{
			return (super.hitTest(localPoint, forTouch) as MouseResponder) || this;
		}

		protected function onTouch(event:TouchEvent):void
		{
			var t:Touch = event.getTouch(this);

			if (t)
			{
				if (t.phase == TouchPhase.BEGAN)
				{
					state = MouseEvent.MOUSE_DOWN;

					if (_onMouseDown)
					{
						_onMouseDown.dispatch(this);
					}
				}
				else if (t.phase == TouchPhase.HOVER)
				{
					if (state == MouseEvent.ROLL_OUT || !state)
					{
						state = MouseEvent.ROLL_OVER;

						if (_onRollOver)
						{
							_onRollOver.dispatch(this);
						}
					}
				}
				else if (t.phase == TouchPhase.ENDED)
				{
					state = MouseEvent.MOUSE_UP;

					if (_onMouseUp)
					{
						_onMouseUp.dispatch(this);
					}
				}
			}
			else
			{
				if (state != MouseEvent.ROLL_OUT)
				{
					state = MouseEvent.ROLL_OUT;

					if (_onRollOut)
					{
						_onRollOut.dispatch(this);
					}
				}
			}
		}
	}
}
