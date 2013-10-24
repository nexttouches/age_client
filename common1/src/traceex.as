package
{
	import flash.system.Capabilities;

	/**
	 * 带格式化的 trace
	 */
	[Inline]
	public function traceex(... args):void
	{
		if (Capabilities.isDebugger)
		{
			trace(format.apply(null, args));
		}
	}
}
