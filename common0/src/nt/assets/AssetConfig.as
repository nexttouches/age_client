package nt.assets
{
	import flash.utils.Dictionary;
	import nt.assets.extensions.CompressedAMFAsset;
	import nt.assets.extensions.ImageAsset;
	import nt.assets.extensions.LibAsset;
	import nt.assets.extensions.SoundAsset;
	import nt.assets.extensions.TextAsset;
	import nt.assets.extensions.ZipAsset;

	/**
	 * 资源配置
	 * @author kk
	 *
	 */
	public class AssetConfig
	{
		/**
		 * 通常是 Flash Vars 进来的版本
		 */
		public static var version:String;

		/**
		 * 资源根路径
		 */
		public static var root:String;

		/**
		 * 程序最后一次打包时间，应该通过 flashVars 进来
		 */
		public static var lastBuild:Number;

		/**
		 * 标记是否已初始化
		 */
		public static var isInit:Boolean;

		/**
		 * @private
		 */
		private static var infos:Dictionary;

		public static var isEditMode:Boolean;

		public static var isPathIsURL:Boolean;

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
		 * 设置或获取是否启用无缓存模式
		 */
		public static var noCache:Boolean = false;

		/**
		 * 根据路径获得指定的 AssetInfo
		 * @param path
		 * @return
		 *
		 */
		public static function getInfo(path:String):AssetInfo
		{
			if (!infos)
			{
				throw new Error("AssetConfig 尚未初始化");
			}

			if (!infos[path])
			{
				infos[path] = { path: path, pathIsURL: isPathIsURL };
			}

			if (!(infos[path] is AssetInfo))
			{
				infos[path] = new AssetInfo(infos[path]);
			}
			return infos[path];
		}

		/**
		 * 初始化 AssetConfig
		 * @param infos 键为路径，值为 {path, version, size} 的对象数组
		 * @param version 整个 AssetConfig 的版本
		 * @param root 资源根目录
		 * @param isEditMode 可选，是否是编辑模式
		 * @param isPathIsURL 可选，路径是否已是完整路径
		 *
		 */
		public static function init(infos:Dictionary, version:String, root:String, isEditMode:Boolean = false, isPathIsURL:Boolean = false):void
		{
			if (isInit)
			{
				return;
//				throw new Error("AssetConfig 不能重复初始化");
			}
			AssetConfig.isEditMode = isEditMode;
			AssetConfig.isPathIsURL = isPathIsURL;
			isInit = true;
			AssetConfig.version = version;
			AssetConfig.root = root;
			AssetConfig.infos = infos;
			Asset.register("lib", LibAsset);
			Asset.register("swf", LibAsset);
			Asset.register("anis", ZipAsset);
			Asset.register("xml", TextAsset);
			Asset.register("png", ImageAsset);
			Asset.register("jpg", ImageAsset);
			Asset.register("jxr", ImageAsset);
			Asset.register("cfg", CompressedAMFAsset);
			Asset.register("mp3", SoundAsset);
		}

		public static function dispose():void
		{
			if (!isInit)
			{
				throw new Error("尚未初始化");
			}
			isInit = false;
			Asset.unregister("lib");
			Asset.unregister("swf");
			Asset.unregister("anis");
			Asset.unregister("xml");
			Asset.unregister("png");
			Asset.unregister("jpg");
			Asset.unregister("jxr");
			Asset.unregister("cfg");
			Asset.unregister("mp3");
		}
	}
}
