package ageb.modules.avatar.timelineClasses.contextMenus
{
	import flash.events.Event;
	import ageb.modules.avatar.op.ChangeFrameIsKeyframe;

	/**
	 * 转换为过渡
	 * @author zhanghaocong
	 *
	 */
	public class RemoveKeyframeMenu extends FrameContextMenuItem
	{
		/**
		 * constructor
		 *
		 */
		public function RemoveKeyframeMenu()
		{
			super();
			item.caption = "清除关键帧";
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
		 * @return
		 *
		 */
		override public function validate():void
		{
			if (frames.length == 0)
			{
				item.enabled = false;
			}
			else if (frames.length == 1)
			{
				item.enabled = frames[0].isKeyframe;
			}
			else
			{
				item.enabled = true;
			}
		}
	}
}
