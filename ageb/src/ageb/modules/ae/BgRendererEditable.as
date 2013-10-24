package ageb.modules.ae
{
	import age.assets.BGInfo;
	import age.renderers.BGRenderer;

	public class BgRendererEditable extends BGRenderer implements ISelectableRenderer
	{
		public function BgRendererEditable()
		{
			super();
			touchable = true;
		}

		override public function set info(value:BGInfo):void
		{
			if (infoEditable)
			{
				infoEditable.onIsDraggingChange.remove(onIsDraggingChange);
				infoEditable.onPositionChange.remove(onXYChange);
				infoEditable.onIsSelectedChange.remove(onIsSelectedChange);
				infoEditable.onIsFlipXChange.remove(onIsFlipXChange);
				infoEditable.onIsFlipYChange.remove(onIsFlipYChange);
			}
			super.info = value;

			if (infoEditable)
			{
				infoEditable.onIsDraggingChange.add(onIsDraggingChange);
				infoEditable.onPositionChange.add(onXYChange);
				infoEditable.onIsSelectedChange.add(onIsSelectedChange);
				infoEditable.onIsFlipXChange.add(onIsFlipXChange);
				infoEditable.onIsFlipYChange.add(onIsFlipYChange);
				onIsSelectedChange();
				originAlpha = alpha;
			}
		}

		private var originAlpha:Number;

		private function onIsDraggingChange():void
		{
			super.alpha = originAlpha * (selectableInfo.isDragging ? 0.5 : 1);
		}

		override public function set alpha(value:Number):void
		{
			super.alpha = value;
			originAlpha = value;
		}

		private function onXYChange():void
		{
			x = _info.x;
			y = _info.y;
			z = _info.z;
		}

		private function onIsFlipXChange():void
		{
			isFlipX = info.isFlipX;
		}

		private function onIsFlipYChange():void
		{
			isFlipY = info.isFlipY;
		}

		private function onIsSelectedChange():void
		{
			if (infoEditable.isSelected)
			{
				color = 0x00ffcc;
			}
			else
			{
				color = 0xffffff;
			}
		}

		final protected function get infoEditable():BGInfoEditable
		{
			return _info as BGInfoEditable;
		}

		final public function get selectableInfo():ISelectableInfo
		{
			return _info as ISelectableInfo;
		}
	}
}
