package ageb.modules.ae
{
	import age.assets.FrameLayerInfo;
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
				info.onTexturesChange.remove(onTexturesChange);
			}
		}

		private function onTexturesChange():void
		{
			// 强制刷新一下当前贴图
			currentFrame = currentFrame;
		}
	}
}
