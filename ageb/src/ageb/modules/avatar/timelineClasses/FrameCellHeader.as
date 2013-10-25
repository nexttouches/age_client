package ageb.modules.avatar.timelineClasses
{
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import mx.core.FTETextField;

	/**
	 * 帧网格 Header
	 * @author zhanghaocong
	 *
	 */
	public class FrameCellHeader extends FrameCell
	{
		/**
		 * 每 5 帧显示当前帧数的文本框
		 */
		private var tf:FTETextField;

		/**
		 * 文字格式
		 */
		private static var sharedTextFormat:TextFormat = new TextFormat("微软雅黑", 10, 0xcccccc, null, null, null, null, null);

		/**
		 * constructor
		 *
		 */
		public function FrameCellHeader()
		{
			super();
			height = 21;
		}

		/**
		 * @inhertDoc
		 * @param hasBeenRecycled
		 *
		 */
		override public function prepare(hasBeenRecycled:Boolean):void
		{
			var index:int = columnIndex + 1;

			if (index == 1 || index % 5 == 0)
			{
				if (!tf)
				{
					tf = new FTETextField();
					tf.defaultTextFormat = sharedTextFormat;
					tf.autoSize = TextFieldAutoSize.LEFT;
				}
				tf.text = String(index);
				addChild(tf);
			}
			else
			{
				if (tf && tf.parent)
				{
					removeChild(tf);
				}
			}
		}

		/**
		 * @inheritDoc
		 * @param willBeRecycled
		 *
		 */
		override public function discard(willBeRecycled:Boolean):void
		{
			// Do nothing
		}
	}
}
