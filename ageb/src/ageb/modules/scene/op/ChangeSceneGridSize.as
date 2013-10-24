package ageb.modules.scene.op
{
	import ageb.modules.document.Document;

	public class ChangeSceneGridSize extends SceneOPBase
	{
		public var gridWidth:Number;

		public var gridHeight:Number;

		public var oldGridWidth:Number;

		public var oldGridHeight:Number;

		public var oldGrids:Array;

		public function ChangeSceneGridSize(doc:Document, gridWidth:Number, gridHeight:Number)
		{
			super(doc);
			this.gridWidth = gridWidth;
			this.gridHeight = gridHeight;
		}

		override protected function saveOld():void
		{
			oldGrids = doc.info.grids;
			oldGridWidth = doc.info.gridWidth;
			oldGridHeight = doc.info.gridHeight;
		}

		override public function redo():void
		{
			doc.info.setGridSize(gridWidth, gridHeight);
		}

		override public function undo():void
		{
			doc.info.setGridSize(oldGridWidth, oldGridHeight, oldGrids);
		}

		override public function get name():String
		{
			return format("修改网格大小 ({gridWidth}×{gridHeight})", this);
		}
	}
}
