package ageb.modules.tools.selectToolClasses.menus
{
	import flash.events.Event;
	import flash.geom.Point;
	import age.AGE;
	import age.data.LayerType;
	import ageb.modules.ae.LayerInfoEditable;
	import ageb.modules.scene.op.AddObject;

	/**
	 * 添加对象菜单
	 * @author zhanghaocong
	 *
	 */
	public class AddObjectMeun extends SelectToolMenuItem
	{
		/**
		 * constructor
		 *
		 */
		public function AddObjectMeun()
		{
			super();
			contextMenuItem.caption = "添加对象";
		}

		/**
		 * @inheritDoc
		 * @param event
		 *
		 */
		override protected function onSelect(event:Event):void
		{
			var mousePosition:Point = new Point(nativeStage.stage.mouseX - AGE.paddingLeft, nativeStage.stage.mouseY - AGE.paddingTop);
			mousePosition = lr.globalToLocal(mousePosition, mousePosition);
			new AddObject(doc, lr.info as LayerInfoEditable, mousePosition.x, lr.info.parent.uiToZ(mousePosition.y)).execute();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function onShow():void
		{
			contextMenuItem.enabled = lr.info.type == LayerType.OBJECT;
		}
	}
}
