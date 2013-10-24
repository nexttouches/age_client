package age.renderers
{
	import age.AGE;

	/**
	 * 抖动的辅助类
	 * @author zhanghaocong
	 *
	 */
	public class CameraShake
	{
		public var intensity:Number;

		public var numFrames:int;

		private var decay:Number;

		public function CameraShake(intensity:Number, numFrames:int)
		{
			this.intensity = intensity;
			this.numFrames = numFrames;
			decay = intensity / numFrames;
		}

		/**
		 * 执行下一帧抖动
		 * @return 是否已抖动完毕
		 *
		 */
		public function nextFrame(camera:Camera2D):Boolean
		{
			if (numFrames > 0)
			{
				numFrames--;

				if (numFrames <= 0)
				{
					camera.scene.x = camera.scene.y = 0;
					numFrames = 0;
					return false;
				}
				else
				{
					intensity -= decay;
					camera.scene.x = int(Math.random() * intensity * AGE.s.stage.stageWidth * 2 - intensity * AGE.s.stage.stageWidth);
					camera.scene.y = int(Math.random() * intensity * AGE.s.stage.stageHeight * 2 - intensity * AGE.s.stage.stageHeight);
					return true;
				}
			}
			return false
		}
	}
}
