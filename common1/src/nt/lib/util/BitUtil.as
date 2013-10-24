package nt.lib.util
{

	public class BitUtil
	{
		/**
		 * 创建一个 8 字节的 buffer
		 * @return
		 *
		 */
		public static function createBuffer():Vector.<Boolean>
		{
			return new Vector.<Boolean>(n, true);
		}

		/**
		 * 把一个字节解成 8 位 Boolean
		 * @param bits
		 * @param bitArray
		 * @return
		 *
		 */
		public static function extract(bits:uint, bitArray:Vector.<Boolean>):Vector.<Boolean>
		{
			if (bitArray.length != n)
			{
				throw new ArgumentError("bitArray 的长度只能是 8");
			}

			for (i = 0; i < n; i++)
			{
				bitArray[i] = Boolean(bits & (1 << i));
			}
			return bitArray;
		}

		/**
		 * helper
		 */
		private static var i:uint;

		/**
		 * helper
		 */
		private static var n:uint = 8;

		/**
		 * helper
		 */
		private static var result:int;

		/**
		 * 把 8 位 Boolean 压到数组
		 * @param bitArray
		 * @return
		 *
		 */
		public static function compress(bitArray:Vector.<Boolean>):uint
		{
			result = 0;

			for (i = 0; i < n; i++)
			{
				if (bitArray[i])
				{
					result |= 1 << i;
				}
				else
				{
					result &= ~(1 << i);
				}
			}
			return result;
		}
	}
}
