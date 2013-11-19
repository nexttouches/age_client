package nt.assets
{

	/**
	 * 资源状态常量集
	 * @author KK
	 * @see Asset#state
	 */
	public class AssetState
	{
		/**
		 * 尚未开始加载
		 */
		public static const NOT_LOADED:int = 0;

		/**
		 * 正在下载
		 */
		public static const LOADING:int = 1;

		/**
		 * 已下载完毕
		 */
		public static const LOADED:int = 2;

		/**
		 * 下载时出现错误
		 */
		public static const ERROR:int = 3;

		/**
		 * 资源是否已被释放，这表示该资源不可再使用
		 */
		public static const DISPOSED:int = 4;

		public static const NAMES:Vector.<String> = new <String>[ "NOT_LOADED", "LOADING",
																  "LOADED", "ERROR",
																  "DISPOSED" ];
	}
}
