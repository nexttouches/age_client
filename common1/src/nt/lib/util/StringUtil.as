package nt.lib.util
{
	import flash.utils.ByteArray;

	public class StringUtil
	{

		/**
		 * 是否为Email地址;
		 * @param char
		 * @return
		 *
		 */
		public static function isEmail(char:String):Boolean
		{
			if (char == null)
			{
				return false;
			}
			char = trim(char);
			var pattern:RegExp = /(\w|[_.\-])+@((\w|-)+\.)+\w{2,4}+/;
			var result:Object = pattern.exec(char);
			if (result == null)
			{
				return false;
			}
			return true;
		}

		/**
		 * 是否是数值字符串;
		 * @param char
		 * @return
		 *
		 */
		public static function isNumber(char:String):Boolean
		{
			if (char == null)
			{
				return false;
			}
			return !isNaN(Number(char));
		}

		/**
		 * 是否为Double型数据;
		 * @param char
		 * @return
		 *
		 */
		public static function isDouble(char:String):Boolean
		{
			char = trim(char);
			var pattern:RegExp = /^[-\+]?\d+(\.\d+)?$/;
			var result:Object = pattern.exec(char);
			if (result == null)
			{
				return false;
			}
			return true;
		}

		/**
		 * Integer;
		 * @param char
		 * @return
		 *
		 */
		public static function isInteger(char:String):Boolean
		{
			if (char == null)
			{
				return false;
			}
			char = trim(char);
			var pattern:RegExp = /^[-\+]?\d+$/;
			var result:Object = pattern.exec(char);
			if (result == null)
			{
				return false;
			}
			return true;
		}

		/**
		 * English;
		 * @param char
		 * @return
		 *
		 */
		public static function isEnglish(char:String):Boolean
		{
			if (char == null)
			{
				return false;
			}
			char = trim(char);
			var pattern:RegExp = /^[A-Za-z]+$/;
			var result:Object = pattern.exec(char);
			if (result == null)
			{
				return false;
			}
			return true;
		}

		/**
		 * 中文;
		 * @param char
		 * @return
		 *
		 */
		public static function isChinese(char:String):Boolean
		{
			if (char == null)
			{
				return false;
			}
			char = trim(char);
			var pattern:RegExp = /^[\u0391-\uFFE5]+$/;
			var result:Object = pattern.exec(char);
			if (result == null)
			{
				return false;
			}
			return true;
		}

		/**
		 * 双字节
		 * @param char
		 * @return
		 *
		 */
		public static function isDoubleChar(char:String):Boolean
		{
			if (char == null)
			{
				return false;
			}
			char = trim(char);
			var pattern:RegExp = /^[^\x00-\xff]+$/;
			var result:Object = pattern.exec(char);
			if (result == null)
			{
				return false;
			}
			return true;
		}

		/**
		 * 含有中文字符
		 * @param char
		 * @return
		 *
		 */
		public static function hasChineseChar(char:String):Boolean
		{
			if (char == null)
			{
				return false;
			}
			char = trim(char);
			var pattern:RegExp = /[^\x00-\xff]/;
			var result:Object = pattern.exec(char);
			if (result == null)
			{
				return false;
			}
			return true;
		}

		/**
		 * 注册字符;
		 * @param char
		 * @param len
		 * @return
		 *
		 */
		public static function hasAccountChar(char:String, len:uint = 15):Boolean
		{
			if (char == null)
			{
				return false;
			}
			if (len < 10)
			{
				len = 15;
			}
			char = trim(char);
			var pattern:RegExp = new RegExp("^[a-zA-Z0-9][a-zA-Z0-9_-]{0," + len + "}$", "");
			var result:Object = pattern.exec(char);
			if (result == null)
			{
				return false;
			}
			return true;
		}

		/**
		 * URL地址;
		 * @param char
		 * @return
		 *
		 */
		public static function isURL(char:String):Boolean
		{
			if (char == null)
			{
				return false;
			}
			char = trim(char).toLowerCase();
			var pattern:RegExp = /^http:\/\/[A-Za-z0-9]+\.[A-Za-z0-9]+[\/=\?%\-&_~`@[\]\':+!]*([^<>\"\"])*$/;
			var result:Object = pattern.exec(char);
			if (result == null)
			{
				return false;
			}
			return true;
		}

		/**
		 * 是否为空白;
		 * @param char
		 * @return
		 *
		 */
		public static function isWhitespace(char:String):Boolean
		{
			switch (char)
			{
				case " ":
				case "\t":
				case "\r":
				case "\n":
				case "\f":
					return true;
				default:
					return false;
			}
		}

		/**
		 * 去左右空格
		 * @param char
		 * @return
		 *
		 */
		public static function trim(s:String):String
		{
			return s.replace(/^\s+|\s+$/gs, '');
		}

		/**
		 * 去左空格
		 * @param char
		 * @return
		 *
		 */
		public static function ltrim(char:String):String
		{
			if (char == null)
			{
				return null;
			}
			var pattern:RegExp = /^\s*/;
			return char.replace(pattern, "");
		}

		/**
		 * 去右空格
		 * @param char
		 * @return
		 *
		 */
		public static function rtrim(char:String):String
		{
			if (char == null)
			{
				return null;
			}
			var pattern:RegExp = /\s*$/;
			return char.replace(pattern, "");
		}


		/**
		 * utf16转utf8编码
		 * @param char
		 * @return
		 *
		 */
		public static function utf16to8(char:String):String
		{
			var out:Array = new Array();
			var len:uint = char.length;
			for (var i:uint = 0; i < len; i++)
			{
				var c:int = char.charCodeAt(i);
				if (c >= 0x0001 && c <= 0x007F)
				{
					out[i] = char.charAt(i);
				}
				else if (c > 0x07FF)
				{
					out[i] = String.fromCharCode(0xE0 | ((c >> 12) & 0x0F), 0x80 | ((c >> 6) & 0x3F), 0x80 | ((c >> 0) & 0x3F));
				}
				else
				{
					out[i] = String.fromCharCode(0xC0 | ((c >> 6) & 0x1F), 0x80 | ((c >> 0) & 0x3F));
				}
			}
			return out.join('');
		}

		/**
		 * utf8转utf16编码
		 * @param char
		 * @return
		 *
		 */
		public static function utf8to16(char:String):String
		{
			var out:Array = new Array();
			var len:uint = char.length;
			var i:uint = 0;
			var char2:int, char3:int;
			while (i < len)
			{
				var c:int = char.charCodeAt(i++);
				switch (c >> 4)
				{
					case 0:
					case 1:
					case 2:
					case 3:
					case 4:
					case 5:
					case 6:
					case 7:
						// 0xxxxxxx  
						out[out.length] = char.charAt(i - 1);
						break;
					case 12:
					case 13:
						// 110x xxxx   10xx xxxx  
						char2 = char.charCodeAt(i++);
						out[out.length] = String.fromCharCode(((c & 0x1F) << 6) | (char2 & 0x3F));
						break;
					case 14:
						// 1110 xxxx  10xx xxxx  10xx xxxx  
						char2 = char.charCodeAt(i++);
						char3 = char.charCodeAt(i++);
						out[out.length] = String.fromCharCode(((c & 0x0F) << 12) | ((char2 & 0x3F) << 6) | ((char3 & 0x3F) << 0));
						break;
				}
			}
			return out.join('');
		}

		/**
		 * 转换字符编码
		 * @param char
		 * @param charset
		 * @return
		 *
		 */
		public static function encodeCharset(char:String, charset:String):String
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(char);
			bytes.position = 0;
			return bytes.readMultiByte(bytes.length, charset);
		}

		/**
		 * 添加新字符到指定位置
		 * @param char
		 * @param value
		 * @param position
		 * @return
		 *
		 */
		public static function addAt(char:String, value:String, position:int):String
		{
			if (position > char.length)
			{
				position = char.length;
			}
			var firstPart:String = char.substring(0, position);
			var secondPart:String = char.substring(position, char.length);
			return (firstPart + value + secondPart);
		}

		/**
		 * 替换指定位置字符
		 * @param char
		 * @param value
		 * @param beginIndex
		 * @param endIndex
		 * @return
		 *
		 */
		public static function replaceAt(char:String, value:String, beginIndex:int, endIndex:int):String
		{
			beginIndex = Math.max(beginIndex, 0);
			endIndex = Math.min(endIndex, char.length);
			var firstPart:String = char.substr(0, beginIndex);
			var secondPart:String = char.substr(endIndex, char.length);
			return (firstPart + value + secondPart);
		}

		/**
		 * 删除指定位置字符
		 * @param char
		 * @param beginIndex
		 * @param endIndex
		 * @return
		 *
		 */
		public static function removeAt(char:String, beginIndex:int, endIndex:int):String
		{
			return StringUtil.replaceAt(char, "", beginIndex, endIndex);
		}

		/**
		 * 修复双换行符
		 * @param char
		 * @return
		 *
		 */
		public static function fixNewlines(char:String):String
		{
			return char.replace(/\r\n/gm, "\n");
		}

		/**
		 * 删除单行和多行注释
		 * @param s
		 * @return
		 *
		 */
		public static function removeComments(s:String):String
		{
			var buffer:Array = [];
			const Slash:String = "/";
			const Star:String = "*";
			const R:String = "\r";
			const SingleLine:int = 1; // 单行注释
			const MultiLine:int = 2; // 多行注释
			var parseComment:Boolean = false; // 标记是否开始分析注释
			var currentCommentType:int = 0; // 当前扫描到的注释类型，0 表示不是注释
			var index:int = 0;
			while (true)
			{
				var char:String = s.charAt(index);
				if (currentCommentType == 0)
				{
					if (char != Slash)
					{
						buffer.push(char);
					}
					else
					{
						// 探测下一个字符是 / 还是 *
						var nextChar:String = s.charAt(index + 1);
						if (nextChar == Slash)
						{
							currentCommentType = SingleLine;
						}
						else if (nextChar == Star)
						{
							currentCommentType = MultiLine;
						}
						else
						{
							buffer.push(char);
						}
					}
				}
				else if (currentCommentType == SingleLine)
				{
					if (char == R)
					{
						currentCommentType = 0
					}
				}
				else if (currentCommentType == MultiLine)
				{
					if (char == Star)
					{
						// 探测下一个字符是不是斜杠
						if (char.charAt(index + 1) == Slash)
						{
							index++;
							currentCommentType = 0;
						}
					}
				}
				index++;
				if (index >= s.length)
				{
					break;
				}
			}
			return buffer.join("");
		}

		/**
		* 整理换行，该方法会删除多余的空行和 \n 标记
		* @param s
		* @return
		*
		*/
		public static function organizeLineBreaks(s:String):String
		{
			return s.replace(/\r\n/g, "\r").replace(/\n/g, "\r").replace(/\r{2,}/g, "\r");
		}
	}
}
