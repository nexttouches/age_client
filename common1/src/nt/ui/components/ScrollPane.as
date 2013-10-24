package nt.ui.components
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import nt.lib.util.IDisposable;
	import nt.ui.containers.Canvas;
	import nt.ui.containers.LayoutAlign;
	import nt.ui.core.Component;

	public class ScrollPane extends Canvas implements IDisposable
	{
		/**
		 * 当前 scrollBar
		 */
		public var vScrollBar:VScrollBar;

		/**
		 * 当前 scrollBar
		 */
		public var hScrollBar:HScrollBar;

		/**
		 * 当前 viewport
		 */
		private var _viewport:IViewport;

		/**
		 * 鼠标滚动响应区域
		 */
		private var mouseWheelResponser:Shape;

		/**
		 * 标记鼠标滚轮响应区域是否已无效，以便重新绘制
		 */
		private var mouseWheelResponserInvalidated:Boolean = true;

		/**
		 * 标记滚动条的位置是否已变化，以便重新定位 viewport 和 VScrollBar
		 */
		private var scrollBarPositionChanged:Boolean = true;

		public function ScrollPane()
		{
			super();
			// 鼠标响应区域
			mouseWheelResponser = new Shape();
			mouseWheelResponser.visible = false;
			$addChildAt(mouseWheelResponser, 0);
			// 滚动条
			vScrollBar = new VScrollBar();
			hScrollBar = new HScrollBar();
			// 鼠标滚轮事件
			addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			//onMouseDown.add(this_onMouseDown);
		}

		/*private function this_onMouseDown(target:Component):void
		{
			trace(target);
		}
*/
		protected function onMouseWheel(event:MouseEvent):void
		{
			if (_useVScrollBar)
			{
				if (_viewport.contentHeight > _viewport.height)
				{
					_viewport.positionY -= event.delta * _viewport.delta;
					_viewport.autoScroll = false;
				}
			}

			if (_useHScrollBar)
			{
				if (_viewport.contentWidth > _viewport.width)
				{
					_viewport.positionX -= event.delta * _viewport.delta;
					_viewport.autoScroll = false;
				}
			}
			vScrollBar.invalidate();
		}

		override public function addChild(child:DisplayObject):DisplayObject
		{
			if (child is IViewport)
			{
				setViewport(child as IViewport);
			}
			return super.addChild(child);
		}

		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			if (child is IViewport)
			{
				setViewport(child as IViewport);
			}
			return super.addChildAt(child, index);
		}

		override public function removeChild(child:DisplayObject):DisplayObject
		{
			var child:DisplayObject = super.removeChild(child);

			if (child is IViewport)
			{
				setViewport(null);
			}
			return child;
		}

		override public function removeChildAt(index:int):DisplayObject
		{
			var child:DisplayObject = super.removeChildAt(index);

			if (child is IViewport)
			{
				setViewport(null);
			}
			return child
		}

		private function setViewport(v:IViewport):void
		{
			if (v && _viewport)
			{
				throw new Error("viewport 已设置，不能重复设置");
			}

			if (_viewport)
			{
				_viewport.onPositionXChange.remove(viewport_onPositionChange);
				_viewport.onPositionYChange.remove(viewport_onPositionChange);
			}
			_viewport = v;
			vScrollBar.viewport = v;
			hScrollBar.viewport = v;

			if (_viewport)
			{
				_viewport.onPositionXChange.add(viewport_onPositionChange);
				_viewport.onPositionYChange.add(viewport_onPositionChange);
				viewportWidth = v.width; // 滚动条在左侧时需要使用
				viewportHeight = v.height; // 滚动条在右侧时需要使用
			}
		}

		private function viewport_onPositionChange(v:IViewport):void
		{
			this.refreshHScrollBarVisible();
			this.refreshVScrollBarVisible();
		}

		/**
		 * added by no4matrix
		 *
		 */
		private function refreshHScrollBarVisible():void
		{
			if (isScrollBarAutoHide)
			{
				hScrollBar.visible = hScrollBar.isScrollable;
			}
			else
			{
				hScrollBar.visible = useHScrollBar;
			}
		}

		/**
		 * added by no4matrix
		 *
		 */
		private function refreshVScrollBarVisible():void
		{
			if (isScrollBarAutoHide)
			{
				vScrollBar.visible = vScrollBar.isScrollable;
			}
			else
			{
				vScrollBar.visible = useVScrollBar;
			}
		}

		override protected function render():void
		{
			super.render();

			if (mouseWheelResponserInvalidated)
			{
				mouseWheelResponserInvalidated = false;
				mouseWheelResponser.graphics.clear();
				mouseWheelResponser.graphics.beginFill(0xff0000, 0);
				mouseWheelResponser.graphics.drawRect(0, 0, width, height);
				mouseWheelResponser.graphics.endFill();
			}

			if (scrollBarPositionChanged && _viewport)
			{
				scrollBarPositionChanged = false;

				if (_useVScrollBar)
				{
					addChild(vScrollBar);
					vScrollBar.height = _viewport.height;

					if (_vScrollBarPosition == LayoutAlign.RIGHT)
					{
						vScrollBar.x = width - vScrollBar.width;
						_viewport.width = vScrollBar.x;
					}
					else
					{
						vScrollBar.x = 0;
						_viewport.x = vScrollBar.width;
						_viewport.width = viewportWidth - vScrollBar.width;
					}
				}
				else
				{
					if (vScrollBar.parent)
					{
						vScrollBar.parent.removeChild(vScrollBar);
					}
					_viewport.width = width;
				}

				if (_useHScrollBar)
				{
					addChild(hScrollBar);
					hScrollBar.width = _viewport.width;

					if (_hScrollBarPosition == LayoutAlign.BOTTOM)
					{
						hScrollBar.y = height - hScrollBar.height;
						_viewport.height = hScrollBar.y;
					}
					else
					{
						hScrollBar.y = 0;
						_viewport.y = hScrollBar.height;
						_viewport.height = viewportHeight - hScrollBar.height;
					}
				}
				else
				{
					if (hScrollBar.parent)
					{
						hScrollBar.parent.removeChild(hScrollBar);
					}
					_viewport.height = height;
				}
			}
		}

		override public function set height(value:Number):void
		{
			mouseWheelResponserInvalidated = true;
			scrollBarPositionChanged = true;
			super.height = value;
		}

		override public function set width(value:Number):void
		{
			mouseWheelResponserInvalidated = true;
			scrollBarPositionChanged = true;
			super.width = value;
		}

		protected override function child_onResize(target:Component):void
		{
			super.child_onResize(target);
			mouseWheelResponserInvalidated = true;
			scrollBarPositionChanged = true;
		}

		public override function dispose():Boolean
		{
			setViewport(null);
			return super.dispose();
		}

		private var _useHScrollBar:Boolean;

		public function get useHScrollBar():Boolean
		{
			return _useHScrollBar;
		}

		public function set useHScrollBar(value:Boolean):void
		{
			_useHScrollBar = value;
			mouseWheelResponserInvalidated = true;
			scrollBarPositionChanged = true;
			invalidate();
		}

		private var _useVScrollBar:Boolean;

		public function get useVScrollBar():Boolean
		{
			return _useVScrollBar;
		}

		public function set useVScrollBar(value:Boolean):void
		{
			_useVScrollBar = value;
			mouseWheelResponserInvalidated = true;
			scrollBarPositionChanged = true;
			invalidate();
		}

		public function get viewport():IViewport
		{
			return _viewport;
		}

		private var _vScrollBarPosition:String = LayoutAlign.RIGHT;

		/**
		 * 设置或获取 vScrollBar 的位置<br/>
		 * 可以接受的值为 LayoutAlign.LEFT, LayoutAlign.RIGHT<br/>
		 * 默认 LayoutAlign.RIGHT
		 * @return
		 * @see game.ui.containers.LayoutAlign
		 */
		public function get vScrollBarPosition():String
		{
			return _vScrollBarPosition;
		}

		public function set vScrollBarPosition(value:String):void
		{
			_vScrollBarPosition = value;
			scrollBarPositionChanged = true;
			invalidate();
		}

		private var _hScrollBarPosition:String = LayoutAlign.BOTTOM;

		/**
		 * 设置或获取 vScrollBar 的位置<br/>
		 * 可以接受的值为 LayoutAlign.TOP, LayoutAlign.BOTTOM<br/>
		 * 默认 LayoutAlign.BOTTOM
		 * @return
		 * @see game.ui.containers.LayoutAlign
		 */
		public function get hScrollBarPosition():String
		{
			return _hScrollBarPosition;
		}

		public function set hScrollBarPosition(value:String):void
		{
			_hScrollBarPosition = value;
			scrollBarPositionChanged = true;
			invalidate();
		}

		private var viewportWidth:Number;

		private var viewportHeight:Number;

		private var _isScrollBarAutoHide:Boolean;

		public function get isScrollBarAutoHide():Boolean
		{
			return _isScrollBarAutoHide;
		}

		public function set isScrollBarAutoHide(value:Boolean):void
		{
			_isScrollBarAutoHide = value;
			scrollBarPositionChanged = true;
			invalidate();
		}

		/**
		 * 设置V滚动条visible
		 * @param visible
		 *
		 */
		public function setVScrollBarVisible(visible:Boolean):void
		{
			this.vScrollBar.visible = visible;
			this.refreshVScrollBarVisible();

			if (false == visible)
			{
				this.vScrollBar.visible = false;
			}
		}

		/**
		 * 设置H滚动条visible
		 * @param visible
		 *
		 */
		public function setHScrollBarVisible(visible:Boolean):void
		{
			this.hScrollBar.visible = visible;
			this.refreshHScrollBarVisible();

			if (false == visible)
			{
				this.hScrollBar.visible = false;
			}
		}

		/**
		 * 设置或获取是否使用鼠标滚轮<br>
		 * 关闭后，鼠标将可以点击到后面的内容
		 * @return
		 *
		 */
		public function get isMouseWheelEnabled():Boolean
		{
			return mouseWheelResponser.visible;
		}

		public function set isMouseWheelEnabled(value:Boolean):void
		{
			mouseWheelResponser.visible = value;
		}
	}
}
