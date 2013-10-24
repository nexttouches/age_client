package nt.lib.util
{
	public function callLater(closure:Function, ... args):void
	{
		CallLaterImpl.add(closure, args);
	}
}
import flash.display.Sprite;
import flash.events.Event;

class Invoke
{
	private var closure:Function;

	private var args:Array;

	public function Invoke(closure:Function, args:Array = null)
	{
		this.closure = closure;
		this.args = args;
	}

	public function execute():void
	{
		closure.apply(null, args);
	}
}

class CallLaterImpl
{
	public function CallLaterImpl()
	{
	}

	private static var host:Sprite = new Sprite();

	private static var queue:Vector.<Invoke> = new Vector.<Invoke>();

	public static function add(closure:Function, args:Array = null):void
	{
		queue.push(new Invoke(closure, args));
		host.addEventListener(Event.ENTER_FRAME, processCallLater);
	}

	private static function processCallLater(e:Event):void
	{
		host.removeEventListener(e.type, arguments.callee);

		while (queue.length > 0)
		{
			queue.shift().execute();
		}
	}
}
