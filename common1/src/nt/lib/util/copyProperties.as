package nt.lib.util
{
	import nt.lib.inject.IInjectable;
	import nt.lib.reflect.Type;

	public function copyProperties(source:Object, target:Object, byRef:Boolean = false):void
	{
		var properties:Object = Type.of(source).writableProperties;
		for (var name:String in properties)
		{
			var copyValue:* = source[name];
			if (copyValue is IInjectable)
			{
				copyValue.copy(target[name]);
			}
			else
			{
				if (target.hasOwnProperty(name))
				{
					target[name] = (copyValue == null || byRef) ? copyValue : clone(copyValue);
				}
			}
		}
	}
}
