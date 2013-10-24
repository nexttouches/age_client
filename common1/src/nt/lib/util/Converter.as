package nt.lib.util
{


	public class Converter
	{
		public function Converter()
		{
		}

		/**
		 * 智能转换，将字符串转换成预期的类型
		 * @param input
		 * @return
		 *
		 */
		public static function intelligenceConvert(input:String):*
		{
			var result:*;
			if (input == "true") // 自动转换类型：true
			{
				result = true
			}
			else if (input == "false") // 自动转换类型：false
			{
				result = false;
			}
			else if (input == "null") // 自动转换类型：null
			{
				result = null;
			}
			else if (input == "undefined") // 自动转换类型：undefined
			{
				result = undefined;
			}
			else if (!isNaN(result = Number(input))) // 自动转换类型：数字
			{
				// 已在 if 中优化
			}
			else if (input.indexOf("{") == 0 && input.lastIndexOf("}") == 0) // 自动转换类型：JSON
			{
				result = JSON.parse(input);
			}
			else // 字符串
			{
				result = input;
			}
			return result;
		}
	}
}
