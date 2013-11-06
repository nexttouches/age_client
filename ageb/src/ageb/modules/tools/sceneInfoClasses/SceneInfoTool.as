package ageb.modules.tools.sceneInfoClasses
{
	import mx.events.FlexEvent;
	import ageb.modules.document.Document;
	import ageb.modules.document.SceneDocument;

	/**
	 * 场景信息工具
	 * @author zhanghaocong
	 *
	 */
	public class SceneInfoTool extends SceneInfoPanel
	{

		[Embed(source="../assets/icons/window.png")]
		private var iconClass:Class;

		/**
		 * constructor
		 *
		 */
		public function SceneInfoTool()
		{
			super();
			name = "场景信息";
			shortcut = "E";
			icon = iconClass;
			availableDocs = new <Class>[ SceneDocument ];
		}

		/**
		 * @private
		 *
		 */
		protected function onSizeChange():void
		{
			xField.value = sceneDoc.info.width;
			yField.value = sceneDoc.info.height;
			zField.value = sceneDoc.info.depth;
		}

		/**
		 * @inheritDoc
		 *
		 */
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

		/**
		 * @inheritDoc
		 *
		 */
		override protected function onShow(event:FlexEvent):void
		{
			onSizeChange();
		}
	}
}
