package ageb.modules.avatar.timelineClasses.contextMenus
{
	import flash.events.Event;
	import ageb.modules.avatar.op.InsertFrame;

	public class InsertKeyframeMenu extends FrameContextMenuItem
	{
		public function InsertKeyframeMenu()
		{
			super();
			item.caption = "插入关键帧";
			item.separatorBefore = true;
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
		override public function validate():void
		{
			// 总是启用
			item.enabled = true;
		}
	}
}
