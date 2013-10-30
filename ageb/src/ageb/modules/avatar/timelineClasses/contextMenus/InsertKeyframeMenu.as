package ageb.modules.avatar.timelineClasses.contextMenus
{
	import flash.events.Event;
	import ageb.modules.avatar.op.InsertFrame;

	public class InsertKeyframeMenu extends FrameMenuItem
	{
		public function InsertKeyframeMenu()
		{
			super();
			contextMenuItem.caption = "插入关键帧";
		}

		/**
		 * @inheritDoc
		 * @param event
		 *
		 */
		override protected function onSelect(event:Event):void
		{
			new InsertFrame(doc, info, cells, true, true).execute();
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
