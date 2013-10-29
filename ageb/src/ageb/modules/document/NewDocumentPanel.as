package ageb.modules.document
{
	import flash.events.MouseEvent;
	import mx.managers.PopUpManager;
	import spark.components.TitleWindow;
	import ageb.modules.Modules;
	import org.osflash.signals.OnceSignal;

	/**
	 * 新建文档面板，包含了新建场景和新建 Avatar 2 个标签页
	 * @author zhanghaocong
	 *
	 */
	public class NewDocumentPanel extends TitleWindow
	{
		private static var _instance:NewDocumentPanel;

		/**
		 * 隐藏
		 *
		 */
		public static function hide():void
		{
			PopUpManager.removePopUp(instance);
		}

		/**
		 * 唯一实例
		 * @return
		 *
		 */
		public static function get instance():NewDocumentPanel
		{
			return _instance ||= new NewDocumentPanel;
		}

		/**
		 * 打开
		 * @return
		 *
		 */
		public static function show():NewDocumentPanel
		{
			PopUpManager.addPopUp(instance, Modules.getInstance().root, true);
			PopUpManager.centerPopUp(instance)
			return instance;
		}

		[SkinPart(required="true")]
		public var newSceneDocumentPanel:NewSceneDocumentPanel;

		[SkinPart(required="true")]
		public var newAvatarDocumentPanel:NewAvatarDocumentPanel;

		/**
		 * constructor
		 *
		 */
		public function NewDocumentPanel()
		{
			super();
			title = "新建";
			setStyle("skinClass", NewDocumentPanelSkin);
		}

		/**
		 * 创建场景按确定时广播<br>
		 * 正确的回调签名是 function (id:String, width:int, height:int):void;
		 * @return
		 *
		 */
		public function get onCreateScene():OnceSignal
		{
			return newSceneDocumentPanel.onOK;
		}

		/**
		 * Avatar 标签页中点击确定时广播<br>
		 * 正确的回调签名是 function (id:String):void;
		 */
		public function get onCreateAvatar():OnceSignal
		{
			return newAvatarDocumentPanel.onOK;
		}

		override protected function closeButton_clickHandler(event:MouseEvent):void
		{
			super.closeButton_clickHandler(event);
			hide();
		}
	}
}
