package ageb.modules.avatar.op
{
	import mx.core.mx_internal;
	import age.data.FrameLayerInfo;
	import ageb.modules.avatar.timelineClasses.FrameLayerList;
	import ageb.modules.document.Document;

	/**
	 * 拖拽重新排序图层操作
	 * @author zhanghaocong
	 *
	 */
	public class DragReorderFrameLayerOP extends AvatarOPBase
	{
		/**
		 * 下落位置
		 */
		public var dropIndex:int;

		/**
		 * 焦点
		 */
		public var caretIndex:int;

		/**
		 * 要重新排序的项
		 */
		public var items:Vector.<Object>;

		/**
		 * 可选的参数有 DragManager.MOVE 和 DragManager.COPY<br>
		 * 暂不支持 COPY
		 */
		public var dragAction:String;

		/**
		 * 表示由哪个列表控件触发
		 */
		public var dragInitiator:FrameLayerList;

		/**
		 * 旧选中索引项
		 */
		public var oldSelections:Vector.<int>;

		/**
		 * 旧数据源中的内容
		 */
		public var oldSource:Vector.<FrameLayerInfo>;

		/**
		 * 新数据源中的内容<br>
		 * 首次执行 redo 后将记录修改后的列表到该值，然后下次 redo 的时候采用直接覆盖数组的方法
		 */
		public var newSource:Vector.<FrameLayerInfo>;

		/**
		 * 新的选中项索引
		 */
		public var newSelections:Vector.<int>;

		/**
		 * 拖拽排序帧图层操作
		 * @param doc
		 * @param dropIndex
		 * @param caretIndex
		 * @param items
		 * @param action
		 * @param dragInitiator
		 *
		 */
		public function DragReorderFrameLayerOP(doc:Document, dropIndex:int, caretIndex:int, items:Vector.<Object>, action:String, dragInitiator:FrameLayerList = null)
		{
			super(doc);
			this.dropIndex = dropIndex;
			this.caretIndex = caretIndex;
			this.items = items;
			this.dragAction = action;
			this.dragInitiator = dragInitiator;
		}

		/**
		* @inheritDoc
		*
		*/
		override public function redo():void
		{
			dragInitiator.reorder(dropIndex, caretIndex, items, dragAction, dragInitiator);

			// 卷动到焦点
			if (caretIndex != -1)
			{
				dragInitiator.scrollTo(dropIndex + caretIndex);
			}

			// 提示所有渲染器索引已变化
			for (var i:int = 0; i < action.layers.length; i++)
			{
				action.getLayerAt(i).onIndexChange.dispatch();
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function saveOld():void
		{
			oldSelections = dragInitiator.selectedIndices.concat();
			oldSource = action.layers.concat();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function undo():void
		{
			// 恢复 source
			dragInitiator.mx_internal::setSelectedIndices(new Vector.<int>());
			dragInitiator.validateProperties();
			action.setLayers(oldSource);
			dragInitiator.mx_internal::setSelectedIndices(oldSelections, true);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function get name():String
		{
			return format("移动图层 ({0}) 到 ({1})", oldSelections.toString(), dropIndex);
		}
	}
}
