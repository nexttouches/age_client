package nt.lib.socket
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class PacketHeader
	{
		// num  & 0xffffffff  后4个字节
		// num >> 32 就是前4个字节了
		public static const UINT64_HACK:Number = Math.pow(2, 32);

		public static const UINT64_HACK_INVERSE:Number = 1 / UINT64_HACK;

		public static const Version:int = 1;

		public static const Compressed:int = 1;

		public static const TS:int = 8;

		public static const BodyLength:int = 4;

		public static const HeaderSize:int = Version + Compressed + TS + BodyLength;

		/**
		 * big endian
		 */
		public static const Endian:String = flash.utils.Endian.BIG_ENDIAN;

		public var version:int;

		public var compressed:Boolean;

		public var ts:Number;

		public var bodyLength:uint;

		public function PacketHeader(version:uint, compressed:Boolean = false, ts:Number = 0, bodyLength:uint = 0)
		{
			this.version = version;
			this.compressed = compressed;
			this.ts = ts;
			this.bodyLength = bodyLength;
		}

		public static function parse(buffer:ByteArray):PacketHeader
		{
			var result:PacketHeader = new PacketHeader(buffer.readUnsignedByte(), buffer.readUnsignedByte() == 1);
			var tsPart1:uint = buffer.readUnsignedInt();
			var tsPart2:uint = buffer.readUnsignedInt();
			result.ts = tsPart2 + tsPart1 * PacketHeader.UINT64_HACK;
			result.bodyLength = buffer.readUnsignedInt();
			return result;
		}
	}
}
