package
{

	public class formatalias
	{
		private static var aliases:Object = {};

		public static function register(alias:String, o:*):void
		{
			aliases[alias] = o;
		}

		public static function get(alias:String):*
		{
			return aliases[alias];
		}
	}
}
