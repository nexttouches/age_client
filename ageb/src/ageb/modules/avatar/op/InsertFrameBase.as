package ageb.modules.avatar.op
{
	import spark.components.gridClasses.CellPosition;
	import ageb.modules.ae.ActionInfoEditable;
	import ageb.modules.ae.FrameLayerInfoEditable;
	import ageb.modules.document.Document;

	/**
	 * 帧添加删除的的基类<br>
	 * 实现了了公用的撤销方法
	 * @author zhanghaocong
	 *
	 */
	internal class InsertFrameBase extends AvatarOPBase
	{
		/**
		 * 变更前帧数
		 */
		protected var oldNumFrames:int;

		/**
		 * 变更前图层，key 为图层索引
		 */
		protected var oldLayers:Object = {};

		/**
		 * 变更了的图层和插入起始点
		 */
		protected var insertPositions:Vector.<CellPosition> = new Vector.<CellPosition>;;

		/**
		 * 当前选中的网格
		 */
		protected var cells:Vector.<CellPosition>;

		/**
		 * 修改的动作
		 */
		protected var info:ActionInfoEditable;

		/**
		 * 旧的当前帧
		 */
		private var oldCurrentFrame:int;

		/**
		 * constructor
		 * @param doc
		 * @param info
		 * @param cells
		 *
		 */
		public function InsertFrameBase(doc:Document, info:ActionInfoEditable, cells:Vector.<CellPosition>)
		{
			super(doc);
			this.info = info;
			this.cells = cells;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function saveOld():void
		{
			var i:int, n:int, cp:CellPosition, lastCP:CellPosition, layer:FrameLayerInfoEditable;
			// 统计 insertPositions
			n = cells.length;

			for (i = 0; i < n; i++)
			{
				cp = cells[i];

				if (!lastCP || cp.rowIndex != lastCP.rowIndex)
				{
					insertPositions.push(cp);
				}
				lastCP = cp;
			}
			// 记录变更前当前帧
			oldCurrentFrame = object.currentFrame;
			// 记录变更前帧数
			oldNumFrames = info.numFrames;
			// 记录变更前图层的帧
			n = insertPositions.length;

			for (i = 0; i < n; i++)
			{
				oldLayers[insertPositions[i].rowIndex] = info.getLayerAt(insertPositions[i].rowIndex).frames.concat();
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function undo():void
		{
			for (var key:String in oldLayers)
			{
				const layer:FrameLayerInfoEditable = info.getLayerAt(int(key));
				layer.setFrames(oldLayers[key]);
			}
			info.numFrames = oldNumFrames;
			object.currentFrame = oldCurrentFrame;
		}
	}
}
