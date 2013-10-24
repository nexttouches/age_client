package ageb.modules.about
{
	import mx.managers.PopUpManager;
	import ageb.modules.ModuleBase;
	import ageb.modules.Modules;

	public class AboutModule extends ModuleBase
	{
		private var _panel:AboutPanel;

		public function get panel():AboutPanel
		{
			return _panel ||= new AboutPanel();
		}

		public function AboutModule()
		{
			super();
		}

		public function open():void
		{
			PopUpManager.addPopUp(panel, Modules.getInstance().root, true);
			PopUpManager.centerPopUp(panel);
		}

		/**
		 * 关闭设置面板
		 *
		 */
		public function close():void
		{
			PopUpManager.removePopUp(panel);
		}
	}
}
