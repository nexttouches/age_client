package ageb.modules.scene
{
	import flash.events.MouseEvent;
	import ageb.modules.ae.SceneInfoEditable;
	import ageb.modules.document.Document;
	import ageb.modules.document.SceneDocument;

	/**
	 * 地图文档视图
	 * @author zhanghaocong
	 *
	 */
	public class SceneDocumentView extends SceneDocumentViewTemplate
	{
		/**
		 * 创建一个新的 MapDocumentView
		 *
		 */
		public function SceneDocumentView()
		{
			super();
		}

		/**
		 * 获得 SceneInfoEditable
		 */
		public function get info():SceneInfoEditable
		{
			return SceneDocument(doc).info;
		}

		/**
		 * 获得当前文档
		 * @return
		 *
		 */
		public function get sceneDoc():SceneDocument
		{
			return doc as SceneDocument;
		}

		override protected function onAddDoc(doc:Document):void
		{
			sceneRenderer.info = info;
			historyPanel.doc = doc;
			layerPanel.doc = doc;
			objectsPanel.doc = doc;
			propertyPanel.doc = doc;
			info.onSizeChange.add(onSizeChange);
			onSizeChange();
			super.onAddDoc(doc);
		}

		override protected function onMouseMove(event:MouseEvent):void
		{
			super.onMouseMove(event);

			if (isNaN(mousePoint.x) || isNaN(mousePoint.y))
			{
				mousePointField.text = "缺少主图层，无法确定鼠标位置";
			}
			else
			{
				mousePointField.text = mousePoint.x.toFixed(3) + ", " + mousePoint.y.toFixed(3);
			}
		}

		override protected function onRemoveDoc(doc:Document):void
		{
			info.onSizeChange.remove(onSizeChange);
			sceneRenderer.info = null;
			historyPanel.doc = null;
			layerPanel.doc = null;
			objectsPanel.doc = null;
			propertyPanel.doc = null;
			super.onRemoveDoc(doc);
		}

		protected function onSizeChange():void
		{
			sceneSize.text = info.width.toFixed(0) + "×" + info.height.toFixed(0)
		}
	}
}
