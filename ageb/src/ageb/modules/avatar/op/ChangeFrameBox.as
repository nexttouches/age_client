package ageb.modules.avatar.op
{
	import age.assets.Box;
	import ageb.modules.ae.FrameInfoEditable;
	import ageb.modules.document.Document;

	/**
	 * 修改 FrameInfo.box 操作
	 * @author zhanghaocong
	 *
	 */
	public class ChangeFrameBox extends ChangeFrameProperty
	{
		/**
		 * constructor
		 * @param doc
		 * @param frames
		 * @param box
		 *
		 */
		public function ChangeFrameBox(doc:Document, frames:Vector.<FrameInfoEditable>, box:Box)
		{
			super(doc, frames, box, "box");
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function get name():String
		{
			return "修改帧框信息";
		}
	}
}
