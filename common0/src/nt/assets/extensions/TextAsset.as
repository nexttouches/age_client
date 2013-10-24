package nt.assets.extensions
{
	import flash.events.Event;
	import nt.assets.Asset;
	import nt.assets.AssetState;

	/**
	 * 文本 Asset
	 * @author kk
	 *
	 */
	public class TextAsset extends Asset
	{
		/**
		 * constructor
		 * @param path
		 * @param priority
		 *
		 */
		public function TextAsset(path:String, priority:int)
		{
			super(path, priority);
		}

		/**
		 * 文本内容
		 */
		public var content:String;

		/**
		 * @inheritDoc
		 *
		 */
		override protected function onComplete(event:Event):void
		{
			stream.readBytes(raw);
			content = String(raw);
			_state = AssetState.Loaded;
			notifyLoadComplete();
		}
	}
}
