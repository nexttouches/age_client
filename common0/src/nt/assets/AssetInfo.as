package nt.assets
{
	import nt.assets.util.URLUtil;

	/**
	 * 资源的基本信息，包括路径，版本，文件大小
	 * @author zhanghaocong
	 *
	 */
	public class AssetInfo
	{
		/**
		 * 路径
		 */
		public var path:String;

		/**
		 * 版本
		 */
		public var version:String;

		/**
		 * 文件大小
		 */
		public var size:uint;

		/**
		 * 标记路径是否是完整 URL
		 */
		private var pathIsURL:Boolean;

		private var _filename:String;

		/**
		 * 文件名
		 * @return
		 *
		 */
		public function get filename():String
		{
			if (!_filename)
			{
				_filename = URLUtil.getFilename(path);
			}
			return _filename;
		}

		/**
		 * constructor
		 * @param raw
		 *
		 */
		public function AssetInfo(raw:Object)
		{
			this.path = raw.path;
			this.version = raw.version;
			this.size = raw.size;
			this.pathIsURL = raw.pathIsURL;
			buildUrl();
		}

		/**
		 * 构建 URL
		 *
		 */
		private function buildUrl():void
		{
			// 调试版本专用，不带版本号的路径
			if (pathIsURL || !version)
			{
				_url = AssetConfig.root + path;

				if (AssetConfig.noCache)
				{
					_url += "?" + Math.random();
				}
			}
			else
			{
				var dot:int = path.lastIndexOf(".");
				var name:String = path.substring(0, dot);
				var ext:String = path.substr(dot);
				_url = AssetConfig.root + name + "_" + version + ext;
			}
		}

		private var _url:String;

		/**
		 * 完整路径
		 */
		[Inline]
		final public function get url():String
		{
			return _url;
		}
	}
}
