package ageb.modules.ae
{
	import age.data.FrameLayerInfo;
	import age.renderers.AnimationLayerRenderer;
	import nt.assets.Asset;

	/**
	 * AnimationLayerRendererEditable
	 * @author zhanghaocong
	 *
	 */
	public class AnimationLayerRendererEditable extends AnimationLayerRenderer
	{
		/**
		 * constructor
		 *
		 */
		public function AnimationLayerRendererEditable()
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
				info.onTexturesChange.remove(onTexturesChange);
			}

			if (infoEditable)
			{
				infoEditable.getFrameInfoAt(0).onBoxChange.remove(adjustSize);
			}
			super.info = value;

			if (info)
			{
				info.onTexturesChange.add(onTexturesChange);
			}

			if (infoEditable)
			{
				infoEditable.getFrameInfoAt(0).onBoxChange.add(adjustSize);
			}
		}

		/**
		 * @private
		 * @return
		 *
		 */
		protected function get infoEditable():FrameLayerInfoEditable
		{
			return info as FrameLayerInfoEditable;
		}

		/**
		 * @private
		 *
		 */
		private function onTexturesChange():void
		{
			info_isComplete = info.isComplete && info.textures != null;
			// 强制刷新一下当前贴图
			currentFrame = currentFrame;
		}
	}
}
