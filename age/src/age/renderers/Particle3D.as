package age.renderers
{
	import starling.extensions.ColorArgb;

	/**
	 * 单个粒子
	 * @author zhanghaocong
	 *
	 */
	public class Particle3D
	{
		public var x:Number = 0;

		public var y:Number = 0;

		public var scale:Number = 1;

		public var rotation:Number = 0;

		public var color:uint = 0xffffff;

		public var alpha:Number = 1;

		public var currentTime:Number = 0;

		public var totalTime:Number = 0;

		public var colorArgb:ColorArgb = new ColorArgb();

		public var colorArgbDelta:ColorArgb = new ColorArgb();

		public var startX:Number, startY:Number;

		public var velocityX:Number, velocityY:Number

		public var radialAcceleration:Number;

		public var tangentialAcceleration:Number;

		public var emitRadius:Number, emitRadiusDelta:Number;

		public var emitRotation:Number, emitRotationDelta:Number;

		public var rotationDelta:Number;

		public var scaleDelta:Number;

		public function Particle3D()
		{
		}
	}
}
