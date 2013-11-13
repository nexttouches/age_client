package ageb.modules.avatar.op
{
	import spark.components.gridClasses.CellPosition;
	import ageb.modules.ae.ActionInfoEditable;
	import ageb.modules.ae.FrameLayerInfoEditable;
	import ageb.modules.document.Document;

	/**
	 * 删除帧
	 * @author zhanghaocong
	 *
	 */
	public class RemoveFrame extends InsertFrameBase
	{
		/**
		 * constructor
		 * @param doc
		 * @param info
		 * @param cells
		 *
		 */
		public function RemoveFrame(doc:Document, info:ActionInfoEditable, cells:Vector.<CellPosition>)
		{
			super(doc, info, cells);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function redo():void
		{
			var i:int, n:int, layer:FrameLayerInfoEditable;

			// 遍历所有 CellPosition，进行删除操作
			for (i = cells.length - 1; i >= 0; i--)
			{
				const rowIndex:int = cells[i].rowIndex;
				const columnIndex:int = cells[i].columnIndex;
				layer = info.getLayerAt(rowIndex);
				layer.removeFrameAt(columnIndex);
			}
			// 提示变更了的图层
			n = insertPositions.length;

			for (i = 0; i < n; i++)
			{
				layer = info.getLayerAt(insertPositions[i].rowIndex);
				layer.notifyFramesChange();
			}
			info.updateNumFrames();
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function get name():String
		{
			return "删除帧";
		}
	}
}
