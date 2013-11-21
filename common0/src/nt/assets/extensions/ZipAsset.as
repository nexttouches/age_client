package nt.assets.extensions
{
	import deng.fzip.FZip;
	import nt.assets.Asset;

	/**
	 * Zip 资源
	 * @author kk
	 *
	 */
	public class ZipAsset extends Asset
	{
		/**
		 * zip 内容
		 */
		public var content:FZip;

		/**
		 * constructor
		 * @param path
		 * @param priority
		 *
		 */
		public function ZipAsset(path:String, priority:int)
		{
			super(path, priority);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function notifyLoadComplete():void
		{
			content = new FZip();
			content.loadBytes(raw);
			super.notifyLoadComplete();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function dispose():void
		{
			content = null;
			super.dispose();
		}

		/**
		 * 根据路径获得 <tt>ZipAsset</tt>
		 * @param path 相对于 <tt>AssetConfig.root</tt> 的路径
		 * @return
		 *
		 */
		public static function get(path:String):ZipAsset
		{
			return Asset.get(path, 0, ZipAsset) as ZipAsset;
		}
	}
}
