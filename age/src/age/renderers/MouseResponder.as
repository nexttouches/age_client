package age.renderers
{
	import flash.events.MouseEvent;
	import age.data.AvatarInfo;
	import age.data.Box;
	import org.osflash.signals.Signal;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	/**
	 * 鼠标响应渲染器，是一个辅助类，专门用于处理 AvatarRenderer 的鼠标事件
	 * @author zhanghaocong
	 *
	 */
	public class MouseResponder extends Quad3D implements IArrangeable, ITouchable, IDisplayObject3D
	{
		/**
		 * 当 info 为 null 时，渲染的默认大小
		 */
		public static const DEFAULT_SIZE:Box = new Box(0, 0, 0, 100, 200, 100, 0.5, 0, 0.5);

		/**
		 * 标记当前 MouseResponder 属于哪个 ObjectRenderer<br>
		 * 鼠标事件广播时，将传递该参数
		 */
		public var owner:ObjectRenderer;

		/**
		 * 创建一个新的 MouseResponder
		 * @param owner
		 *
		 */
		public function MouseResponder(owner:ObjectRenderer)
		{
			this.owner = owner;
			super(0, 0, 0xffffff, true);
			alpha = 0.2;
			touchable = true;
			addEventListener(Event.ADDED_TO_STAGE, onAdd);
			uniqueIndex += uniqueIndex += ZIndexHelper.MOUSE_RESPONDER_OFFSET;
		}

		private function onAdd():void
		{
			projectY = SceneRenender(parent.parent).projectY;
		}

		/**
		 * 释放资源<br>
		 * 将自动解除 info 的引用
		 *
		 */
		override public function dispose():void
		{
			_info = null;
			super.dispose();
		}

		private var _info:AvatarInfo;

		/**
		 * 设置或获取当前渲染的 FrameInfo
		 * @return
		 *
		 */
		public function get info():AvatarInfo
		{
			return _info;
		}

		public function set info(value:AvatarInfo):void
		{
			var size:Box = DEFAULT_SIZE;

			if (_info)
			{
			}
			_info = value;

			if (_info)
			{
				size = value.size;
			}
			mVertexData.setPosition(0, 0, 0);
			mVertexData.setPosition(1, size.width, 0);
			mVertexData.setPosition(2, 0, size.height);
			mVertexData.setPosition(3, size.width, size.height);
			pivotX = size.pivot.x * size.width;
			pivotY = (1 - size.pivot.y) * size.height; // 使 pivotY 颠倒，以快速转换坐标系
			onVertexDataChanged();
		}

		private var _state:String;

		/**
		 * 当前鼠标状态，可用的值在下面
		 * @see MouseEvent.MOUSE_DOWN
		 * @see MouseEvent.MOUSE_UP
		 * @see MouseEvent.ROLL_OVER
		 * @see MouseEvent.ROLL_OUT
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
			return _onMouseDown ||= new Signal(ObjectRenderer);
		}

		private var _onMouseUp:Signal;

		/**
		 * @inheritDoc
		 *
		 */
		public function get onMouseUp():Signal
		{
			return _onMouseUp ||= new Signal(ObjectRenderer);
		}

		private var _onRollOver:Signal;

		/**
		 * @inheritDoc
		 *
		 */
		public function get onRollOver():Signal
		{
			return _onRollOver ||= new Signal(ObjectRenderer);
		}

		private var _onRollOut:Signal;

		/**
		 * @inheritDoc
		 *
		 */
		public function get onRollOut():Signal
		{
			return _onRollOut ||= new Signal(ObjectRenderer);
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
						_onMouseDown.dispatch(owner);
					}
				}
				else if (t.phase == TouchPhase.HOVER)
				{
					if (state == MouseEvent.ROLL_OUT || !state)
					{
						_state = MouseEvent.ROLL_OVER;

						if (_onRollOver)
						{
							_onRollOver.dispatch(owner);
						}
					}
				}
				else if (t.phase == TouchPhase.ENDED)
				{
					_state = MouseEvent.MOUSE_UP;

					if (_onMouseUp)
					{
						_onMouseUp.dispatch(owner);
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
						_onRollOut.dispatch(owner);
					}
				}
			}
		}

		override public function get zIndex():int
		{
			return z * ZIndexHelper.Z_RANGE + uniqueIndex;
		}
	}
}
