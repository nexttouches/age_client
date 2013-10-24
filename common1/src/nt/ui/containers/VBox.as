package nt.ui.containers
{
	import flash.display.DisplayObject;

	public class VBox extends AbstractLayoutContainer
	{
		public function VBox()
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

			for (var i:int = 0; i < numChildren; i++)
			{
				var child:DisplayObject = getChildAt(i);
				child.y = offset;
				offset += child.height;
				offset += _gap;

				if (_autoSize)
				{
					_height += child.height;
					_width = Math.max(_width, child.width);
				}
			}

			if (_autoSize)
			{
				_height += _gap * (n - 1);
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

					if (_align == LayoutAlign.LEFT)
					{
						child.x = 0;
					}
					else if (_align == LayoutAlign.RIGHT)
					{
						child.x = _width - child.width;
					}
					else if (_align == LayoutAlign.CENTER)
					{
						child.x = (_width - child.width) / 2;
					}
				}
			}
		}
	}
}
