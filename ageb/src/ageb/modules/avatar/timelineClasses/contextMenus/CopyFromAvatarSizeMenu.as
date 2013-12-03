package ageb.modules.avatar.timelineClasses.contextMenus
{
	import flash.events.Event;
	import age.data.FrameInfo;
	import age.data.FrameLayerType;
	import ageb.modules.avatar.op.ChangeFrameBox;

	/**
	 * 从 AvatarInfo.size 复制 box 属性到当前帧
	 * @author zhanghaocong
	 *
	 */
	public class CopyFromAvatarSizeMenu extends FrameMenuItem
	{
		/**
		 * constructor
		 *
		 */
		public function CopyFromAvatarSizeMenu()
		{
			super();
			contextMenuItem.caption = "从 size 复制";
		}

		/**
		* @inheritDoc
		* @param event
		*
		*/
		override protected function onSelect(event:Event):void
		{
			new ChangeFrameBox(doc, keyframes, doc.avatar.size.clone1()).execute();
		}

		/**
		 * @inheritDoc
		 * @return
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
				contextMenuItem.enabled = frames[0].type == FrameLayerType.VIRTUAL;
			}
			else
			{
				for each (var info:FrameInfo in frames)
				{
					if (info.type != FrameLayerType.VIRTUAL)
					{
						return;
					}
				}
				contextMenuItem.enabled = true;
			}
		}
	}
}
