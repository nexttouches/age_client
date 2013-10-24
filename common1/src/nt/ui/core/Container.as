package nt.ui.core
{
	import flash.display.DisplayObject;
	import nt.ui.components.IViewport;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	public class Container extends Component implements IViewport
	{
		public function Container()
		{
			super();
		}

		protected function measureAutoSize():void
		{
			_width = _contentWidth;
			_height = _contentHeight;
			fireOnResize();
		}

		protected function measureContentSize():void
		{
			_contentWidth = 0;
			_contentHeight = 0;
			var n:int = numChildren;

			for (var i:int = 0; i < n; i++)
			{
				var child:DisplayObject = getChildAt(i);

				if (child.visible)
				{
					if (child.x + child.width > _contentWidth)
					{
						_contentWidth = child.x + child.width;
					}

					if (child.y + child.height > _contentHeight)
					{
						_contentHeight = child.y + child.height;
					}
				}
			}

			if (_onContentWidthChange)
			{
				_onContentWidthChange.dispatch(this);
			}

			if (_onContentHeightChange)
			{
				_onContentHeightChange.dispatch(this);
			}
		}

		protected function $addChild(child:DisplayObject):DisplayObject
		{
			return super.addChild(child);
		}

		override public function addChild(child:DisplayObject):DisplayObject
		{
			measureContentSize();

			if (_autoSize)
			{
				measureAutoSize();
			}
			Component(child).onResize.add(child_onResize);
			invalidate();
			return super.addChild(child);
		}

		protected function $addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			return super.addChildAt(child, index);
		}

		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			measureContentSize();

			if (_autoSize)
			{
				measureAutoSize();
			}

			if (child is Component)
			{
				Component(child).onResize.add(child_onResize);
			}
			invalidate();
			return super.addChildAt(child, index);
		}

		override public function removeChild(child:DisplayObject):DisplayObject
		{
			measureContentSize();

			if (_autoSize)
			{
				measureAutoSize();
			}

			if (child is Component)
			{
				Component(child).onResize.remove(child_onResize);
			}
			invalidate();
			return super.removeChild(child);
		}

		override public function removeChildAt(index:int):DisplayObject
		{
			measureContentSize();

			if (_autoSize)
			{
				measureAutoSize();
			}

			if (getChildAt(index) is Component)
			{
				Component(getChildAt(index)).onResize.remove(child_onResize);
			}
			invalidate();
			return super.removeChildAt(index);
		}

		override public function removeChildren(beginIndex:int = 0, endIndex:int = int.MAX_VALUE):void
		{
			measureContentSize();

			if (_autoSize)
			{
				measureAutoSize();
			}
			var n:int = endIndex == int.MAX_VALUE ? numChildren : endIndex;

			for (var i:int = beginIndex; i < n; i++)
			{
				if (getChildAt(i) is Component)
				{
					Component(getChildAt(i)).onResize.remove(child_onResize);
				}
			}
			invalidate();
			super.removeChildren(beginIndex, endIndex);
		}

		protected function child_onResize(target:Component):void
		{
			measureContentSize();

			if (_autoSize)
			{
				measureAutoSize();
			}
			invalidate();
		}

		protected var _autoSize:Boolean = true;

		/**
		 * 用于标记 autoSize 属性已变化，需要重新设置
		 */
		protected var autoSizeChanged:Boolean;

		/**
		 * 用于标记 autoSize 已无效，需要重新计算
		 */
		protected var autoSizeInvalidated:Boolean;

		public function get autoSize():Boolean
		{
			return _autoSize;
		}

		/**
		 * 设或获取当前容器是否自动扩展大小
		 * @param value
		 *
		 */
		public function set autoSize(value:Boolean):void
		{
			_autoSize = value;
			autoSizeChanged = true;
			autoSizeInvalidated = true;
			invalidate();
		}

		override public function set height(value:Number):void
		{
			autoSize = false;
			super.height = value;
		}

		override public function set width(value:Number):void
		{
			autoSize = false;
			super.width = value;
		}

		public function get autoScroll():Boolean
		{
			// TODO Auto Generated method stub
			return false;
		}

		public function set autoScroll(value:Boolean):void
		{
			// TODO Auto Generated method stub
		}

		protected var _contentHeight:int;

		public function get contentHeight():int
		{
			return _contentHeight;
		}

		protected var _contentWidth:int;

		public function get contentWidth():int
		{
			return _contentWidth
		}

		public function get delta():int
		{
			return _height * 0.05; // 总是滚 20 下可以到底
		}

		private var _onContentHeightChange:ISignal;

		public function get onContentHeightChange():ISignal
		{
			return _onContentHeightChange ||= new Signal(Component);
		}

		private var _onContentWidthChange:ISignal;

		public function get onContentWidthChange():ISignal
		{
			return _onContentWidthChange ||= new Signal(Component);
		}

		private var _onPositionXChange:ISignal;

		public function get onPositionXChange():ISignal
		{
			return _onPositionXChange ||= new Signal(Component);
		}

		private var _onPositionYChange:ISignal;

		public function get onPositionYChange():ISignal
		{
			return _onPositionYChange ||= new Signal(Component);
		}

		private var _positionX:int;

		public function get positionX():int
		{
			return _positionX;
		}

		public function set positionX(value:int):void
		{
			_positionX = value;

			if (_positionX > contentWidth - width)
			{
				_positionX = contentWidth - width;
			}
			else if (_positionX < 0)
			{
				_positionX = 0;
			}
			invalidateNow();

			if (_onPositionXChange)
			{
				_onPositionXChange.dispatch(this);
			}
		}

		private var _positionY:int;

		public function get positionY():int
		{
			return _positionY;
		}

		public function set positionY(value:int):void
		{
			_positionY = value;

			if (_positionY > contentHeight - height)
			{
				_positionY = contentHeight - height;
			}
			else if (_positionY < 0)
			{
				_positionY = 0;
			}
			invalidateNow();

			if (_onPositionYChange)
			{
				_onPositionYChange.dispatch(this);
			}
		}

		override protected function render():void
		{
			super.render();

			// 当 autoSize 为 true 时， renderRect 可能为 null，此时不需要应用 positionX 和 Y
			if (renderRect)
			{
				renderRect.x = _positionX;
				renderRect.y = _positionY;
				scrollRect = renderRect;
			}
		}
	}
}
