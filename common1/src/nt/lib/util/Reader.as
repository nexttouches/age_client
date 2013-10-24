package nt.lib.util
{
	import flash.utils.ByteArray;

	public class Reader
	{
		private var str:String;

		private var splitter:String = "\r\n";

		private var start:int = 0;

		private var end:int = 0;

		private var line:String;

		private var res:String = "";

		public function Reader(str:String)
		{
			this.str = str;
		}

		public function readLine():String
		{
			if (end == -1)
			{
				return null;
			}
			end = str.indexOf(splitter, start);
			line = str.substring(start, end);
			start = end + splitter.length;
			return line;
		}
	}
}
