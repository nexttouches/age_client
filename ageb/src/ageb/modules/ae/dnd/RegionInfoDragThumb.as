package ageb.modules.ae.dnd
{
	import age.renderers.RegionInfoRenderer;
	import ageb.modules.ae.roundTo;
	import starling.display.DisplayObject;

	public class RegionInfoDragThumb extends RegionInfoRenderer implements IDragThumb
	{
		public function RegionInfoDragThumb()
		{
			super();
		}

		public function setSource(s:DisplayObject):void
		{
			info = RegionInfoRenderer(s).info;
			color = 0x00ff00;
		}

		public function offset(x:Number, y:Number, snapX:Number = 1, snapY:Number = 1):void
		{
			this.x = roundTo(x + info.x, snapX);
		}

		public function get displayObject():DisplayObject
		{
			return this;
		}
	}
}
