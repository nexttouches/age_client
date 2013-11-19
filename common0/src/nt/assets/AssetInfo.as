package nt.assets
{
	import nt.assets.util.URLUtil;

	/**
	 * 资源的基本信息。包括路径、版本、文件大小等
	 * @author zhanghaocong
	 *
	 */
	public class AssetInfo
	{
		/**
		 * 路径（相对于 AssetInfo.root）
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
		 * 地址
		 */
		public var url:String;

		/**
		 * constructor
		 * @param raw
		 *
		 */
		public function AssetInfo(raw:Object = null)
		{
			fromJSON(raw);
		}

		/**
		 * 从 JSON 或一个对象更新
		 * @param raw
		 *
		 */
		public function fromJSON(raw:Object):void
		{
			if (!raw)
			{
				return;
			}
			// 拷贝值
			path = raw.path;
			version = raw.version;
			size = raw.size;
			url = raw.url;
			_filename = null;

			// 如果 url 字段不存在则根据 path 自动创建
			if (!url)
			{
				// 根据 version 填充 url 字段
				if (version)
				{ // 如果有版本号，拼装成改名后的地址
					const dot:int = path.lastIndexOf(".");
					const name:String = path.substring(0, dot);
					const ext:String = path.substr(dot);
					url = AssetConfig.resolvePath(name + "_" + version + ext);
				}
				else
				{ // 如果当前 info 没有版本号，则使用默认地址
					url = AssetConfig.resolvePath(path);
				}
			}
		}

		private var _filename:String;

		/**
		 * 文件名
		 * @return
		 *
		 */
		public function get filename():String
		{
			return _filename ||= URLUtil.getFilename(path);
		}
	}
}
