package ageb.modules.avatar.timelineClasses.contextMenus
{
	import flash.events.Event;
	import ageb.modules.avatar.op.ChangeFrameIsKeyframe;

	/**
	 * 转换为关键帧
	 * @author zhanghaocong
	 *
	 */
	[Deprecated("请使用 InsertFrame", "aeb.modules.avatar.op.InsertFrame")]
	public class ConvertToKeyframeMenu extends FrameContextMenuItem
	{
		/**
		 * constructor
		 *
		 */
		public function ConvertToKeyframeMenu()
		{
			super();
			item.caption = "转换为关键帧";
		}

		/**
		* @inheritDoc
		* @param event
		*
		*/
		override protected function onSelect(event:Event):void
		{
			new ChangeFrameIsKeyframe(doc, frames, true).execute();
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
				item.enabled = !frames[0].isKeyframe;
			}
			else
			{
				item.enabled = true;
			}
		}
	}
}
