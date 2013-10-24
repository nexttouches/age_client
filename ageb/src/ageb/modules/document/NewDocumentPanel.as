package ageb.modules.document
{
	import flash.events.MouseEvent;
	import mx.managers.PopUpManager;
	import ageb.modules.Modules;
	import org.osflash.signals.Signal;

	public class NewDocumentPanel extends NewDocumentPanelTemplate
	{
		private static var _instance:NewDocumentPanel;

		public static function hide():void
		{
			PopUpManager.removePopUp(instance);
		}

		public static function get instance():NewDocumentPanel
		{
			return _instance ||= new NewDocumentPanel;
		}

		public static function show():NewDocumentPanel
		{
			PopUpManager.addPopUp(instance, Modules.getInstance().root, true);
			PopUpManager.centerPopUp(instance)
			return instance;
		}

		public function NewDocumentPanel()
		{
			super();
		}

		/**
		 * 场景标签页中点击确定时广播
		 */
		public var onCreateScene:Signal = new Signal(String, int, int);

		/**
		 * Avatar 标签页中点击确定时广播
		 */
		public var onCreateAvatar:Signal = new Signal();

		override protected function createSceneButton_onClick(event:MouseEvent):void
		{
			onCreateScene.dispatch(idField.text, widthField.value, heightField.value);
			hide();
		}

		override protected function closeButton_clickHandler(event:MouseEvent):void
		{
			super.closeButton_clickHandler(event);
			hide();
		}
	}
}
