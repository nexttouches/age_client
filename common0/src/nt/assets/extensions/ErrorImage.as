package nt.assets.extensions
{
	import flash.display.BitmapData;

	[Embed(source="assets/error.png")]
	/**
	 * 错误图片<br>
	 * 这里使用独立的类，以避免不必要的 BitmapAsset 嵌入
	 */
	public class ErrorImage extends BitmapData
	{
		public function ErrorImage()
		{
			super(0, 0);
		}

		private static var instance:ErrorImage;

		/**
		 * 获得唯一的 ErrorImage
		 * @return
		 *
		 */
		public static function getInstance():ErrorImage
		{
			return instance ||= new ErrorImage();
		}
	}
}
