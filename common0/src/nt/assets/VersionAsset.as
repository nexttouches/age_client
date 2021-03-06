package nt.assets
{

	/**
	 * 用于加载版本信息的 Asset
	 * @author zhanghaocong
	 *
	 */
	public class VersionAsset extends Asset
	{
		/**
		 * constructor
		 *
		 */
		public function VersionAsset(path:String, priority:int)
		{
			super(path, priority);
		}

		private var _result:Object;

		/**
		 * version.bin 中包含的版本信息
		 * @return
		 *
		 */
		public function get result():*
		{
			if (!_result)
			{
				_result = {};
				raw.uncompress();
				const fileVersion:int = raw.readByte();

				if (fileVersion == 1)
				{
					const n:uint = raw.readUnsignedInt();

					for (var i:int = 0; i < n; i++)
					{
						const path:String = raw.readUTF();
						const version:String = raw.readUTF();
						const size:int = raw.readInt();
						_result[path] = { path: path, version: version, size: size };
					}
				}
			}
			return _result;
		}

		/**
		* 根据路径获得 <tt>VersionAsset</tt>
		* @param path 相对于 <tt>AssetConfig.root</tt> 的路径
		* @return
		*
		*/
		public static function get(path:String):VersionAsset
		{
			return Asset.get(path, 0, VersionAsset) as VersionAsset;
		}
	}
}
