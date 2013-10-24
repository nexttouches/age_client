package
{
	import nt.lib.reflect.Property;
	import nt.lib.reflect.Type;
	import nt.lib.util.assert;
	import org.osflash.signals.ISignal;

	public function checkSignals(... objects):void
	{
		for each (var o:* in objects)
		{
			trace("[CHECK SIGNAL]", o);

			for each (var v:Property in Type.of(o).properties)
			{
				if (o[v.name] is ISignal)
				{
					var n:int = ISignal(o[v.name]).numListeners;
					trace(v.name + " : " + n);
					assert(n == 0);
				}
			}
		}
	}
}
