package nt.lib.util
{
	import flash.system.Capabilities;

	[Inline]
	public function assert(b:Boolean, m:String = "", errorClass:Class = null):void
	{
		if (Capabilities.isDebugger)
		{
			if (!b)
			{
				throw new (errorClass ||= Error)(m);
			}
		}
	}
}
