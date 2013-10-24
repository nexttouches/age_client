package nt.ui.components
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import nt.ui.configs.DefaultStyle;
	import nt.ui.core.Component;
	import nt.ui.core.SkinnableComponent;

	/**
	 * 垂直拖拽条
	 * @author KK
	 *
	 */
	public class VSlider extends SkinnableComponent
	{
		/**
		 * 使用同一个 Rectangle 储存拖拽时的参数，避免重复创建对象
		 */
		private static var dragRect:Rectangle = new Rectangle();

		[Skin]
		public var handle:Scale9Image;

		[Skin]
		public var track:Scale9Image;

		protected var direction:int;

		public function VSlider(skin:* = null, direction:int = SliderDirection.V)
		{
			super(skin || DefaultStyle.VSliderSkin);
			this.direction = direction;
		}

		override public function setSkin(value:DisplayObject):void
		{
			super.setSkin(value);
			handle.onMouseDown.add(handle_mouseDownHandler);
			handle.buttonMode = true;
			track.longPressEnabled = true;
			track.longPressDelay = 100;
			track.onLongPress.add(track_longPressingHandler);
			track.onLongPressing.add(track_longPressingHandler);
		}

		protected function track_longPressingHandler(target:Component):void
		{
			isPressing = true;
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_onMouseUp);

			if (direction == SliderDirection.V)
			{
				if (mouseY < handle.y)
				{
					value -= 0.1;
				}
				else if (mouseY > handle.y + handle.height)
				{
					value += 0.1;
				}
			}
			else
			{
				if (mouseX < handle.x)
				{
					value -= 0.1;
				}
				else if (mouseX > handle.x + handle.width)
				{
					value += 0.1;
				}
			}
		}

		protected function stage_onMouseUp(event:MouseEvent):void
		{
			isPressing = false;
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_onMouseUp);
		}

		protected function handle_mouseDownHandler(target:Component):void
		{
			isDragging = true;
			dragRect.x = track.x;
			dragRect.y = track.y;

			if (direction == SliderDirection.V)
			{
				dragRect.width = 0;
				dragRect.height = track.height - handle.height;
			}
			else
			{
				dragRect.width = track.width - handle.width;
				dragRect.height = 0;
			}
			handle.startDrag(false, dragRect);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handle_onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, handle_onMouseUp);
		}

		protected function handle_onMouseUp(event:MouseEvent):void
		{
			isDragging = false;
			handle.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, handle_onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, handle_onMouseUp);
		}

		protected function handle_onMouseMove(event:MouseEvent):void
		{
			if (direction == SliderDirection.V)
			{
				value = (handle.y - track.y) / (track.height - handle.height);
			}
			else
			{
				value = (handle.x - track.x) / (track.width - handle.width);
			}
		}

		private var _value:Number = 0;

		/**
		 * 设置或获取当前 slider 的值
		 * @return
		 *
		 */
		public function get value():Number
		{
			return _value;
		}

		public function set value(value:Number):void
		{
			if (value > 1)
			{
				value = 1;
			}
			else if (value < 0 || isNaN(value))
			{
				value = 0;
			}
			_value = value;

			if (!isDragging)
			{
				invalidate();
			}
		}

		override protected function render():void
		{
			super.render();

			if (direction == SliderDirection.V)
			{
				handle.y = track.y + (track.height - handle.height) * value;
			}
			else
			{
				handle.x = track.x + (track.width - handle.width) * value;
			}
		}

		override public function set height(value:Number):void
		{
			// 同时更改 track 的高度
			if (direction == SliderDirection.V)
			{
				track.height = value;
				super.height = value;
			}
			else
			{
				throw new Error("当前方向不能设置高度");
			}
		}

		override public function set width(value:Number):void
		{
			if (direction == SliderDirection.H)
			{
				track.width = value;
				super.width = value;
			}
			else
			{
				throw new Error("当前方向不能设置宽度");
			}
		}

		override public function get height():Number
		{
			// 总是使用 track 作为 VSlider 的高度
			return track.height;
		}

		override public function get width():Number
		{
			// 总是以 track 的宽度作为 Slider 的宽度
			return track.width;
		}

		/**
		 * 指示当前是否按住了 track
		 * @return
		 *
		 */
		protected var isPressing:Boolean;

		/**
		 * 指示当前是否正在拖动 handle
		 * @return
		 *
		 */
		protected var isDragging:Boolean;
	}
}
