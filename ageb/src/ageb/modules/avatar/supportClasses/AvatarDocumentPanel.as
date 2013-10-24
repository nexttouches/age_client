package ageb.modules.avatar.supportClasses
{
	import age.AGE;
	import ageb.modules.ae.ActionInfoEditable;
	import ageb.modules.ae.ObjectInfoEditable;
	import ageb.modules.ae.ObjectRendererEditable;
	import ageb.modules.ae.SceneRendererEditable;
	import ageb.modules.document.AvatarDocument;
	import ageb.modules.document.Document;
	import ageb.modules.document.FormPanel;
	import nt.lib.util.assert;

	/**
	 * AvatarDocumentPanel 定义了在 AvatarDocumentView 出现的子面板<br>
	 * 比较容易和 AvatarDocumentView 混淆，请额外注意
	 * @see aeb.modules.avatar.timelineClasses.TimelinePanel
	 * @see aeb.modules.avatar.AvatarPropertyPanel
	 * @see aeb.modules.avatar.FrameInfoPanel
	 * @author zhanghaocong
	 *
	 */
	public class AvatarDocumentPanel extends FormPanel
	{
		/**
		 * 创建一个新的 AvatarDocumentPanel
		 *
		 */
		public function AvatarDocumentPanel()
		{
			super();
		}

		private var _doc:Document;

		/**
		 * 设置或获取要渲染的文档
		 * @return
		 *
		 */
		public function get doc():Document
		{
			return _doc;
		}

		public function set doc(value:Document):void
		{
			if (avatarDoc)
			{
				actionInfo = null;
				objectInfo.onActionNameChange.remove(onActionNameChange);
			}
			_doc = value;

			if (avatarDoc)
			{
				objectInfo.onActionNameChange.add(onActionNameChange);
				onActionNameChange();
			}
		}

		private var _actionInfo:ActionInfoEditable;

		/**
		 * 设置或获取当前显示的动作
		 * @return
		 *
		 */
		public function get actionInfo():ActionInfoEditable
		{
			return _actionInfo;
		}

		public function set actionInfo(value:ActionInfoEditable):void
		{
			_actionInfo = value;
		}

		/**
		 * ObjectInfo 的动作变更时调用
		 *
		 */
		private function onActionNameChange():void
		{
			actionInfo = objectInfo.actionInfo as ActionInfoEditable;
		}

		/**
		* 获取当前的渲染器
		* @return
		*
		*/
		[Inline]
		final protected function get renderer():ObjectRendererEditable
		{
			return sceneRenderer.charLayer.getObjectRendererByInfo(avatarDoc.object) as ObjectRendererEditable;
		}

		/**
		 * 获取当前的 AvatarDocument
		 * @return
		 *
		 */
		[Inline]
		final protected function get avatarDoc():AvatarDocument
		{
			return _doc as AvatarDocument;
		}

		/**
		 * 获取当前的 ObjectInfoEditable
		 * @return
		 *
		 */
		[Inline]
		final protected function get objectInfo():ObjectInfoEditable
		{
			return avatarDoc.object;
		}

		/**
		 * 获得 SceneRendererEditable
		 * @return
		 *
		 */
		[Inline]
		final protected function get sceneRenderer():SceneRendererEditable
		{
			assert(AGE.s != null, "AE 尚未准备好");
			return modules.ae.sceneRenderer;
		}
	}
}
