package nt.ui.containers
{
	import flash.display.DisplayObject;

	/**
	 * 横向布局容器
	 * @author zhanghaocong
	 *
	 */
	public class HBox extends AbstractLayoutContainer
	{
		public function HBox()
		{
			super();
		}

		override protected function layout():void
		{
			if (_autoSize)
			{
				_width = 0;
				_height = 0;
			}
			var offset:Number = 0;
			var n:int = numChildren;

			for (var i:int = 0; i < n; i++)
			{
				var child:DisplayObject = getChildAt(i);
				child.x = offset;
				offset += child.width;
				offset += _gap;

				if (_autoSize)
				{
					_width += child.width;
					_height = Math.max(_height, child.height);
				}
			}

			if (_autoSize)
			{
				_width += _gap * (n - 1);
			}
			fireOnResize();
		}

		override protected function doAlign():void
		{
			if (_align != LayoutAlign.NONE)
			{
				for (var i:int = 0; i < numChildren; i++)
				{
					var child:DisplayObject = getChildAt(i);

					if (_align == LayoutAlign.TOP)
					{
						child.y = 0;
					}
					else if (_align == LayoutAlign.BOTTOM)
					{
						child.y = _height - child.height;
					}
					else if (_align == LayoutAlign.MIDDLE)
					{
						child.y = (_height - child.height) * 0.5;
					}
				}
			}
			super.doAlign();
		}
	}
}
