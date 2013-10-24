package nt.lib.serialization.nml
{

	public class NML
	{
		private static var encoder:Encoder;

		private static var decoder:Decoder;

		internal static const Delimiter:String = ":";

		internal static const Terminator:String = "\r";

		public static function decode(input:String):Object
		{
			if (!decoder)
			{
				decoder = new Decoder();
			}
			return decoder.decode(input);
		}

		public static function encode(input:Object):String
		{
			if (!encoder)
			{
				encoder = new Encoder();
			}
			return encoder.encode(input);
		}
	}
}
