package ageb.modules.scene.op
{
	import ageb.modules.document.Document;

	/**
	 * ChangeSceneGridCell 修改网格操作
	 * @author zhanghaocong
	 *
	 */
	public class ChangeSceneGridCell extends SceneOPBase
	{
		public var x:int;

		public var y:int;

		public var value:int;

		public var oldValue:int;

		public function ChangeSceneGridCell(doc:Document, x:int, y:int, value:int)
		{
			super(doc);
			this.x = x;
			this.y = y;
			this.value = value;
		}

		override protected function saveOld():void
		{
			oldValue = doc.info.getGridCell(x, y);
		}

		override public function redo():void
		{
			doc.info.setGridCell(x, y, value);
		}

		override public function undo():void
		{
			doc.info.setGridCell(x, y, oldValue);
		}

		override public function get name():String
		{
			return format("修改网格 ({x},{y}) 到 ({value})", this)
		}
	}
}
