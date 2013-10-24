package
{
	import flash.external.ExternalInterface;

	public function browserlog(template:String, ... args):void
	{
		p[0] = template;
		p.push.apply(null, args);

		if (ExternalInterface.available)
		{
			ExternalInterface.call("console.log", format.apply(null, p));
		}
		else
		{
			traceex.apply(null, p);
		}
		p.length = 0;
	}
}

var p:Array = [];
