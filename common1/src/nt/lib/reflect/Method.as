package nt.lib.reflect
{
	import nt.lib.util.Factory;

	public class Method extends Property
	{
		public function Method(name:String, type:Class = null, uri:String = null)
		{
			super(name, type, uri);
		}

		public function invoke(scope:*, args:Array):*
		{
			return scope[name].apply(null, args);
		}
	}
}
