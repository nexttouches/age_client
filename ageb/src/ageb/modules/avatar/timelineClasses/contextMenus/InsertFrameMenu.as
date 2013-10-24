package ageb.modules.avatar.timelineClasses.contextMenus
{
	import flash.events.Event;
	import ageb.modules.avatar.op.InsertFrame;

	/**
	 * 插入帧
	 * @author zhanghaocong
	 *
	 */
	public class InsertFrameMenu extends FrameContextMenuItem
	{
		/**
		 * constructor
		 *
		 */
		public function InsertFrameMenu()
		{
			super();
			item.caption = "插入帧";
		}

		/**
		 * @inheritDoc
		 * @param event
		 *
		 */
		override protected function onSelect(event:Event):void
		{
			new InsertFrame(doc, info, cells, false, false).execute();
		}

		/**
		 * @inheritDoc
		 * @param event
		 *
		 */
		override public function validate():void
		{
			// 总是启用
			item.enabled = true;
		}
	}
}
