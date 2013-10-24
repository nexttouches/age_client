package nt.lib.log
{

	public class SimpleLogger implements ILogger
	{
		private var classShortName:String;

		private var target:ILogTarget;

		public function SimpleLogger(target:ILogTarget, classShortName:String)
		{
			this.target = target;
			this.classShortName = classShortName;
		}

		public function debug(... args):void
		{
			log(args, LogLevel.DEBUG);
		}

		public function info(... args):void
		{
			log(args, LogLevel.INFO);
		}

		public function error(... args):void
		{
			log(args, LogLevel.ERROR);
		}

		private function log(args:Array, level:int):void
		{
			var str:String = format.apply(null, args)
			target.log("[" + classShortName + "]" + str, level);
		}
	}
}
