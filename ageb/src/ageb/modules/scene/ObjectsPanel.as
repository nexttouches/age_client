package ageb.modules.scene
{
	import spark.events.GridSelectionEvent;
	import spark.events.IndexChangeEvent;
	import age.assets.LayerType;
	import ageb.modules.ae.LayerInfoEditable;
	import ageb.modules.document.Document;
	import ageb.modules.document.SceneDocument;

	public class ObjectsPanel extends ObjectsPanelTemplate
	{
		public function ObjectsPanel()
		{
			super();
		}

		private var _doc:Document;

		/**
		 * 设置或获取当前关联的文档对象
		 * @return
		 *
		 */
		public function get doc():Document
		{
			return _doc;
		}

		public function set doc(value:Document):void
		{
			if (_doc)
			{
				sceneDoc.info.onSelectedLayersIndicesChange.remove(onSelectedLayersIndicesChange);
				sceneDoc.info.onSelectedObjectsChange.remove(onSelectedObjectsChange);
				list.removeEventListener(GridSelectionEvent.SELECTION_CHANGE, list_onChange);
				list.selectedItem = null;
				list.dataProvider = null;
			}
			_doc = value;

			if (_doc)
			{
				sceneDoc.info.onSelectedLayersIndicesChange.add(onSelectedLayersIndicesChange);
				sceneDoc.info.onSelectedObjectsChange.add(onSelectedObjectsChange);
				list.addEventListener(GridSelectionEvent.SELECTION_CHANGE, list_onChange);
				onSelectedLayersIndicesChange();
			}
		}

		protected function list_onChange(event:GridSelectionEvent):void
		{
			sceneDoc.info.setSelectedObjects(list.selectedItems, this);
		}

		private function onSelectedObjectsChange(trigger:Object = null):void
		{
			if (trigger == this)
			{
				return;
			}
			list.selectedItems = Vector.<Object>(sceneDoc.info.selectedObjects);
			list.validateNow();
			list.ensureCellIsVisible(list.selectedIndex);
		}

		private function onSelectedLayersIndicesChange(trigger:Object = null):void
		{
			if (trigger == this)
			{
				return;
			}
			list.dataProvider = null;
			list.columns = gridColumns[selectedLayer.type];

			if (selectedLayer.type == LayerType.BG)
			{
				list.dataProvider = selectedLayer.bgsArrayList;
			}
			else if (selectedLayer.type == LayerType.OBJECT)
			{
				list.dataProvider = selectedLayer.objectsArrayList;
			}
			list.validateNow();
		}

		protected function get sceneDoc():SceneDocument
		{
			return _doc as SceneDocument;
		}

		protected function get selectedLayer():LayerInfoEditable
		{
			return sceneDoc.info.layers[sceneDoc.info.selectedLayersIndices[0]] as LayerInfoEditable;
		}
	}
}
