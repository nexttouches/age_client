package age
{
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import starling.core.Starling;

	internal class Engine extends Starling
	{
		public var now:Number;

		protected var lastFrameTimestamp:Number;

		public function Engine(rootClass:Class, stage:Stage, viewPort:Rectangle = null, stage3D:Stage3D = null, renderMode:String = "auto", profile:String = "baselineConstrained")
		{
			super(rootClass, stage, viewPort, stage3D, renderMode, profile);
			lastFrameTimestamp = getTimer() / 1000.0;
		}

		override public function nextFrame():void
		{
			var now:Number = getTimer() / 1000.0;
			var passedTime:Number = now - lastFrameTimestamp;
			lastFrameTimestamp = now;
			advanceTime(passedTime);
			render();
		}
	}
}
