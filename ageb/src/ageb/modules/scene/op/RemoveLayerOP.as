package ageb.modules.scene.op
{
	import spark.components.List;
	import age.assets.LayerInfo;
	import ageb.modules.ae.LayerInfoEditable;
	import ageb.modules.document.Document;

	/**
	 * 删除图层操作
	 * @author zhanghaocong
	 *
	 */
	public class RemoveLayerOP extends SceneOPBase
	{
		public var removeIndices:Vector.<int>;

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

		public var list:List;

		public function RemoveLayerOP(doc:Document, removeIndices:Vector.<int>, list:List = null)
		{
			super(doc);
			this.removeIndices = removeIndices;
			this.list = list;
		}

		override protected function saveOld():void
		{
			if (list)
			{
				oldSelections = list.selectedIndices.concat();
			}
			oldSource = doc.info.layers.concat();
			oldCharLayerIndex = doc.info.charLayerIndex;
		}

		override public function redo():void
		{
			if (newSource)
			{
				doc.info.layersVectorList.source = oldSource;
			}
			else
			{
				var charLayer:LayerInfoEditable = doc.info.layersVectorList.getItemAt(doc.info.charLayerIndex) as LayerInfoEditable;
				removeIndices.sort(compareValues);

				for (var i:int = removeIndices.length - 1; i >= 0; i--)
				{
					doc.info.layersVectorList.removeItemAt(removeIndices[i]);
				}
				// 保存好新的结果备用
				newSource = doc.info.layersVectorList.toArray();
				newCharLayerIndex = doc.info.layersVectorList.getItemIndex(charLayer);
			}
			doc.info.charLayerIndex = newCharLayerIndex;
			doc.info.onLayersChange.dispatch();
		}

		override public function undo():void
		{
			doc.info.layersVectorList.source = oldSource;

			if (list)
			{
				list.selectedIndices = oldSelections;
			}
			doc.info.charLayerIndex = oldCharLayerIndex;
			doc.info.onLayersChange.dispatch();
		}

		override public function get name():String
		{
			return "删除图层 (" + removeIndices.toString() + ")";
		}

		private function compareValues(a:int, b:int):int
		{
			return a - b;
		}
	}
}
