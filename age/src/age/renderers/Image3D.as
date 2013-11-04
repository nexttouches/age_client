package age.renderers
{
	import flash.events.MouseEvent;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;

	/**
	 * Image3D 实现了场景中 3D 功能之类的基本接口
	 * @author zhanghaocong
	 *
	 */
	public class Image3D extends Image implements IArrangeable, IDisplayObject3D, IDirectionRenderer, ITouchable
	{
		public function Image3D()
		{
			super(emptyTexture);
			touchable = false;
			uniqueIndex = ZIndexHelper.getUniqueZIndex();
			addEventListener(Event.ADDED_TO_STAGE, onAdd);
		}

		private function onAdd():void
		{
			projectY = SceneRenender(parent.parent).projectY;
		}

		private var _direction:int;

		/**
		 * @inheritDoc
		 *
		 */
		public function get direction():int
		{
			return _direction;
		}

		public function set direction(value:int):void
		{
			_direction = value;
			scaleX = Math.abs(scaleX) * (value == Direction.RIGHT ? 1 : -1);
		}

		/**
		 * 设置新的 Texture 后再调整大小
		 * @param t
		 *
		 */
		protected function setTexture(t:Texture):void
		{
			texture = t;
			readjustSize();
		}

		/**
		 * @inheritDoc
		 *
		 */
		public override function dispose():void
		{
			if (parent)
			{
				parent.removeChild(this);
			}

			if (_onDispose)
			{
				_onDispose.dispatch(this);
				_onDispose.removeAll();
			}

			if (_onMouseDown)
			{
				_onMouseDown.removeAll();
			}

			if (onMouseUp)
			{
				_onMouseUp.removeAll();
			}

			if (_onRollOut)
			{
				_onRollOut.removeAll();
			}

			if (_onRollOver)
			{
				_onRollOver.removeAll();
			}
			super.dispose();
		}

		private var _onDispose:ISignal;

		/**
		 * @inheritDoc
		 *
		 */
		public function get onDispose():ISignal
		{
			return _onDispose ||= new Signal(BGRenderer);
		}

		private var _state:String;

		/**
		 * @inheritDoc
		 *
		 */
		public function get state():String
		{
			return _state;
		}

		private var _onMouseDown:Signal;

		/**
		 * @inheritDoc
		 *
		 */
		public function get onMouseDown():Signal
		{
			return _onMouseDown ||= new Signal(TextureRenderer);
		}

		private var _onMouseUp:Signal;

		/**
		 * @inheritDoc
		 *
		 */
		public function get onMouseUp():Signal
		{
			return _onMouseUp ||= new Signal(TextureRenderer);
		}

		private var _onRollOver:Signal;

		/**
		 * @inheritDoc
		 *
		 */
		public function get onRollOver():Signal
		{
			return _onRollOver ||= new Signal(TextureRenderer);
		}

		private var _onRollOut:Signal;

		/**
		 * @inheritDoc
		 *
		 */
		public function get onRollOut():Signal
		{
			return _onRollOut ||= new Signal(TextureRenderer);
		}

		/**
		 * @inheritDoc
		 *
		 */
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

		protected function onTouch(event:TouchEvent):void
		{
			var t:Touch = event.getTouch(this);

			if (t)
			{
				if (t.phase == TouchPhase.BEGAN)
				{
					_state = MouseEvent.MOUSE_DOWN;

					if (_onMouseDown)
					{
						_onMouseDown.dispatch(this);
					}
				}
				else if (t.phase == TouchPhase.HOVER)
				{
					if (state == MouseEvent.ROLL_OUT || !state)
					{
						_state = MouseEvent.ROLL_OVER;

						if (_onRollOver)
						{
							_onRollOver.dispatch(this);
						}
					}
				}
				else if (t.phase == TouchPhase.ENDED)
				{
					_state = MouseEvent.MOUSE_UP;

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
					_state = MouseEvent.ROLL_OUT;

					if (_onRollOut)
					{
						_onRollOut.dispatch(this);
					}
				}
			}
		}

		protected var uniqueIndex:int;

		/**
		 * @inheritDoc
		 *
		 */
		public function get zIndex():int
		{
			return z * ZIndexHelper.Z_RANGE + uniqueIndex;
		}

		protected var is3D:Boolean = true;

		private var _z:Number = 0;

		/**
		 * @inheritDoc
		 *
		 */
		public function get z():Number
		{
			return _z;
		}

		public function set z(value:Number):void
		{
			_z = value;
			// 调用实际的 _projectY 方法
			super.y = _projectY != null ? int(_projectY(_y, _z)) : 0;
		}

		private var _y:Number;

		public override function set y(value:Number):void
		{
			if (is3D)
			{
				_y = value;
				super.y = _projectY != null ? int(_projectY(_y, _z)) : 0;
			}
			else
			{
				super.y = value;
			}
		}

		private var _projectY:Function;

		/**
		 * @inheritDoc
		 *
		 */
		public function get projectY():Function
		{
			return _projectY;
		}

		public function set projectY(value:Function):void
		{
			_projectY = value;

			if (value != null)
			{
				super.y = int(_projectY(_y, _z));
			}
		}

		private var _scale:Number = 1;

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		public function get scale():Number
		{
			return _scale;
		}

		public function set scale(value:Number):void
		{
			if (value != _scale)
			{
				_scale = value;
				scaleX = value;
				scaleY = value;
			}
		}

		protected static var _emptyTexture:Texture;

		/**
		 * 共享了的空贴图，初始化后将使用该贴图
		 * @return
		 *
		 */
		protected static function get emptyTexture():Texture
		{
			return _emptyTexture ||= Texture.empty(1, 1);
		}
	}
}
