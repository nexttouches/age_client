package nt.lib.log
{

	public interface ILogger
	{
		function debug(... args):void;
		function info(... args):void;
		function error(... args):void;
	}
}
