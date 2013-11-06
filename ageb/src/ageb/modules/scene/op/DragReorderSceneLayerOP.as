package ageb.modules.scene.op
{
	import mx.core.mx_internal;
	import age.data.LayerInfo;
	import ageb.modules.ae.LayerInfoEditable;
	import ageb.modules.document.Document;
	import ageb.modules.scene.SceneLayerList;
	import org.apache.flex.collections.VectorList;

	/**
	 * 拖拽调整图层顺序操作
	 * @author zhanghaocong
	 *
	 */
	public class DragReorderSceneLayerOP extends SceneOPBase
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
		public var action:String;

		/**
		 * 表示由哪个列表控件触发
		 */
		public var dragInitiator:SceneLayerList;

		/**
		 * 旧选中索引项
		 */
		public var oldSelections:Vector.<int>;

		/**
		 * 旧数据源中的内容
		 */
		public var oldSource:Vector.<LayerInfo>;

		/**
		 * 旧主图层索引
		 */
		public var oldCharLayerIndex:int;

		/**
		 * 创建一个新的 ReorderlayerOP
		 * @param doc
		 * @param dropIndex
		 * @param caretIndex
		 * @param items
		 * @param action
		 * @param dragInitiator
		 *
		 */
		public function DragReorderSceneLayerOP(doc:Document, dropIndex:int, caretIndex:int, items:Vector.<Object>, action:String, dragInitiator:SceneLayerList = null)
		{
			super(doc);
			this.dropIndex = dropIndex;
			this.caretIndex = caretIndex;
			this.items = items;
			this.action = action;
			this.dragInitiator = dragInitiator;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function redo():void
		{
			const charLayer:LayerInfoEditable = dp.getItemAt(doc.info.charLayerIndex) as LayerInfoEditable;
			dragInitiator.reorder(dropIndex, caretIndex, items, action, dragInitiator);
			// charLayerIndex 可能有变化，我们更新一下
			doc.info.charLayerIndex = dp.getItemIndex(charLayer);;

			// 卷动到焦点
			if (caretIndex != -1)
			{
				dragInitiator.scrollTo(dropIndex + caretIndex);
			}
			doc.info.onLayersChange.dispatch();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function saveOld():void
		{
			oldSelections = dragInitiator.selectedIndices.concat();
			oldSource = VectorList(dragInitiator.dataProvider).source.concat();
			oldCharLayerIndex = doc.info.charLayerIndex;
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
			dp.source = oldSource;
			dragInitiator.mx_internal::setSelectedIndices(oldSelections, true);
			// 恢复 charLayerIndex
			doc.info.charLayerIndex = oldCharLayerIndex;
			doc.info.onLayersChange.dispatch();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function get name():String
		{
			return format("移动图层 ({0}) 到 ({1})", oldSelections.toString(), dropIndex);
		}

		/**
		 * @private
		 * @return
		 *
		 */
		protected function get dp():VectorList
		{
			return dragInitiator.dataProvider as VectorList;
		}
	}
}
