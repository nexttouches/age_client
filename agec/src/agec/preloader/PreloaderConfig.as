package agec.preloader
{

	/**
	 * 预加载配置文件
	 * @author zhanghaocong
	 *
	 */
	public class PreloaderConfig
	{
		/**
		 * 默认资源根目录
		 */
		public static const DEFAULT_ROOT_PATH:String = "../../test_assets/bin/";

		/**
		 * 默认加载器路径
		 */
		public static const DEFAULT_PRELOADER_PATH:String = "preloaderskin.swf";

		/**
		 * 版本
		 */
		public var version:String;

		/**
		 * 时间（字符串）
		 */
		public var time:String;

		/**
		 * 构建次数
		 */
		public var build:int = 0;

		/**
		 * version.bin 路径
		 */
		public var versionPath:String;

		/**
		 * preloader 的皮肤路径，默认是 preloaderskin.swf
		 */
		public var skinPath:String;

		/**
		 * main.swf 路径（固定为 "main.swf"）
		 */
		public const mainPath:String = "main.swf";

		/**
		 * 资源根路径
		 */
		public var rootPath:String;

		/**
		 * constructor
		 *
		 */
		public function PreloaderConfig()
		{
		}

		/**
		 * 初始化配置
		 * @param parameters 外部传入的 FlashVars
		 *
		 */
		public function init(params:Object):void
		{
			// 收集数据
			rootPath = params.rootPath || DEFAULT_ROOT_PATH;
			skinPath = params.skinPath || DEFAULT_PRELOADER_PATH;
			version = params.version;
			build = params.build;
			time = params.time;

			// 有版本和没版本加载不同的 version.bin
			if (version)
			{
				versionPath = "version_" + version + ".bin";
			}
			else
			{
				versionPath = "version.bin";
			}
			time = params.time;
			build = params.build;
		}
	}
}
