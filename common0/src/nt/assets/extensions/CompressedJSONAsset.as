package nt.assets.extensions
{
	import nt.assets.Asset;

	/**
	 * 用于加载 JSON 的 Asset
	 * @author KK
	 *
	 */
	public class CompressedJSONAsset extends Asset
	{
		/**
		 * constructor
		 * @param path
		 * @param priority
		 *
		 */
		public function CompressedJSONAsset(path:String, version:int)
		{
			super(path, version);
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
				var json:String = raw.readUTFBytes(raw.bytesAvailable);
				_result = JSON.parse(json);
				trace("[JSONAsset] parse complete " + path);
			}
			return _result;
		}
	}
}
