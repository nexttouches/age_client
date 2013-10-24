package ageb.modules.avatar.timelineClasses.contextMenus
{
	import flash.events.Event;
	import ageb.modules.avatar.op.RemoveFrame;

	/**
	 * 删除帧操作
	 * @author zhanghaocong
	 *
	 */
	public class RemoveFrameMenu extends FrameContextMenuItem
	{
		/**
		 * constructor
		 *
		 */
		public function RemoveFrameMenu()
		{
			super();
			item.caption = "删除帧";
		}

		/**
		 * inheritDoc
		 * @param event
		 *
		 */
		override protected function onSelect(event:Event):void
		{
			new RemoveFrame(doc, info, cells).execute();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function validate():void
		{
			item.enabled = true;
		}
	}
}
