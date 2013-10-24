package ageb.modules.scene.op
{
	import ageb.modules.ae.RegionInfoEditable;
	import ageb.modules.document.Document;

	/**
	 * 增加区域
	 * @author zhanghaocong
	 *
	 */
	public class AddRegion extends SceneOPBase
	{
		public var x:Number;

		public var region:RegionInfoEditable;

		public function AddRegion(doc:Document, x:Number)
		{
			super(doc);
			this.x = x;
		}

		override public function redo():void
		{
			doc.info.addRegion(region);
		}

		override protected function saveOld():void
		{
			region = new RegionInfoEditable();
			region.x = x;
			region.width = 100;
			region.depth = doc.info.depth;
			region.id = doc.info.getNextRegionID();
		}

		override public function undo():void
		{
			doc.info.removeRegion(region);
		}

		override public function get name():String
		{
			return format("创建新区域 ({x})", this);
		}
	}
}
