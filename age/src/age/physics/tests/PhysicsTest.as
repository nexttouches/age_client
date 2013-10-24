package age.physics.tests
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import age.AGE;
	import age.physics.Body;
	import age.physics.World;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class PhysicsTest extends Sprite
	{
		private var world:World = new World(new Point(0, 9.8));

		private var shape:Shape = new Shape();

		public function PhysicsTest()
		{
			super();
			var mapWidth:int = 3000;
			var n:int = 11;

			for (var i:int = 0; i < n; i++)
			{
				addRect(Math.random() * (800 - 100), 400 + Math.random() * 400 - 50 - 100, 100, 100, 150).isSurface = false;
			}
			addRect(0, 800 - 50, 3000, 50, 0).isSurface = true;
			AGE.s.juggler.add(world);
			AGE.s.nativeStage.addEventListener(MouseEvent.CLICK, onClick);
			AGE.s.nativeStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			AGE.s.nativeStage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			AGE.s.nativeStage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			shape = new Shape();
			shape.graphics.beginFill(0);
			AGE.s.nativeStage.addChild(shape);
		}

		protected function onEnterFrame(event:Event):void
		{
			var b:Body = world.bodies[0];
			b.elasticity = 0.5;
			b.mass = 130;

			if (isKeyDown(Keyboard.W))
			{
				b.vy = -400;
			}

			if (isKeyDown(Keyboard.A))
			{
				b.vx = -400;
			}
			else if (isKeyDown(Keyboard.D))
			{
				b.vx = 400;
			}
			else
			{
			}
			//shape.graphics.drawCircle(b.middleX, b.middleY, 1);
		}

		private var keyDownList:Object = {};

		private function isKeyDown(keyCode:uint):Boolean
		{
			return keyDownList[keyCode] == true;
		}

		protected function onKeyUp(event:KeyboardEvent):void
		{
			keyDownList[event.keyCode] = false;
		}

		protected function onKeyDown(event:KeyboardEvent):void
		{
			keyDownList[event.keyCode] = true;
		}

		protected function onClick(event:MouseEvent):void
		{
			// addRect(AE.s.nativeStage.mouseX, AE.s.nativeStage.mouseY, 100, 100, 200);
		}

		public function addRect(x:Number, y:Number, width:Number, height:Number, mass:Number):Body
		{
			var b:Body = new Body();
			b.x = x;
			b.y = y;
			b.width = width;
			b.halfWidth = width / 2;
			b.height = height;
			b.halfHeight = height / 2;
			b.mass = mass;
			world.addBody(b);
			var br:BodyRenderer = new BodyRenderer();
			br.body = b;
			addChild(br);
			return b;
		}
	}
}
