package ageb.modules.ae
{
	import age.data.FrameLayerInfo;
	import age.renderers.AnimationLayerRenderer;
	import nt.assets.Asset;

	public class AnimationLayerRendererEditable extends AnimationLayerRenderer
	{
		public function AnimationLayerRendererEditable()
		{
			super();
		}

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

			if (value)
			{
				for each (var a:Asset in value.assets)
				{
					SyncInfoLoader.loadAtlasConfig(a.path);
				}
			}

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
