package age.physics
{
	import flash.display.Shape;
	import flash.geom.Point;
	import age.AGE;
	import starling.animation.IAnimatable;

	public class World implements IAnimatable
	{
		public var bodies:Vector.<Body> = new Vector.<Body>;

		public var g:Point;

		public function World(g:Point)
		{
			this.g = g;
		}

		public function advanceTime(time:Number):void
		{
			var i:int, j:int, a:Body, b:Body, c:Collision, n:int = bodies.length;

			// 计算新位置
			for (i = 0; i < n; i++)
			{
				b = bodies[i];
				b.vx += g.x * time;
				b.vy += (g.y * b.mass) * time;
				b.x += b.vx * time;
				b.y += b.vy * time;
			}
			// 碰撞检测
			var collisions:Vector.<Collision> = new Vector.<Collision>();

			for (i = 0; i < n; i++)
			{
				b = bodies[i];

				for (j = i + 1; j < n; j++)
				{
					c = b.getCollision(bodies[j]);

					if (c)
					{
						collisions.push(c);
					}
				}
			}
			// 碰撞求解
			n = collisions.length;
			const STICKY_THRESHOLD:Number = 0.004;

			for (i = 0; i < n; i++)
			{
				c = collisions[i];
				a = c.a;
				b = c.b;

				//Shape(AE.s.nativeStage.getChildAt(2)).graphics.drawCircle(c.x, c.y, 1);
				if (!a.isSurface && !b.isSurface)
				{
					continue;
				}
				// To find the side of entry calculate based on
				// the normalized sides
				var dx:Number = (b.middleX - a.middleX) / b.halfWidth;
				var dy:Number = (b.middleY - a.middleY) / b.halfHeight;
				// Calculate the absolute change in x and y
				var absDX:Number = Math.abs(dx);
				var absDY:Number = Math.abs(dy);

				// If the distance between the normalized x and y
				// position is less than a small threshold (.1 in this case)
				// then this object is approaching from a corner
				if (Math.abs(absDX - absDY) < .1)
				{
					// If the player is approaching from positive X
					if (dx < 0)
					{
						// Set the player x to the right side
						a.x = b.right;
							// If the player is approaching from negative X
					}
					else
					{
						// Set the player x to the left side
						a.x = b.left - a.width;
					}

					// If the player is approaching from positive Y
					if (dy < 0)
					{
						// Set the player y to the bottom
						a.y = b.bottom;
							// If the player is approaching from negative Y
					}
					else
					{
						// Set the player y to the top
						a.y = b.top - a.height;
					}

					// Randomly select a x/y direction to reflect velocity on
					if (Math.random() < .5)
					{
						// Reflect the velocity at a reduced rate
						a.vx *= a.elasticity;

						// If the object's velocity is nearing 0, set it to 0
						// STICKY_THRESHOLD is set to .0004
						if (Math.abs(a.vx) < STICKY_THRESHOLD)
						{
							a.vx = 0;
						}
					}
					else
					{
						a.vx *= a.elasticity;
						a.vy *= -a.elasticity;

						if (Math.abs(a.vy) < STICKY_THRESHOLD)
						{
							a.vy = 0;
						}
					}
						// If the object is approaching from the sides
				}
				else if (absDX > absDY)
				{
					// If the player is approaching from positive X
					if (dx < 0)
					{
						a.x = b.right;
					}
					else
					{
						// If the player is approaching from negative X
						a.x = b.left - a.width;
					}
					// Velocity component
					a.vx *= a.elasticity;

					if (Math.abs(a.vx) < STICKY_THRESHOLD)
					{
						a.vx = 0;
					}
						// If this collision is coming from the top or bottom more
				}
				else
				{
					// If the player is approaching from positive Y
					if (dy < 0)
					{
						a.y = b.bottom;
					}
					else
					{
						// If the player is approaching from negative Y
						a.y = b.top - a.height;
					}
					// Velocity component
					a.vx *= a.elasticity;
					a.vy = -a.vy * a.elasticity;

					if (Math.abs(a.vy) < STICKY_THRESHOLD)
					{
						a.vy = 0;
					}
				}
			}
		}

		public function addBody(b:Body):void
		{
			bodies.push(b);
		}

		public function removeBody(b:Body):void
		{
			bodies.splice(bodies.indexOf(b), 1);
		}
	}
}
