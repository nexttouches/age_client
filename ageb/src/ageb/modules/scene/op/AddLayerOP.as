package ageb.modules.scene.op
{
	import ageb.modules.ae.LayerInfoEditable;
	import ageb.modules.document.Document;

	/**
	 * 添加图层操作
	 * @author zhanghaocong
	 *
	 */
	public class AddLayerOP extends SceneOPBase
	{
		public var info:LayerInfoEditable;

		private var lastSelectedIndeics:Vector.<int>;

		public function AddLayerOP(doc:Document)
		{
			super(doc);
		}

		override public function redo():void
		{
			doc.info.layersArrayList.addItemAt(info, 0);
			// 总是添加新图层到第一个位置，只需简单 ++ 就可以更改 charLayerIndex
			doc.info.charLayerIndex++;
			doc.info.onLayersChange.dispatch();
			doc.info.selectedLayersIndices = new <int>[ 0 ];
			doc.info.onSelectedLayersIndicesChange.dispatch(this);
		}

		override protected function saveOld():void
		{
			info = new LayerInfoEditable(null, doc.info);
			lastSelectedIndeics = doc.info.selectedLayersIndices.concat();
		}

		override public function undo():void
		{
			doc.info.layersArrayList.removeItem(info);
			// 总是添加新图层到第一个位置，只需简单 -- 就可以恢复 charLayerIndex
			doc.info.charLayerIndex--;
			doc.info.onLayersChange.dispatch();
			doc.info.selectedLayersIndices = lastSelectedIndeics.concat();
			doc.info.onSelectedLayersIndicesChange.dispatch(this);
		}

		override public function get name():String
		{
			return "添加图层";
		}
	}
}
