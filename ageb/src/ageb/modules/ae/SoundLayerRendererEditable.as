package ageb.modules.ae
{
	import age.data.FrameLayerInfo;
	import age.renderers.SoundLayerRenderer;

	/**
	 * SoundLayerRendererEditable
	 * @author zhanghaocong
	 *
	 */
	public class SoundLayerRendererEditable extends SoundLayerRenderer
	{
		/**
		 * constructor
		 *
		 */
		public function SoundLayerRendererEditable()
		{
			super();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function set info(value:FrameLayerInfo):void
		{
			if (info)
			{
				info.onSoundsChange.remove(onSoundsChange);
			}
			super.info = value;

			if (info)
			{
				info.onSoundsChange.remove(onSoundsChange);
			}
		}

		/**
		 * constructor
		 *
		 */
		private function onSoundsChange():void
		{
			info_isComplete = info.isComplete && info.sounds != null;
			// 强制播一下
			currentFrame = currentFrame;
		}
	}
}
