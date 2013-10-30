package ageb.modules.avatar.timelineClasses.contextMenus
{
	import flash.events.Event;
	import ageb.modules.avatar.op.InsertFrame;

	public class InsertEmptyKeyframeMenu extends FrameMenuItem
	{
		public function InsertEmptyKeyframeMenu()
		{
			super();
			contextMenuItem.caption = "插入空白关键帧";
		}

		/**
		 * @inheritDoc
		 * @param event
		 *
		 */
		override protected function onSelect(event:Event):void
		{
			new InsertFrame(doc, info, cells, true, false).execute();
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
