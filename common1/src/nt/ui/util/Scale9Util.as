package nt.ui.util
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	public class Scale9Util
	{
		private static var m:Matrix = new Matrix();

		/**
		 * 使用指定的参数绘制九宫格
		 * @param bitmapData 九宫格图片
		 * @param graphics 指定的 Graphics 对象
		 * @param width 九宫格宽
		 * @param height 九宫格高
		 * @param scale9Grid 在 flash 中设计好的九宫格网格
		 *
		 */
		public static function draw(bitmapData:BitmapData, graphics:Graphics, width:Number, height:Number, scale9Grid:Rectangle):void
		{
			// 为没有设置 scale9Grid 的情况下提供快速绘制
			if (!scale9Grid)
			{
				m.identity();
				m.a = width / bitmapData.width;
				m.d = height / bitmapData.height;
				graphics.clear();
				graphics.beginBitmapFill(bitmapData, m);
				graphics.drawRect(0, 0, width, height);
				graphics.endFill();
				return;
			}
			var x:int, y:int;
			var offsetX:int = 0, offsetY:int;
			var drawX:int = 0, drawY:int;
			var girdWidth:int, gridHeight:int;
			var drawWidth:int, drawHeight:int;
			var bitmapDataWidth:int = bitmapData.width;
			var bitmapDataHeight:int = bitmapData.height;
			// 分别是 ↖、↑、↗ 3 个位置的宽度 
			var widths:Array = [ scale9Grid.left, scale9Grid.width, bitmapDataWidth - scale9Grid.right ];
			// 分别是 ↖、←、↙ 3 个位置的高度
			var heights:Array = [ scale9Grid.top, scale9Grid.height, bitmapDataHeight - scale9Grid.bottom ];
			// 设置中心格子的绘制尺寸
			var centerGridWidth:int = width - widths[0] - widths[2];
			var centerGridHeight:int = height - heights[0] - heights[2];
			graphics.clear();
			m.identity();
			const n:int = 3;

			for (x = 0; x < n; x++)
			{
				// 九宫格中该部分的原始尺寸
				girdWidth = widths[x];
				// 要绘制的宽度，如果是中间（x=1）那一格的话就要计算实际大小				
				drawWidth = x == 1 ? centerGridWidth : widths[x];
				// y 轴从 0 开始绘制
				drawY = offsetY = 0;

				for (y = 0; y < n; y++)
				{
					gridHeight = heights[y];
					drawHeight = y == 1 ? centerGridHeight : heights[y];

					if (drawWidth > 0 && drawHeight > 0)
					{
						// 缩放操作，通常只有绘制到中间格子才需要缩放
						m.a = drawWidth / girdWidth;
						m.d = drawHeight / gridHeight;
						// 平移操作，指定从 bitmapData 的哪个部分开始绘制
						m.tx = int(-offsetX * m.a + drawX);
						m.ty = int(-offsetY * m.d + drawY);
						// 绘制
						graphics.beginBitmapFill(bitmapData, m);
						graphics.drawRect(drawX, drawY, drawWidth, drawHeight);
					}
					// 更新偏移
					offsetY += gridHeight;
					drawY += drawHeight;
				}
				// 更新偏移
				offsetX += girdWidth;
				drawX += drawWidth;
			}
			graphics.endFill();
		}

		private static var cachedBitmapDatas:Dictionary = new Dictionary;

		public static function getBitmapData(factory:Class):BitmapData
		{
			if (!cachedBitmapDatas[factory])
			{
				var origin:DisplayObject = new factory;
				var bitmapData:BitmapData = new BitmapData(origin.width, origin.height, true, 0);
				bitmapData.draw(origin);
				cachedBitmapDatas[factory] = bitmapData;
			}
			return cachedBitmapDatas[factory];
		}

		public static function disposeBitmapDataCache():void
		{
			for each (var bitmapData:BitmapData in cachedBitmapDatas)
			{
				bitmapData.dispose();
			}
			cachedBitmapDatas = new Dictionary;
		}
	}
}
