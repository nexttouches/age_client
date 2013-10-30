package ageb.modules.avatar.timelineClasses.contextMenus
{
	import flash.events.Event;
	import ageb.modules.avatar.op.InsertFrame;

	/**
	 * 插入帧
	 * @author zhanghaocong
	 *
	 */
	public class InsertFrameMenu extends FrameMenuItem
	{
		/**
		 * constructor
		 *
		 */
		public function InsertFrameMenu()
		{
			super();
			contextMenuItem.caption = "插入帧";
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
		override public function onShow():void
		{
			// 总是启用
			contextMenuItem.enabled = true;
		}
	}
}
