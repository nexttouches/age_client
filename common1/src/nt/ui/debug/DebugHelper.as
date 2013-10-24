package nt.ui.debug
{

	public class DebugHelper
	{
		private static var _showOutline:Boolean = false;

		public static function get showOutline():Boolean
		{
			return _showOutline;
		}

		public static function set showOutline(value:Boolean):void
		{
			if (value != _showOutline)
			{
				_showOutline = value;
			}
		}
	}
}
