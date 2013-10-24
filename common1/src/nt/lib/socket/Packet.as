package nt.lib.socket
{
	import flash.utils.ByteArray;
	import nt.lib.socket.config.PacketConfig;

	public class Packet
	{
		/**
		 * 包头信息
		 */
		public var header:PacketHeader;

		/**
		 * 包数据
		 */
		public var data:*;

		public function Packet(data:* = null)
		{
			this.data = data;
		}

		private var _buffer:ByteArray;

		public function get buffer():ByteArray
		{
			if (!_buffer)
			{
				_buffer = new ByteArray;
				var body:ByteArray = new ByteArray();
				body.writeUTFBytes(JSON.stringify(data));
				header = new PacketHeader(PacketConfig.Version, false, 0, body.length);

				if (PacketConfig.Compression == PacketCompression.Auto && body.length > 512)
				{
					header.compressed = true;
				}
				else if (PacketConfig.Compression == PacketCompression.Always)
				{
					header.compressed = true;
				}
				else
				{
					header.compressed = false;
				}

				if (header.compressed)
				{
					body.deflate();
				}
				_buffer.writeByte(header.version);
				_buffer.writeByte(header.compressed ? 1 : 0);
				_buffer.writeUnsignedInt(header.ts * PacketHeader.UINT64_HACK_INVERSE);
				_buffer.writeUnsignedInt(uint(header.ts));
				_buffer.writeUnsignedInt(header.bodyLength);
				_buffer.writeBytes(body);
			}
			return _buffer;
		}

		public static function parse(buffer:ByteArray):Packet
		{
			var result:Packet;
			var header:PacketHeader = PacketHeader.parse(buffer);

			if (buffer.position + header.bodyLength <= buffer.bytesAvailable)
			{
				result = new Packet();
				result.header = header;
				var json:String;

				if (!result.header.compressed)
				{
					json = buffer.readUTFBytes(header.bodyLength);
				}
				else
				{
					var body:ByteArray = new ByteArray();
					buffer.readBytes(body, 0, header.bodyLength);
					buffer.inflate();
					json = body.readUTFBytes(body.length);
				}
				result.data = JSON.parse(json);
			}
			else
			{
				// 没有得到完整的包，把 position 设回 HeaderSize，就当没读过这个包，以便后期放回缓存
				buffer.position -= PacketHeader.HeaderSize;
			}
			return result;
		}

		public function get size():int
		{
			return header.bodyLength + PacketHeader.HeaderSize;
		}
	}
}
