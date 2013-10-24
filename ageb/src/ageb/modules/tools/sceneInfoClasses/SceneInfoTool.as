package ageb.modules.tools.sceneInfoClasses
{
	import mx.events.FlexEvent;
	import ageb.modules.document.Document;
	import ageb.modules.document.SceneDocument;

	public class SceneInfoTool extends SceneInfoPanel
	{

		[Embed(source="../assets/icons/window.png")]
		private var iconClass:Class;

		public function SceneInfoTool()
		{
			super();
			name = "场景信息";
			shortcut = "E";
			icon = iconClass;
			availableDocuments = new <Class>[ SceneDocument ];
		}

		protected function onSizeChange():void
		{
			sceneWidth.value = currentSceneDocument.info.width;
			sceneHeight.value = currentSceneDocument.info.height;
		}

		override public function set currentDocument(value:Document):void
		{
			if (currentSceneDocument)
			{
				currentSceneDocument.info.onSizeChange.remove(onSizeChange);
			}
			super.currentDocument = value;

			if (currentSceneDocument)
			{
				currentSceneDocument.info.onSizeChange.add(onSizeChange);
			}
		}

		override protected function onShow(event:FlexEvent):void
		{
			onSizeChange();
		}
	}
}
