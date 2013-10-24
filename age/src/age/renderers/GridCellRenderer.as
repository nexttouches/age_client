package age.renderers
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.geom.Rectangle;
	import starling.display.Image;
	import starling.textures.Texture;

	/**
	 * 用来渲染行走区域每个小格子的辅助类
	 * @author zhanghaocong
	 *
	 */
	public class GridCellRenderer extends Image implements IArrangeable, IDetailRenderer
	{
		/**
		 * 网格 Y
		 */
		public var cellX:int;

		/**
		 * 网格 X
		 */
		public var cellY:int;

		public function GridCellRenderer(texture:Texture = null)
		{
			super(texture || sharedTexture);
			alpha = 0.5;
		}

		private var _value:int;

		/**
		 * 设置或获取当前网格的值
		 * @return
		 *
		 */
		public function get value():int
		{
			return _value;
		}

		public function set value(value:int):void
		{
			_value = value;

			// 1 可走，其他不可走
			if (value == 0)
			{
				color = 0x00ff00;
			}
			else
			{
				color = 0xffffff;
			}
		}

		/**
		 * 共享了的网格贴图
		 */
		public static var sharedTexture:Texture;

		/**
		* 根据参数刷新网格贴图
		* @param width
		* @param height
		* @return
		*
		*/
		public static function updateTexture(width:Number, height:Number):void
		{
			// 删掉原来的
			if (sharedTexture)
			{
				sharedTexture.dispose();
				sharedTexture = null;
			}
			// 检查任意一边不能超过 2048
			const max:Number = 2048;
			var scale:Number = 1;

			if (width > max)
			{
				scale = max / width;
			}

			if (height > max && height > width)
			{
				scale = max / height;
			}
			width *= scale;
			height *= scale;
			const lineThickness:Number = 1;
			var s:Shape = new Shape();
			var g:Graphics = s.graphics;
			g.beginFill(0x999999);
			g.lineStyle(1, 0xdddddd, lineThickness);
			g.drawRect(lineThickness, lineThickness, width - lineThickness * 2, height - lineThickness * 2);
			g.endFill();
			var b:BitmapData = new BitmapData(width, height, true, 0);
			b.draw(s);
			sharedTexture = Texture.fromBitmapData(b, false);
		}

		public function get zIndex():int
		{
			return 0;
		}

		/**
		 * @inhertDoc
		 *
		 */
		public function updateDetail(visibleRect:Rectangle):void
		{
			// 左边界
			if (x + width < visibleRect.x)
			{
				visible = false;
				return;
			}

			// 上边界
			if (y + height < visibleRect.y)
			{
				visible = false;
				return;
			}

			// 右边界
			if (x - width > visibleRect.right)
			{
				visible = false;
				return;
			}

			// 下边界
			if (y - height > visibleRect.bottom)
			{
				visible = false;
				return;
			}
			visible = true;
		}
	}
}
