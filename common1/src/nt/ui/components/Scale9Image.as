package nt.ui.components
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import nt.ui.core.SkinnableComponent;
	import nt.ui.util.Scale9Util;

	/**
	 * 可以为任何 IBitmapDrawable 实现九宫格效果，不再受限于 flash player
	 * @author KK
	 *
	 */
	public class Scale9Image extends SkinnableComponent
	{
		public function Scale9Image(skin:* = null)
		{
			super(skin);
		}

		override public function setSkin(value:DisplayObject):void
		{
			if (value)
			{
				super.setSkin(value);
				setImageClass(skin["constructor"]);
			}
		}

		private var _imageClass:Class;

		public function get imageClass():Class
		{
			return _imageClass;
		}

		public function set imageClass(value:Class):void
		{
			_imageClass = value;
			setImageClass(value);
		}

		override protected function render():void
		{
			if (scale9GridChanged)
			{
				scale9GridChanged = false;
				var started:int = getTimer();

				if (!_scale9Grid)
				{
					if (_width == 0 || _height == 0)
					{
						width = scale9BitmapData.width;
						height = scale9BitmapData.height;
					}
				}
				Scale9Util.draw(scale9BitmapData, graphics, _width, _height, _scale9Grid);
					// traceex("[Scale9Image] {0} drawing completed in {1}", this.name, started - getTimer());
			}
			super.render();
		}

		override public function set height(value:Number):void
		{
			scale9GridChanged = true;
			super.height = value;
		}

		override public function set width(value:Number):void
		{
			scale9GridChanged = true;
			super.width = value;
		}

		private var scale9GridChanged:Boolean;

		private var _scale9Grid:Rectangle;

		override public function get scale9Grid():Rectangle
		{
			return _scale9Grid;
		}

		override public function set scale9Grid(innerRectangle:Rectangle):void
		{
			scale9GridChanged = true;
			_scale9Grid = innerRectangle;

			if (_scale9Grid)
			{
				// 取整处理
				_scale9Grid.x = _scale9Grid.x >> 0;
				_scale9Grid.y = _scale9Grid.y >> 0;
				_scale9Grid.width = _scale9Grid.width >> 0;
				_scale9Grid.height = _scale9Grid.height >> 0;

				if (_scale9Grid.right > scale9BitmapData.width || _scale9Grid.bottom > scale9BitmapData.height)
				{
					throw new Error("九宫格不能超过原图尺寸");
				}
			}
			invalidate();
		}

		private var scale9BitmapData:BitmapData;

		private function setImageClass(value:Class):void
		{
			// 使用没有缩放过的原版皮肤做模板
			scale9BitmapData = Scale9Util.getBitmapData(value)
			scale9Grid = skin.scale9Grid;
			removeChildren();
		}
	}
}
