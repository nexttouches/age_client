package ageb.modules.ae
{
	import flash.geom.Point;
	import age.data.RegionInfo;
	import age.renderers.RegionInfoRenderer;
	import starling.display.DisplayObject;

	public class RegionInfoRendererEditable extends RegionInfoRenderer implements ISelectableRenderer
	{
		public function RegionInfoRendererEditable()
		{
			super();
			touchable = true;
		}

		final public function get selectableInfo():ISelectableInfo
		{
			return _info as ISelectableInfo;
		}

		override public function set info(value:RegionInfo):void
		{
			if (infoEditable)
			{
				infoEditable.onIsDraggingChange.remove(onIsDraggingChange);
				infoEditable.onPositionChange.remove(onXYChange);
				infoEditable.onIsSelectedChange.remove(onIsSelectedChange);
				infoEditable.onWidthChange.remove(onWidthChange);
				infoEditable.onHeightChange.remove(onHeightChange);
			}
			super.info = value;

			if (infoEditable)
			{
				infoEditable.onIsDraggingChange.add(onIsDraggingChange);
				infoEditable.onPositionChange.add(onXYChange);
				infoEditable.onIsSelectedChange.add(onIsSelectedChange);
				infoEditable.onWidthChange.add(onWidthChange);
				infoEditable.onHeightChange.add(onHeightChange);
				onIsSelectedChange();
				originAlpha = alpha;
			}
		}

		private function onHeightChange():void
		{
			splitterV.height = _info.height;
			tf.text = _info.toString();
			flatten();
		}

		private function onWidthChange():void
		{
			splitterH.width = _info.width;
			tf.text = _info.toString();
			flatten();
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
			tf.text = _info.toString();
			splitterH.width = _info.width;
			flatten();
		}

		private function onIsSelectedChange():void
		{
			if (infoEditable.isSelected)
			{
				color = 0x00ff00;
			}
			else
			{
				color = SPLITTER_COLOR;
			}
			flatten();
		}

		protected function get infoEditable():RegionInfoEditable
		{
			return info as RegionInfoEditable;
		}

		override public function hitTest(localPoint:Point, forTouch:Boolean = false):DisplayObject
		{
			if (super.hitTest(localPoint, forTouch))
			{
				return this;
			}
			return null;
		}
	}
}
