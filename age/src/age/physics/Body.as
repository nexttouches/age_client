package age.physics
{
	import flash.geom.Rectangle;

	public class Body extends Rectangle
	{
		public var vx:Number = 0;

		public var vy:Number = 0;

		public var ax:Number = 0;

		public var ay:Number = 0;

		/**
		 * 质量，数值越大，掉落速度越快<br>
		 * 为 0 时，将不受重力控制
		 */
		public var mass:Number = 0;

		/**
		 * 弹性，一般用在落地后的反弹力上
		 */
		public var elasticity:Number = 0.3;

		public function get middleX():Number
		{
			return halfWidth + x;
		}

		public function get middleY():Number
		{
			return halfHeight + y;
		}

		public var halfWidth:Number;

		public var halfHeight:Number;

		/**
		 * 是否是表面<br>
		 * 在我们的引擎里，表面是指可以站立的表面<br>
		 * 默认值为 false
		 */
		public var isSurface:Boolean = false;

		public function Body()
		{
		}

		/**
		 * 得到一个 Collision 对象
		 * @param body
		 * @return
		 *
		 */
		public function getCollision(body:Body):Collision
		{
			if (intersects(body))
			{
				var rect:Rectangle = new Rectangle();
				rect.x = (x > body.x) ? x : body.x;
				rect.y = (y > body.y) ? y : body.y;
				rect.width = ((x + width) < (body.x + body.width) ? (x + width) : (body.x + body.width)) - rect.x;
				rect.height = ((y + height) < (body.y + body.height) ? (y + height) : (body.y + body.height)) - rect.y;

				if (rect.width < 0 || rect.height < 0)
				{
					rect.width = rect.height = 0;
				}
				return new Collision(this, body, rect.x + rect.width / 2, rect.y + rect.height / 2);
			}
			return null;
		}
	}
}
