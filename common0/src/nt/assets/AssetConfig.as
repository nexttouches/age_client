package nt.assets
{

	/**
	 * 资源配置
	 * @author kk
	 *
	 */
	public class AssetConfig
	{
		/**
		 * 资源根路径，默认是 "" （空字符串）
		 */
		public static var root:String = "";

		/**
		 * 储存所有 AssetInfo
		 */
		private static var infos:Object = {};

		/**
		 * 获得相对于 AssetConfig.root 的路径
		 * @param args
		 * @return
		 *
		 */
		public static function resolvePath(... args):String
		{
			return AssetConfig.root + args.join("/");
		}

		/**
		 * 任意 path 如果含有该关键字则视为完整 URL
		 */
		private static const URL_KEYWORD:String = "://"

		/**
		 * 根据路径获得指定的 AssetInfo
		 * @param path 相对于 <tt>root</tt> 的路径或完整 URL（如 <tt>http://</tt> 开头）
		 * @return AssetInfo
		 *
		 */
		public static function getInfo(path:String):AssetInfo
		{
			// 缓存中找不到该路径对应的信息，我们创建一个
			if (!infos[path])
			{
				// 检查是否是完整 URL
				const isURL:Boolean = path.indexOf(URL_KEYWORD) != -1;

				if (isURL)
				{
					infos[path] = new AssetInfo({ url: path, path: path });
				}
				else
				{
					// 找不到路径对应的信息，我们 fallback
					infos[path] = new AssetInfo({ path: path }); // 该信息不包含版本
				}
			}
			else
			{
				// infos 可能存的不是 AssetInfo，我们转换一下
				if (!(infos[path] is AssetInfo))
				{
					infos[path] = new AssetInfo(infos[path]);
				}
			}
			return infos[path];
		}

		/**
		 * 初始化 AssetConfig
		 * @param root 资源根路径：比如静态资源的 CDN 路径。
		 * @param infos 可选：资源信息文件，默认 null。事后可以通过 <tt>updateInfos</tt> 来更新
		 *
		 */
		public static function init(root:String, infos:Object = null):void
		{
			AssetConfig.root = root;

			// 检查并补充 "/" 结尾（root 为空字符串时可能是相对路径，故不作修改）
			if (root.length > 0 && root.lastIndexOf("/") != root.length - 1)
			{
				AssetConfig.root += "/";
			}

			if (infos)
			{
				AssetConfig.infos = infos;
			}
			trace("[AssetConfig] 已初始化 (root=" + AssetConfig.root + ")");
		}

		/**
		 * 更新 infos
		 * @param newInfos 要更新的 infos。新旧 info 如遇 path 冲突则报错
		 *
		 */
		public static function updateInfos(newInfos:Object):void
		{
			for each (var info:Object in newInfos)
			{
				// 检查重复的路径
				if (infos.hasOwnProperty(info.path))
				{
					throw new ArgumentError("[AssetConfig] updateInfos 时发生错误：路径重复 (" + info.path + ")");
				}
				infos[info.path] = info;
			}
		}
	}
}
