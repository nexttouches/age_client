package age.renderers
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import starling.textures.Texture;

	/**
	 * 用来渲染行走区域每个小格子的辅助类
	 * @author zhanghaocong
	 *
	 */
	public class GridCellRenderer extends Image3D implements IDetailRenderer
	{
		/**
		 * 网格 Y
		 */
		public var cellX:int;

		/**
		 * 网格 Z
		 */
		public var cellZ:int;

		/**
		 * constructor
		 *
		 */
		public function GridCellRenderer()
		{
			super();
			texture = sharedTexture;
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

		private var _size:Vector3D;

		/**
		 * 设置或获取当前网格的大小
		 * @return
		 *
		 */
		public function get size():Vector3D
		{
			return _size;
		}

		public function set size(value:Vector3D):void
		{
			_size = value;
			x = cellX * _size.x;
			y = 0;
			z = cellZ * _size.z;
			readjustSize();
			pivotY = texture.height;
		}

		/**
		 * 共享了的网格贴图
		 */
		public static var sharedTexture:Texture;

		/**
		 * 根据参数刷新网格贴图
		 * @param cellSize
		 *
		 */
		public static function updateTexture(cellSize:Vector3D):void
		{
			// 删掉原来的
			if (sharedTexture)
			{
				sharedTexture.dispose();
				sharedTexture = null;
			}
			cellSize = cellSize.clone();
			cellSize.z /= 2; // ÷ 2 得到透视后的大小
			// 检查任意一边不能超过 2048
			const max:Number = 2048;
			var scale:Number = 1;

			if (cellSize.x > max)
			{
				scale = max / cellSize.x;
			}

			if (cellSize.z > max && cellSize.z > cellSize.x)
			{
				scale = max / cellSize.z;
			}
			cellSize.scaleBy(scale);
			const lineThickness:Number = 1;
			var s:Shape = new Shape();
			var g:Graphics = s.graphics;
			g.beginFill(0x999999);
			g.lineStyle(1, 0xdddddd, lineThickness);
			g.drawRect(lineThickness, lineThickness, cellSize.x - lineThickness * 2, cellSize.z - lineThickness * 2);
			g.moveTo(0, cellSize.z - lineThickness * 2);
			g.lineTo(cellSize.x - lineThickness * 2, 0);
			g.endFill();
			var b:BitmapData = new BitmapData(cellSize.x, cellSize.z, true, 0);
			b.draw(s);
			sharedTexture = Texture.fromBitmapData(b, false);
		}

		/**
		 * @inhertDoc
		 *
		 */
		public function updateDetail(visibleRect:Rectangle):void
		{
			return;

			// 左边界
			if (x + width < visibleRect.x)
			{
				visible = false;
				return;
			}

			// 上边界
			/*if (y + height < visibleRect.y)
			{
				visible = false;
				return;
			}*/
			// 右边界
			if (x - width > visibleRect.right)
			{
				visible = false;
				return;
			}
			// 下边界
			/*if (y - height > visibleRect.bottom)
			{
				visible = false;
				return;
			}*/
			visible = true;
		}
	}
}
