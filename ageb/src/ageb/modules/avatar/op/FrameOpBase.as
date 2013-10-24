package ageb.modules.avatar.op
{
	import ageb.modules.ae.FrameInfoEditable;
	import ageb.modules.document.Document;

	/**
	 * 帧操作的基础类
	 * @author zhanghaocong
	 *
	 */
	public class FrameOpBase extends AvatarOPBase
	{
		/**
		 * 本次操作的帧列表
		 */
		protected var frames:Vector.<FrameInfoEditable>;

		/**
		 * constructor
		 * @param doc
		 * @param frames
		 *
		 */
		public function FrameOpBase(doc:Document, frames:Vector.<FrameInfoEditable>)
		{
			super(doc);
			this.frames = frames;
		}
	}
}
