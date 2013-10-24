package nt.lib.util
{
	import flash.utils.ByteArray;

	/**
	 * 支持位访问的 ByteArray 子类。
	 * @author Y.Boy
	 *
	 */
	public class BitArray extends ByteArray
	{
		/**
		 * 构造函数。可传递一个 ByteArray 对象进行初始化。
		 * @param bytes 现有的 ByteArray 数据。
		 *
		 */
		public function BitArray(bytes:ByteArray = null)
		{
			if (bytes != null)
			{
				this.writeBytes(bytes, 0, bytes.length);
			}
		}

		/**
		 * 返回位长度。bitLength = ByteArray.length * 8 。
		 * @return
		 *
		 */
		public function get bitLength():uint
		{
			return this.length * 8;
		}

		/**
		 * 返回由参数 index 指定位置处的位的值。1 为 true，0 为 false 。
		 * @param index 一个整数，指示位在 ByteArray 中的位置。第一个位由 0 指示，最后一个位由 BitArray.length * 8 - 1 指示。
		 * @return 指示索引处的位的值。或者，如果指定的索引不在该 ByteArray 的索引范围内，会抛出 RangeErroe 错误，并返回 false 。
		 *
		 */
		public function getBitAt(index:uint = 0):Boolean
		{
			index++; // 索引值加 1 ，计算出长度

			if (index > this.length * 8)
			{
				throw new RangeError("数值不在可接受的范围内。可接受范围为：0 到 ByteArray.length*8-1 。");
				return false;
			}
			var byteIndex:uint = Math.ceil(index / 8) - 1; // 目标字节的索引
			var flag:uint = 1 << (this.length * 8 - index) % 8; // 计算标志位
			return Boolean(this[byteIndex] & flag);
		}

		/**
		 * 设置由参数 index 指定位置处的位的值。如果 index 指定位置处的长度大于当前长度，该字节数组的长度将设置为最大值，右侧多出的位将用零填充。
		 * @param index 一个整数，指示位在 ByteArray 中的位置。第一个位由 0 指示，最后一个位由 BitArray.length * 8 - 1 指示。
		 * @param value 要设置的值。true 为 1 ，false 为 0 。
		 *
		 */
		public function setBitAt(index:uint, value:Boolean):void
		{
			index++; // 索引值加 1 ，计算出长度
			// 如果 index 指定位置处的长度大于当前长度，该字节数组的长度将设置为最大值，右侧多出的位将用零填充。
			var len:uint = Math.ceil(index / 8);

			if (len > this.length)
			{
				this.length = len;
			}
			var byteIndex:uint = Math.ceil(index / 8) - 1;
			var flag:uint = 1 << (this.length * 8 - index) % 8; // 计算标志位

			if (value)
			{
				this[byteIndex] |= flag; // 设置位，即赋值 1
			}
			else
			{
				this[byteIndex] &= ~flag; // 取消位，即赋值 0
			}
		}

		/**
		 * 获取指定坐标处的值，x 轴方向的长度由 lengthX 指定。
		 * @param lengthX x 轴方向上的长度。
		 * @param x x 坐标。
		 * @param y y 坐标。
		 * @return 指定坐标处的值。
		 *
		 */
		public function getBitAtCoord(lengthX:uint, x:uint, y:uint):Boolean
		{
			var i:uint = y * lengthX + x;
			return this.getBitAt(i);
		}
	}
}
