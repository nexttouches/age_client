package nt.lib.util
{
	import flash.text.Font;

	public class FontUtil
	{
		private static const DEFAULT_FONT:String = "_serif";

		/**
		 * 根据指定的字体列表获得第一个可用的字体
		 * @param fonts 字体列表
		 * @param defaultFont 如果指定列表中没有可用字体，则返回默认字体
		 * @return 第一个可用的字体，如果没有可用字体则返回 defaultFont
		 *
		 */
		public static function getAvailableFont(fonts:Array, defaultFont:String = DEFAULT_FONT):String
		{
			var list:Array = Font.enumerateFonts(true);
			var n:int = list.length;
			var fontNames:Object = {};

			for (var i:int = 0; i < n; i++)
			{
				fontNames[list[i].fontName] = true;
			}
			n = fonts.length;

			for (i = 0; i < n; i++)
			{
				if (fonts[i] in fontNames)
				{
					return fonts[i];
				}
			}
			return defaultFont;
		}
	}
}
