package ageb.modules.avatar
{
	import flash.events.MouseEvent;
	import age.renderers.LayerRenderer;
	import ageb.modules.document.AvatarDocument;
	import ageb.modules.document.Document;
	import starling.display.DisplayObject;

	/**
	 * AvatarDocument 视图
	 * @author kk
	 *
	 */
	public class AvatarDocumentView extends AvatarDocumentViewTemplate
	{
		/**
		 * constructor
		 *
		 */
		public function AvatarDocumentView()
		{
			super();
		}

		/**
		 * @inheritDoc
		 * @param doc
		 *
		 */
		override protected function onRemoveDoc(doc:Document):void
		{
			timelinePanel.doc = null;
			historyPanel.doc = null;
			frameInfoPanel.doc = null;
			sceneRenderer.info = null;
			super.onRemoveDoc(doc);
		}

		/**
		 * 获得关联的 AvatarDocument
		 * @return
		 *
		 */
		final protected function get avatarDoc():AvatarDocument
		{
			return doc as AvatarDocument;
		}

		/**
		 * @inheritDoc
		 * @param doc
		 *
		 */
		override protected function onAddDoc(doc:Document):void
		{
			sceneRenderer.info = avatarDoc.scene;
			historyPanel.doc = doc;
			timelinePanel.doc = doc;
			frameInfoPanel.doc = doc;
			super.onAddDoc(doc);
		}

		/**
		 * @inheritDoc
		 * @param doc
		 *
		 */
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

		/**
		 * @inheritDoc
		 * @param doc
		 *
		 */
		override protected function get mousePointRelative():DisplayObject
		{
			if (super.mousePointRelative)
			{
				// 使用 mouseResponder 作为原点
				return LayerRenderer(super.mousePointRelative).getObjectRendererByInfo(avatarDoc.object).displayObject;
			}
			return null;
		}
	}
}
