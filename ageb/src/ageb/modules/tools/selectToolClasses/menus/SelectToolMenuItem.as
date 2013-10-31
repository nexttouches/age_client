package ageb.modules.tools.selectToolClasses.menus
{
	import ageb.modules.Modules;
	import ageb.modules.ae.LayerRendererEditable;
	import ageb.modules.ae.SceneInfoEditable;
	import ageb.modules.document.SceneDocument;
	import ageb.utils.MenuItem;

	/**
	 * 切换到 SelectTool 时使用的右键菜单项基类
	 * @author zhanghaocong
	 *
	 */
	public class SelectToolMenuItem extends MenuItem
	{
		/**
		 * 当前操作的图层渲染器
		 */
		public var lr:LayerRendererEditable

		/**
		 * constructor
		 *
		 */
		public function SelectToolMenuItem()
		{
			super();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function onClose():void
		{
			// 解引用
			lr = null;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function onShow():void
		{
			// 默认启用
			contextMenuItem.enabled = true;
		}

		/**
		 * 当前文档
		 * @return
		 *
		 */
		protected function get doc():SceneDocument
		{
			return Modules.getInstance().document.currentDoc as SceneDocument;
		}

		/**
		 * 当前 SceneInfoEditable
		 * @return
		 *
		 */
		protected function get sceneInfo():SceneInfoEditable
		{
			return doc.info;
		}
	}
}
