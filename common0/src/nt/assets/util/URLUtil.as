package nt.assets.util
{

	/**
	 * URL 工具类
	 * @author kk
	 *
	 */
	public class URLUtil
	{
		/**
		 * 获得指定路径中的后缀名（不含 "."）
		 * @param path
		 * @return
		 *
		 */
		public static function getExtension(path:String):String
		{
			var q:int = path.indexOf("?");

			if (q == -1)
			{
				q = int.MAX_VALUE;
			}
			var dot:int = path.lastIndexOf(".", q);

			if (dot == -1)
			{
				return "";
			}
			return path.substring(dot + 1, q);
		}

		/**
		 * 获得指定路径中的文件名（不含后缀名）
		 * @param path
		 * @return
		 *
		 */
		public static function getFilename(path:String):String
		{
			var seg:Array = path.split("/");
			var fullname:String = String(seg[seg.length - 1]);
			var dot:int = fullname.lastIndexOf(".");

			if (dot == -1)
			{
				return fullname;
			}
			return fullname.substring(0, dot);
		}
	}
}
