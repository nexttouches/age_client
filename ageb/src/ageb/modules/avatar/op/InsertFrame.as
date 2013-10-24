package ageb.modules.avatar.op
{
	import spark.components.gridClasses.CellPosition;
	import ageb.modules.ae.ActionInfoEditable;
	import ageb.modules.ae.FrameInfoEditable;
	import ageb.modules.ae.FrameLayerInfoEditable;
	import ageb.modules.document.Document;

	/**
	 * 插入帧
	 * @author zhanghaocong
	 *
	 */
	public class InsertFrame extends InsertFrameBase
	{
		/**
		 * 是否复制属性（结合 isSetAsKeyframe，即为关键帧）
		 */
		private var isCopyProps:Boolean;

		/**
		 *  是否设置为关键帧（即为空白关键帧）
		 */
		private var isSetAsKeyframe:Boolean;

		/**
		 * 创建一个新的 InsertFrame
		 * @param doc 目标文档
		 * @param info 修改的动作
		 * @param cells 当前选中的网格
		 * @param isSetAsKeyframe 是否设置为关键帧（即为空白关键帧）
		 * @param isCopyProps 是否复制属性（结合 isSetAsKeyframe，即为关键帧）
		 *
		 */
		public function InsertFrame(doc:Document, info:ActionInfoEditable, cells:Vector.<CellPosition>, isSetAsKeyframe:Boolean, isCopyProps:Boolean)
		{
			super(doc, info, cells);
			this.isSetAsKeyframe = isSetAsKeyframe;
			this.isCopyProps = isCopyProps;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function redo():void
		{
			var i:int, n:int, layer:FrameLayerInfoEditable;
			var numFrames:int = oldNumFrames;
			n = cells.length

			// 插入帧
			for (i = 0; i < n; i++)
			{
				const rowIndex:int = cells[i].rowIndex;
				const columnIndex:int = cells[i].columnIndex;
				// 要插入的帧
				var newFrame:FrameInfoEditable = new FrameInfoEditable()
				layer = info.getLayerAt(rowIndex);

				// 插入位置超过了帧长度，需要补齐前面的帧
				// 该操作属追加
				if (layer.numFrames <= columnIndex)
				{
					while (layer.numFrames < columnIndex)
					{
						layer.addFrame(new FrameInfoEditable());
					}
					layer.addFrameAt(newFrame, columnIndex);
				}
				// 插入位置在帧内部
				else
				{
					if (isSetAsKeyframe)
					{
						if (layer.getFrameInfoAt(columnIndex).isKeyframe)
						{
							// 本来就是关键帧，不需改动
							continue;
						}
						// 替换我们新创建的帧
						layer.replaceFrameAt(newFrame, columnIndex);
					}
					else
					{
						// 此时才创建要插入的帧
						newFrame = new FrameInfoEditable();
						// 总是在当前帧后插入普通帧
						layer.addFrameAt(newFrame, columnIndex + 1);
					}
				}

				// 如果选择的是插入关键帧
				// 这里需要拷贝一些数据
				if (isSetAsKeyframe)
				{
					if (isCopyProps && newFrame.index > 0)
					{
						newFrame.texture = newFrame.prevKeyFrame.texture;

						if (newFrame.prevKeyFrame.box)
						{
							newFrame.box = newFrame.prevKeyFrame.box.clone1();
						}
					}
					newFrame.isKeyframe = true;
				}
				// 第一帧强制设置为关键帧
				else if (newFrame.index == 0 && !newFrame.isKeyframe)
				{
					newFrame.isKeyframe = true;
				}
			}
			// 提示变更了的图层
			n = insertPositions.length;

			for (i = 0; i < n; i++)
			{
				layer = info.getLayerAt(insertPositions[i].rowIndex);
				layer.notifyFramesChange();

				// 修改后的图层帧长度
				if (layer.numFrames > numFrames)
				{
					numFrames = layer.numFrames;
				}
			}
			info.numFrames = numFrames;
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function get name():String
		{
			if (isSetAsKeyframe)
			{
				if (isCopyProps)
				{
					return "插入关键帧";
				}
				return "插入空白关键帧";
			}
			return "插入帧";
		}
	}
}
