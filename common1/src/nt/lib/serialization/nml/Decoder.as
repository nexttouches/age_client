package nt.lib.serialization.nml
{
	import flash.debugger.enterDebugger;

	import nt.lib.util.StringUtil;

	internal final class Decoder
	{
		public function Decoder()
		{
		}

		public function decode(input:String, containsComments:Boolean = false):Object
		{
			if (containsComments)
			{
				input = trimComment(input);
			}
			input = StringUtil.organizeLineBreaks(input);
			var d:String = NML.Delimiter; // performence
			var t:String = NML.Terminator; // performence
			var result:Object = {};
			var lines:Array = input.split(t);
			var n:int = lines.length;

			var multilines:Boolean = false;
			var key:String;

			for (var i:int = 0; i < n; i++)
			{
				var line:String = lines[i];
				if (line.length > 0)
				{
					if (multilines)
					{
						if (line.charAt(0) == "|")
						{
							multilines = false;
						}
						else
						{
							result[key] += line;
						}
					}
					else
					{
						var keyIndex:int = line.indexOf(d);
						key = line.substring(0, keyIndex);
						var str:String = line.substring(keyIndex + 1, line.length);
						if (str.charAt(0) == "\\")
						{
							multilines = true;
							result[key] = "";
						}
						else
						{
							result[key] = str;
						}
					}
				}
			}
			return result;
		}

		private function trimComment(s:String):String
		{
			s = s.replace(/\/\*(\s|.)*?\*\//ig, "");
			s = s.replace(/\/\/(\s|.)*\n]/ig, "\n");
			return s;
		}
	}
}
