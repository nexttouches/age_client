package ageb.modules.scene
{
	import spark.events.IndexChangeEvent;
	import ageb.modules.ae.SceneInfoEditable;
	import ageb.modules.document.Document;
	import ageb.modules.document.SceneDocument;
	import ageb.modules.scene.op.AddLayerOP;
	import ageb.modules.scene.op.RemoveLayerOP;
	import ageb.utils.FlashTip;

	/**
	 * 地图图层面板
	 * @author zhanghaocong
	 *
	 */
	public class SceneLayerPanel extends SceneLayerPanelTemplate
	{
		/**
		 * 创建一个新的 SceneLayerPanel
		 *
		 */
		public function SceneLayerPanel()
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
				info.onSelectedLayersIndicesChange.remove(onSelectedLayersIndicesChange);
				list.dataProvider = null;
			}
			_doc = value;

			if (_doc)
			{
				list.dataProvider = info.layersVectorList;
				info.onSelectedLayersIndicesChange.add(onSelectedLayersIndicesChange);
				onSelectedLayersIndicesChange();
			}
		}

		/**
		 * 通过代码修改 info.selectedLayersIndices 时调用
		 *
		 */
		private function onSelectedLayersIndicesChange(trigger:Object = null):void
		{
			// 不是当前面板触发的修改，需要重新设置索引
			if (trigger != list)
			{
				list.selectedIndices = info.selectedLayersIndices.concat();
			}
		}

		/**
		 * 图层列表手动修改时调用
		 *
		 */
		override protected function list_onChange(event:IndexChangeEvent):void
		{
			info.selectedLayersIndices = list.selectedIndices;
			info.onSelectedLayersIndicesChange.dispatch(list);
		}

		/**
		 * 增加图层
		 *
		 */
		override protected function addLayer():void
		{
			new AddLayerOP(documentView.doc).execute();
		}

		/**
		 * 删除图层
		 *
		 */
		override protected function removeLayer():void
		{
			if (list.selectedIndices.indexOf(sceneDoc.info.charLayerIndex) != -1)
			{
				FlashTip.show("选中的图层中含有角色层，不可删除");
				return;
			}
			new RemoveLayerOP(documentView.doc, list.selectedIndices.concat(), list).execute();
		}

		/**
		 * 获得 SceneDocument 引用
		 * @return
		 *
		 */
		private function get sceneDoc():SceneDocument
		{
			return _doc as SceneDocument;
		}

		/**
		 * 获得 SceneInfoEditable 引用
		 * @return
		 *
		 */
		private function get info():SceneInfoEditable
		{
			return sceneDoc.info;
		}
	}
}
