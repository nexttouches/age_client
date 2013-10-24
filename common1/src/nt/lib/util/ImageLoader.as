package nt.lib.util
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;

	/**
	 * 加载 ByteArray 中的图片的小工具类
	 * @author zhanghaocong
	 *
	 */
	public class ImageLoader
	{
		public function ImageLoader()
		{
		}

		private static var defaultLoaderContext:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);

		/**
		 * 读取图片，完成时调用 onComplete(bitmapData)
		 * @param bytes
		 * @param onComplete
		 * @param context
		 *
		 */
		public static function loadBinary(bytes:ByteArray, onComplete:Function, context:LoaderContext = null):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void
			{
				if (loader.content is Bitmap)
				{
					onComplete(Bitmap(loader.content).bitmapData);
				}
				else
				{
					onComplete(loader.content);
				}
				loader.unloadAndStop();
			});
			loader.loadBytes(bytes, context || defaultLoaderContext);
		}
	}
}
