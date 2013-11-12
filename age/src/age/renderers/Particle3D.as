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

		public var velocityX:Number, velocityY:Number, velocityZ:Number;

		public var radialAcceleration:Number;

		public var tangentialAcceleration:Number;

		public var emitRadius:Number, emitRadiusDelta:Number;

		public var emitRotation:Number, emitRotationDelta:Number;

		public var rotationDelta:Number;

		public var scaleDelta:Number;

		public var z:Number;

		public function Particle3D()
		{
		}
	}
}
