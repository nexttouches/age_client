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
			sceneWidth.value = sceneDoc.info.width;
			sceneHeight.value = sceneDoc.info.height;
		}

		override public function set doc(value:Document):void
		{
			if (sceneDoc)
			{
				sceneDoc.info.onSizeChange.remove(onSizeChange);
			}
			super.doc = value;

			if (sceneDoc)
			{
				sceneDoc.info.onSizeChange.add(onSizeChange);
			}
		}

		override protected function onShow(event:FlexEvent):void
		{
			onSizeChange();
		}
	}
}
