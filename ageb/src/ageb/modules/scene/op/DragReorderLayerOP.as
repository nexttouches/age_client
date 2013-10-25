package ageb.modules.scene.op
{
	import mx.collections.ArrayList;
	import mx.core.mx_internal;
	import ageb.modules.ae.LayerInfoEditable;
	import ageb.modules.document.Document;
	import ageb.modules.scene.SceneLayerList;

	/**
	 * 拖拽调整图层顺序操作
	 * @author zhanghaocong
	 *
	 */
	public class DragReorderLayerOP extends SceneOPBase
	{
		public var dropIndex:int;

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
		public var oldSource:Array;

		/**
		 * 旧主图层索引
		 */
		public var oldCharLayerIndex:int;

		/**
		 * 新数据源中的内容<br>
		 * 首次执行 redo 后将记录修改后的列表到该值，然后下次 redo 的时候采用直接覆盖数组的方法
		 */
		public var newSource:Array;

		/**
		 * 新的选中项索引
		 */
		public var newSelections:Vector.<int>;

		/**
		 * 新的主图层索引（如有变化）
		 */
		public var newCharLayerIndex:int;

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
		public function DragReorderLayerOP(doc:Document, dropIndex:int, caretIndex:int, items:Vector.<Object>, action:String, dragInitiator:SceneLayerList = null)
		{
			super(doc);
			this.dropIndex = dropIndex;
			this.caretIndex = caretIndex;
			this.items = items;
			this.action = action;
			this.dragInitiator = dragInitiator;
		}

		override public function redo():void
		{
			if (newSource)
			{
				dragInitiator.mx_internal::setSelectedIndices(new Vector.<int>());
				dragInitiator.validateProperties();
				dp.source = newSource;
				dragInitiator.mx_internal::setSelectedIndices(newSelections, true);
			}
			else
			{
				var charLayer:LayerInfoEditable = dp.getItemAt(doc.info.charLayerIndex) as LayerInfoEditable;
				dragInitiator.reorder(dropIndex, caretIndex, items, action, dragInitiator);
				// 保存好新的结果
				newSource = dp.toArray();
				newSelections = new Vector.<int>(items.length);
				newCharLayerIndex = dp.getItemIndex(charLayer);

				for (var i:int = 0; i < items.length; i++)
				{
					newSelections[i] = dp.getItemIndex(items[i]);
				}
			}
			doc.info.charLayerIndex = newCharLayerIndex;

			// 卷动到焦点
			if (caretIndex != -1)
			{
				dragInitiator.scrollTo(dropIndex + caretIndex);
			}
			doc.info.onLayersChange.dispatch();
		}

		override protected function saveOld():void
		{
			oldSelections = dragInitiator.selectedIndices.concat();
			oldSource = dragInitiator.dataProvider.toArray();
			oldCharLayerIndex = doc.info.charLayerIndex;
		}

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

		override public function get name():String
		{
			return format("移动图层 ({0}) 到 ({1})", oldSelections.toString(), dropIndex);
		}

		/**
		 * @private
		 * @return
		 *
		 */
		protected function get dp():ArrayList
		{
			return dragInitiator.dataProvider as ArrayList;
		}
	}
}
