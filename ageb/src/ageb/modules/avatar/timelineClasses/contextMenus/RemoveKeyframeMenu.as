package ageb.modules.avatar.timelineClasses.contextMenus
{
	import flash.events.Event;
	import ageb.modules.avatar.op.ChangeFrameIsKeyframe;

	/**
	 * 转换为过渡
	 * @author zhanghaocong
	 *
	 */
	public class RemoveKeyframeMenu extends FrameMenuItem
	{
		/**
		 * constructor
		 *
		 */
		public function RemoveKeyframeMenu()
		{
			super();
			contextMenuItem.caption = "清除关键帧";
		}

		/**
		 * @inheritDoc
		 * @param event
		 *
		 */
		override protected function onSelect(event:Event):void
		{
			new ChangeFrameIsKeyframe(doc, frames, false).execute();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function onShow():void
		{
			if (frames.length == 0)
			{
				contextMenuItem.enabled = false;
			}
			else if (frames.length == 1)
			{
				contextMenuItem.enabled = frames[0].isKeyframe;
			}
			else
			{
				contextMenuItem.enabled = true;
			}
		}
	}
}
