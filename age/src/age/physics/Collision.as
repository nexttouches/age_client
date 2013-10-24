package age.physics
{
	import flash.geom.Point;

	/**
	 * 表示一个碰撞
	 * @author zhanghaocong
	 *
	 */
	public class Collision extends Point
	{
		public var a:Body;

		public var b:Body;

		/**
		 * 创建一个新的碰撞
		 * @param a 对象 A
		 * @param b 对象 B
		 * @param x 碰撞的点，一般是两个 Body 相交区域的中心点 X
		 * @param y 碰撞的点，一般是两个 Body 相交区域的中心点 Y
		 *
		 */
		public function Collision(a:Body, b:Body, x:Number, y:Number)
		{
			super(x, y);
			this.a = a;
			this.b = b;
		}
	}
}
