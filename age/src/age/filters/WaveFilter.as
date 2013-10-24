package age.filters
{
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.geom.Point;
	import age.AGE;
	import starling.animation.IAnimatable;
	import starling.animation.Juggler;
	import starling.core.Starling;
	import starling.filters.DisplacementMapFilter;
	import starling.textures.Texture;

	/**
	 * 水波滤镜
	 * @author zhanghaocong
	 *
	 */
	public class WaveFilter extends DisplacementMapFilter implements IAnimatable
	{
		private var offset:Number = 0;

		private var scaledheight:int = 0;

		private var scaledWidth:int = 0;

		private var scale:Number;

		/**
		 * 创建一个新的 WaveFilter
		 * @param width 宽
		 * @param height 高
		 * @param juggler 要添加到的 juggler
		 *
		 */
		public function WaveFilter(width:int, height:int, juggler:Juggler)
		{
			this.scale = Starling.contentScaleFactor;
			this.scaledWidth = width * scale;
			this.scaledheight = height * scale;
			super(getTexture(width * scale, height * scale, scale), null, BitmapDataChannel.RED, BitmapDataChannel.RED, 40, 5);
			juggler.add(this);
		}

		/**
		 * @inheritDoc
		 * @param time
		 *
		 */
		public function advanceTime(time:Number):void
		{
			if (offset > scaledheight)
			{
				offset = 0;
			}
			else
			{
				offset += time * scale * 20;
			}
			mapPoint.y = offset - scaledheight;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function dispose():void
		{
			mapTexture.dispose();
			AGE.renderJuggler.remove(this);
			super.dispose();
		}

		/**
		 * 根据参数获得贴图
		 * @param scaledWidth
		 * @param scaledHeight
		 * @param scale
		 * @return
		 *
		 */
		public static function getTexture(scaledWidth:int, scaledHeight:int, scale:Number):Texture
		{
			// XXX 做个缓存
			var perlinData:BitmapData = new BitmapData(scaledWidth, scaledHeight, false);
			perlinData.perlinNoise(200 * scale, 20 * scale, 2, 5, true, true, 0, true);
			var dispMap:BitmapData = new BitmapData(scaledWidth, scaledHeight * 2, false);
			dispMap.copyPixels(perlinData, perlinData.rect, new Point(0, 0));
			dispMap.copyPixels(perlinData, perlinData.rect, new Point(0, perlinData.height));
			var texture:Texture = Texture.fromBitmapData(dispMap);
			return texture;
		}
	}
}
