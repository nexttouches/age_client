package nt.lib.log
{

	public class TraceTarget implements ILogTarget
	{
		public function log(str:String, level:int):void
		{
			trace(format("[{0}]{1}", formatLevel(level), str));
		}

		private function formatLevel(level:int):String
		{
			switch (level)
			{
				case LogLevel.DEBUG:
				{
					return "debug";
				}
				case LogLevel.INFO:
				{
					return "info";
				}
				case LogLevel.ERROR:
				{
					return "error";
				}

				default:
				{
					return "default";
				}
			}
		}
	}
}
