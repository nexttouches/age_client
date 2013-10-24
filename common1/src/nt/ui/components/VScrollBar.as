package nt.ui.components
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import nt.ui.configs.DefaultStyle;
	import nt.ui.core.Component;

	/**
	 * 垂直滚动条
	 * @author KK
	 *
	 */
	public class VScrollBar extends VSlider
	{
		/**
		 * 规定的最小 handle 尺寸
		 */
		protected static const MIN_HANDLE_SIZE:int = 24;

		[Skin]
		public var upButton:PushButton;

		[Skin]
		public var downButton:PushButton;

		public function VScrollBar(skin:* = null, direction:int = SliderDirection.V)
		{
			super(skin || DefaultStyle.VScrollBarSkin, direction);
		}

		override public function setSkin(value:DisplayObject):void
		{
			super.setSkin(value);
			upButton.longPressEnabled = true;
			upButton.longPressDelay = 100;
			upButton.longPressingInterval = 100;
			upButton.onLongPress.add(arrowButton_mouseDownHandler);
			upButton.onLongPressing.add(arrowButton_mouseDownHandler);
			upButton.onMouseDown.add(arrowButton_mouseDownHandler);
			downButton.longPressEnabled = true;
			downButton.longPressDelay = 100;
			downButton.longPressingInterval = 100;
			downButton.onLongPress.add(arrowButton_mouseDownHandler);
			downButton.onLongPressing.add(arrowButton_mouseDownHandler);
			downButton.onMouseDown.add(arrowButton_mouseDownHandler);
		}

		protected function arrowButton_mouseDownHandler(target:Component):void
		{
			if (!isScrollable)
			{
				return;
			}
			isPressing = true;
			stage.addEventListener(MouseEvent.MOUSE_UP, arrowButton_mouseUpHandler);

			if (target == upButton)
			{
				value -= 0.1;
			}
			else
			{
				value += 0.1;
			}
		}

		protected function arrowButton_mouseUpHandler(event:MouseEvent):void
		{
			isPressing = false;
			stage.removeEventListener(MouseEvent.MOUSE_UP, arrowButton_mouseUpHandler);
		}

		private var _viewport:IViewport;

		private var contentHeightChanged:Boolean;

		/**
		 * 设置或获取当前 viewport
		 * @return
		 *
		 */
		public function get viewport():IViewport
		{
			return _viewport;
		}

		public function set viewport(value:IViewport):void
		{
			if (_viewport)
			{
				if (direction == SliderDirection.V)
				{
					if (_viewport.onContentHeightChange)
					{
						_viewport.onContentHeightChange.remove(contentHeightChangeHandler);
					}

					if (_viewport.onPositionYChange)
					{
						_viewport.onPositionYChange.remove(positionChangeHandler);
					}
				}
				else
				{
					if (_viewport.onContentWidthChange)
					{
						_viewport.onContentWidthChange.remove(contentHeightChangeHandler);
					}

					if (_viewport.onPositionXChange)
					{
						_viewport.onPositionXChange.remove(positionChangeHandler);
					}
				}
				_viewport.onResize.remove(contentHeightChangeHandler);
			}
			_viewport = value;

			if (_viewport)
			{
				if (direction == SliderDirection.V)
				{
					if (_viewport.onContentHeightChange)
					{
						_viewport.onContentHeightChange.add(contentHeightChangeHandler);
					}

					if (_viewport.onPositionYChange)
					{
						_viewport.onPositionYChange.add(positionChangeHandler);
					}
				}
				else
				{
					if (_viewport.onContentWidthChange)
					{
						_viewport.onContentWidthChange.add(contentHeightChangeHandler);
					}

					if (_viewport.onPositionXChange)
					{
						_viewport.onPositionXChange.add(positionChangeHandler);
					}
				}
				_viewport.onResize.add(contentHeightChangeHandler);
			}
			contentHeightChangeHandler(null);
		}

		protected function positionChangeHandler(target:Component):void
		{
			// 非用户主动控制时才更新
			if (!isDragging && !isPressing)
			{
				updateValue();
				invalidate();
			}
		}

		protected function contentHeightChangeHandler(target:Component):void
		{
			var p:Number;
			var handleSize:int;

			if (direction == SliderDirection.V)
			{
				if (_viewport)
				{
					p = _viewport.contentHeight == 0 ? 1 : _viewport.height / _viewport.contentHeight;
				}
				else
				{
					p = 1;
				}

				if (p > 1)
				{
					p = 1;
				}
				handleSize = track.height * p;
				handle.height = handleSize < MIN_HANDLE_SIZE ? MIN_HANDLE_SIZE : handleSize;
			}
			else
			{
				if (_viewport)
				{
					p = _viewport.contentWidth == 0 ? 1 : _viewport.width / _viewport.contentWidth;
				}
				else
				{
					p = 1;
				}

				if (p > 1)
				{
					p = 1;
				}
				handleSize = track.width * p;
				handle.width = handleSize < MIN_HANDLE_SIZE ? MIN_HANDLE_SIZE : handleSize;
			}
			updateValue();
			invalidate();
		}

		/**
		 * 根据 viewport 状态更新 handle 的位置
		 *
		 */
		private function updateValue():void
		{
			if (_viewport)
			{
				if (direction == SliderDirection.V)
				{
					value = _viewport.positionY / (_viewport.contentHeight - _viewport.height); // 这里可能会产生 NaN
				}
				else
				{
					value = _viewport.positionX / (_viewport.contentWidth - _viewport.width); // 这里可能会产生 NaN
				}
			}
			else
			{
				value = 0;
			}
		}

		override public function set value(value:Number):void
		{
			if (isNaN(value))
			{
				value = 0;
			}

			// 用户主动控制时才更改 viewport 的属性
			if (_viewport)
			{
				if (isDragging || isPressing)
				{
					if (direction == SliderDirection.V)
					{
						_viewport.positionY = value * (_viewport.contentHeight - _viewport.height);
					}
					else
					{
						_viewport.positionX = value * (_viewport.contentWidth - _viewport.width);
					}
				}

				if (!_viewport.autoScroll)
				{
					_viewport.autoScroll = value > 0.9;
				}
			}
			super.value = value;
		}

		override public function get height():Number
		{
			return downButton.y + downButton.height;
		}

		override public function set height(value:Number):void
		{
			super.height = value;
			upButton.y = 0;
			track.y = upButton.y + upButton.height;
			track.height = value - upButton.height - downButton.height;
			downButton.y = value - downButton.height;
			contentHeightChangeHandler(null);
		}

		override public function get width():Number
		{
			return downButton.x + downButton.width;
		}

		override public function set width(value:Number):void
		{
			super.width = value;
			upButton.y = 0;
			track.x = upButton.x + upButton.width;
			track.width = value - upButton.width - downButton.width;
			downButton.x = value - downButton.width;
			contentHeightChangeHandler(null);
		}

		override protected function handle_mouseDownHandler(target:Component):void
		{
			if (!isScrollable)
			{
				return;
			}
			super.handle_mouseDownHandler(target);
		}

		public function get isScrollable():Boolean
		{
			if (direction == SliderDirection.V)
			{
				if (viewport.contentHeight <= viewport.height)
				{
					return false;
				}
			}
			else if (direction == SliderDirection.H)
			{
				if (viewport.contentWidth <= viewport.width)
				{
					return false;
				}
			}
			return true;
		}
	}
}
