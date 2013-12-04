package age.renderers
{
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.filters.BlurFilter;
	import age.data.AvatarInfo;
	import age.data.Box;
	import starling.events.Event;
	import starling.textures.Texture;

	/**
	 * 简单阴影渲染器，就是个椭圆形
	 * @author zhanghaocong
	 *
	 */
	public class ShadowRenderer extends TextureRenderer
	{
		/**
		 * constructor
		 *
		 */
		public function ShadowRenderer()
		{
			super();
			// 正片叠底
			blendMode = BlendMode.MULTIPLY;
			//uniqueIndex += ZIndexHelper.SHADOW_OFFSET;
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function get zIndex():int
		{
			return int.MAX_VALUE - 100 + uniqueIndex;
			//return position.z * ZIndexHelper.Z_RANGE + uniqueIndex;
		}

		private var _size:Box;

		/**
		 * 要渲染的阴影尺寸
		 */
		public function get size():Box
		{
			return _size;
		}

		/**
		 * @private
		 */
		public function set size(value:Box):void
		{
			if (_size)
			{
				visible = false;
			}
			_size = value;

			if (_size)
			{
				visible = true;
				draw();
			}
		}

		private var _info:AvatarInfo;

		/**
		 * 设置或获取当前渲染的 AvatarInfo
		 * @return
		 *
		 */
		public function get info():AvatarInfo
		{
			return _info;
		}

		public function set info(value:AvatarInfo):void
		{
			if (_info)
			{
				size = null;
			}
			_info = value;

			if (_info)
			{
				size = _info.size;
			}
		}

		/**
		 * 要求重绘阴影
		 *
		 */
		public function draw():void
		{
			if (!stage)
			{
				addEventListener(Event.ADDED_TO_STAGE, onAdd);
				return;
			}

			if (size && size.width > 0 && size.depth > 0)
			{
				visible = true;
				texture = shadowTexture;
				// 除 2 为了压扁阴影，就不做复杂的透视运算了
				mVertexData.setPosition(0, 0, 0);
				mVertexData.setPosition(1, size.width, 0);
				mVertexData.setPosition(2, 0, size.depth / 2);
				mVertexData.setPosition(3, size.width, size.depth / 2);
				onVertexDataChanged();
				pivotX = size.width / 2;
				pivotY = size.depth / 3.5; // 阴影稍稍偏上一些
			}
			else
			{
				visible = false;
			}
		}

		/**
		 * @private
		 * @param event
		 *
		 */
		protected function onAdd(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAdd);
			draw();
		}

		/**
		 * ShadowRenderer 不支持方向，改了也没用
		 * @param value
		 *
		 */
		override public function set direction(value:int):void
		{
			// 方向无效
		}

		/**
		 * 旧 projectY
		 */
		private var origProjectY:Function;

		/**
		 * @inheritDoc
		 *
		 */
		override public function set projectY(value:Function):void
		{
			origProjectY = value;
			super.projectY = projectY_ignoreY;

			if (value != null)
			{
				validatePosition();
			}
		}

		/**
		 * 忽略 y 参数的 projectY 方法
		 * @param y
		 * @param z
		 * @return
		 *
		 */
		protected function projectY_ignoreY(y:Number, z:Number):Number
		{
			return origProjectY(y * 0.2, z);
		}

		/**
		 * 创建一个 64×64 圆用作阴影
		 * @return
		 *
		 */
		private static function getShadowTexture():Texture
		{
			const radius:int = 32;
			const blur:int = 4;
			const alpha:Number = 0.5;
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0, alpha);
			shape.graphics.drawCircle(radius, radius, radius - blur * 2);
			shape.graphics.endFill();
			shape.filters = [ new BlurFilter(blur, blur)];
			const bitmapData:BitmapData = new BitmapData(radius * 2, radius * 2, true, 0);
			bitmapData.draw(shape);
			return Texture.fromBitmapData(bitmapData);
		}

		/**
		 * @private
		 */
		private static var _shadowTexture:Texture

		/**
		 * 共享了的影子贴图
		 */
		public static function get shadowTexture():Texture
		{
			return _shadowTexture ||= getShadowTexture();
		}
	}
}
