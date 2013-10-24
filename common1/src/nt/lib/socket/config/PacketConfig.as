package nt.lib.socket.config
{
	import nt.lib.socket.PacketCompression;

	public class PacketConfig
	{
		public static var Version:int = 1;

		public static var Compression:int = PacketCompression.Always;
	}
}
