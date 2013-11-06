package ageb.modules.ae
{
	import age.data.FrameInfo;
	import age.data.FrameLayerInfo;
	import age.renderers.WireframeLayerRenderer;

	/**
	 * WireframeLayerRendererEditable
	 * @author zhanghaocong
	 *
	 */
	public class WireframeLayerRendererEditable extends WireframeLayerRenderer
	{
		/**
		 * constructor
		 *
		 */
		public function WireframeLayerRendererEditable()
		{
			super();
		}

		/**
		 * 当前渲染关键帧的 FrameInfoEditable 形态
		 * @return
		 *
		 */
		protected function get frameInfoEditable():FrameInfoEditable
		{
			return frameInfo ? frameInfo.keyframe as FrameInfoEditable : null;
		}

		/**
		 * @inheritDoc
		 * @param value
		 *
		 */
		override public function set frameInfo(value:FrameInfo):void
		{
			if (frameInfoEditable)
			{
				frameInfoEditable.onBoxChange.remove(validate);
			}
			super.frameInfo = value;

			if (frameInfoEditable)
			{
				frameInfoEditable.onBoxChange.add(validate);
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
		 * @inheritDoc
		 * @param value
		 *
		 */
		override public function set info(value:FrameLayerInfo):void
		{
			if (infoEditable)
			{
				infoEditable.onFramesChange.remove(onFramesChange);
			}
			super.info = value;

			if (infoEditable)
			{
				infoEditable.onFramesChange.add(onFramesChange);
			}
		}

		/**
		 * 图层的 frames 变化后，需要重新设置 frameInfo
		 *
		 */
		private function onFramesChange(layer:FrameLayerInfoEditable):void
		{
			currentFrame = currentFrame;
		}
	}
}
