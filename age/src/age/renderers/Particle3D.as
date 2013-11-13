package age.renderers
{
	import starling.extensions.ColorArgb;
	import starling.extensions.Particle;

	/**
	 * 粒子
	 * @author zhanghaocong
	 *
	 */
	public class Particle3D extends Particle
	{
		public var colorArgb:ColorArgb = new ColorArgb();

		public var colorArgbDelta:ColorArgb = new ColorArgb();;

		public var startX:Number, startY:Number;

		public var velocityX:Number, velocityY:Number

		public var radialAcceleration:Number;

		public var tangentialAcceleration:Number;

		public var emitRadius:Number, emitRadiusDelta:Number;

		public var emitRotation:Number, emitRotationDelta:Number;

		public var rotationDelta:Number;

		public var scaleDelta:Number;

		/**
		 * 该值总是为 0
		 */
		public var z:Number = 0;

		public function Particle3D()
		{
		}
	}
}
