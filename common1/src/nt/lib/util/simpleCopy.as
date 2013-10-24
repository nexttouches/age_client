package nt.lib.util
{
	import nt.lib.reflect.Type;

	/**
	 * 复制
	 */
	public function simpleCopy(source:Object, target:Object):void
	{
		if (!source || !target)
		{
			return;
		}
		var key:String;
		for (key in source)
		{
			target[key] = source[key];
		}
		if (source.constructor != Object)
		{
			var properties:Object = Type.of(target).writableProperties;
			for (key in properties)
			{
				target[key] = source[key];
			}
		}
	}
}
