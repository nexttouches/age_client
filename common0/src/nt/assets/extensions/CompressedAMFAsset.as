package nt.assets.extensions
{
	import nt.assets.Asset;

	/**
	 * 用于加载 AMF 的 Asset
	 * @author KK
	 *
	 */
	public class CompressedAMFAsset extends Asset
	{
		/**
		 * constructor
		 * @param path
		 * @param priority
		 *
		 */
		public function CompressedAMFAsset(path:String, priority:int)
		{
			super(path, priority);
		}

		private var _result:*;

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		public function get result():*
		{
			if (!_result)
			{
				raw.uncompress();
				_result = raw.readObject();
				trace("[CompressedAMFAsset] parse complete " + path);
			}
			return _result;
		}
	}
}
