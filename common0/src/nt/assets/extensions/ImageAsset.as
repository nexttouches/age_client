package nt.assets.extensions
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import nt.assets.AssetState;

	/**
	 * 用于加载图像的 Asset
	 * @author KK
	 *
	 */
	public class ImageAsset extends LibAsset
	{
		/**
		 * 加载进来的 bitmapData
		 */
		public var result:BitmapData;

		/**
		 * constructor
		 * @param path
		 * @param priority
		 *
		 */
		public function ImageAsset(path:String, priority:int)
		{
			super(path, priority);
		}

		/**
		 * 加载错误的回调<br>
		 * ImageAsset 加载发生错误时将使用一张默认图片代替<br>
		 * 此时状态为 AssetState.Loaded
		 * @param event
		 *
		 */
		override protected function onIOError(event:IOErrorEvent):void
		{
			_state = AssetState.Loaded;
			result = ErrorImage.getInstance();
			// raw 已经没用了，可以先清掉，但是要保留引用，否则 dispose 时会出错
			raw.clear();
			raw = null;
			// 标记为加载完毕
			_state = AssetState.Loaded;
			// 假装是加载完毕了
			notifyLoadComplete()
		}

		/**
		 * @inheritDoc
		 * @param event
		 *
		 */
		protected override function loader_onComplete(event:Event):void
		{
			if (isDisposed)
			{
				return;
			}
			result = Bitmap(event.currentTarget.content).bitmapData;
			super.loader_onComplete(event);
		}

		/**
		 * @inheritDoc
		 * @param event
		 *
		 */
		public override function dispose():void
		{
			if (result && result != ErrorImage.getInstance())
			{
				result.dispose();
				result = null;
			}
			super.dispose();
		}
	}
}
