package nt.lib.socket
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import nt.lib.util.NativeMappedSignalSet;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.sets.SocketSignalSet;

	public class Connection extends Socket
	{
		private var buffer:ByteArray;

		private var cachedBuffer:ByteArray;

		private var _signals:NativeMappedSignalSet;

		protected function get signals():NativeMappedSignalSet
		{
			return _signals ||= new NativeMappedSignalSet(this);
		}

		private var _onPacket:ISignal;

		public function get onPacket():ISignal
		{
			return _onPacket ||= new Signal(Connection, Packet);
		}

		public function get onConnect():ISignal
		{
			return signals.getNativeMappedSignal(Event.CONNECT);
		}

		public function get onClose():ISignal
		{
			return signals.getNativeMappedSignal(Event.CLOSE);
		}

		public function get onIOError():ISignal
		{
			return signals.getNativeMappedSignal(IOErrorEvent.IO_ERROR, IOErrorEvent);
		}

		public function get onSecurityError():ISignal
		{
			return signals.getNativeMappedSignal(SecurityErrorEvent.SECURITY_ERROR, SecurityErrorEvent);
		}

		public function Connection()
		{
			super();
			addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
			endian = PacketHeader.Endian;
			buffer = new ByteArray;
			cachedBuffer = new ByteArray;
		}

		protected function socketDataHandler(event:ProgressEvent):void
		{
			readBytes(buffer, 0, event.bytesLoaded);
			parse();
		}

		private function parse():void
		{
			buffer.position = 0;

			while (true)
			{
				var remain:int = buffer.length - buffer.position; // 剩余字节数

				if (remain > PacketHeader.HeaderSize) // 至少有一个 header 的长度 +1，才算有效数据
				{
					var p:Packet = Packet.parse(buffer);

					if (p)
					{
						if (_onPacket)
						{
							_onPacket.dispatch(p);
						}
						trace("receive " + p.size + " bytes: " + JSON.stringify(p.data));
					}
					else
					{
						break;
					}
				}
				else
				{
					break;
				}
			}

			// 还有其他数据，考虑清空 buffer 后再放回去，使用 cachedBuff 作为暂存
			if (remain > 0)
			{
				buffer.readBytes(cachedBuffer); // 把剩余字节全部读进 cachedBuffer
			}
			buffer.clear();

			if (cachedBuffer.bytesAvailable > 0) // 确认有暂存数据，可以放回去
			{
				buffer.writeBytes(cachedBuffer);
				cachedBuffer.clear();
			}
		}

		public function send(packet:Packet):void
		{
			var buffer:ByteArray = packet.buffer;
			writeBytes(buffer);
			flush();
			trace("sent " + packet.size + " bytes: " + JSON.stringify(packet.data));
		}
	}
}
