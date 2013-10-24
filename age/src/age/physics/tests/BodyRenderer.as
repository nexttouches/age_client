package age.physics.tests
{
	import age.AGE;
	import age.physics.Body;
	import starling.animation.IAnimatable;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class BodyRenderer extends Quad implements IAnimatable
	{
		public function BodyRenderer()
		{
			super(1, 1, Math.random() * 0xffffffff);
			addEventListener(Event.ADDED_TO_STAGE, onAdd);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			addEventListener(TouchEvent.TOUCH, onTouch);
			touchable = true;
		}

		private function onTouch(event:TouchEvent):void
		{
			if (event.getTouch(this, TouchPhase.BEGAN))
			{
				body.vy -= 600;
				body.vx = 100;
			}
		}

		private function onRemove():void
		{
			AGE.s.juggler.remove(this);
		}

		private function onAdd():void
		{
			AGE.s.juggler.add(this);
		}

		public var body:Body;

		public function advanceTime(time:Number):void
		{
			x = body.x;
			y = body.y;
			width = body.width;
			height = body.height;
		}
	}
}
