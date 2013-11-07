package nt.assets.extensions
{
	import flash.events.Event;
	import flash.media.Sound;
	import nt.assets.Asset;
	import nt.assets.AssetState;

	/**
	 * 声音资源，可以通过调用 sound.play 进行播放
	 * @author zhanghaocong
	 *
	 */
	public class SoundAsset extends Asset
	{
		/**
		 * 用于加载的 Sound 对象
		 */
		public var sound:Sound;

		/**
		 * constructor
		 * @param path
		 * @param priority
		 *
		 */
		public function SoundAsset(path:String, priority:int)
		{
			super(path, priority);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function onComplete(event:Event):void
		{
			stream.readBytes(raw);
			sound = new Sound();
			sound.loadCompressedDataFromByteArray(raw, raw.length);
			_state = AssetState.Loaded;
			notifyLoadComplete();
		}

		/**
		* 根据路径获得 SoundAsset，该路径相对于 AssetConfig.root
		* @param relativePath
		* @return
		*
		*/
		public static function get(relativePath:String):SoundAsset
		{
			return Asset.get(relativePath, 0, SoundAsset) as SoundAsset;
		}
	}
}
