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
		 * 默认的加载器路径
		 */
		private static const DEFAULT_MAIN_URL:String = "main.swf";

		/**
		 * 默认的皮肤路径
		 */
		private static const DEFAULT_SKIN_URL:String = "skin.swf";

		/**
		 * 默认版本文件地址
		 */
		private static const DEFAULT_VERSION_URL:String = "";

		/**
		 * 默认 ROOT 地址
		 */
		private static const DEFAULT_ROOT_URL:String = "";

		/**
		 * main.swf 的路径
		 */
		public var main:String = DEFAULT_MAIN_URL;

		/**
		 * 皮肤路径
		 */
		public var skin:String = DEFAULT_SKIN_URL;

		/**
		 * version.bin 路径
		 */
		public var version:String = DEFAULT_VERSION_URL;

		/**
		 * 资源根路径
		 */
		public var root:String = DEFAULT_ROOT_URL;

		/**
		 * constructor
		 *
		 */
		public function PreloaderConfig(raw:Object = null)
		{
			fromJSON(raw);
		}

		/**
		 * 从 JSON 恢复数据
		 * @param raw JSON 反序列化后的对象或任意 Object
		 *
		 */
		public function fromJSON(raw:Object):void
		{
			if (!raw)
			{
				return;
			}

			for (var key:String in raw)
			{
				if (hasOwnProperty(key))
				{
					this[key] = raw[key];
				}
			}
		}
	}
}
