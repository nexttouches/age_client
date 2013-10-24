package age.utils.objectpools
{
	import starling.display.Image;

	/**
	 * ImagePool<br>
	 * 代码节选自
	 * http://help.adobe.com/zh_CN/as3/mobile/WS948100b6829bd5a6-19cd3c2412513c24bce-8000.html
	 * @author zhanghaocong
	 *
	 */
	public final class ImagePool
	{
		private static var MAX_VALUE:uint;

		private static var GROWTH_VALUE:uint;

		private static var counter:uint;

		private static var pool:Vector.<Image>;

		private static var currentImage:Image;

		public static function init(maxPoolSize:uint, growthValue:uint):void
		{
			MAX_VALUE = maxPoolSize;
			GROWTH_VALUE = growthValue;
			counter = maxPoolSize;
			var i:uint = maxPoolSize;
			pool = new Vector.<Image>(MAX_VALUE);

			while (--i > -1)
				pool[i] = new Image(emptyTexture);
		}

		public static function get():Image
		{
			if (counter > 0)
				return currentImage = pool[--counter];
			var i:uint = GROWTH_VALUE;

			while (--i > -1)
				pool.unshift(new Image(emptyTexture));
			counter = GROWTH_VALUE;
			return get();
		}

		public static function dispose(disposedImage:Image):void
		{
			pool[counter++] = disposedImage;
		}
	}
}
import starling.textures.Texture;

const emptyTexture:Texture = Texture.empty(1, 1);
