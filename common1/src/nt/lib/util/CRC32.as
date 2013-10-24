
package nt.lib.util
{
	import flash.utils.ByteArray;

	public class CRC32
	{
		private static var CRCTable:Array;

		public static function calc(input:ByteArray):uint
		{
			if (!CRCTable)
			{
				CRCTable = initCRCTable();
			}
			var crc32:uint = 0;
			var offset:int = 0;
			var length:int = input.length;
			var crc:uint = ~crc32;
			for (var i:int = offset; i < length; i++)
			{
				crc = CRCTable[(crc ^ input[i]) & 0xFF] ^ (crc >>> 8);
			}
			crc32 = ~crc;
			return crc32 & 0xFFFFFFFF;
		}

		private static function initCRCTable():Array
		{
			var crcTable:Array = new Array(256);
			for (var i:int = 0; i < 256; i++)
			{
				var crc:uint = i;
				for (var j:int = 0; j < 8; j++)
				{
					crc = (crc & 1) ? (crc >>> 1) ^ 0xEDB88320 : (crc >>> 1);
				}
				crcTable[i] = crc;
			}
			return crcTable;
		}
	}
}
