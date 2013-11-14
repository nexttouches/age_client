package ageb.modules.avatar.op
{
	import ageb.modules.ae.FrameInfoEditable;
	import ageb.modules.document.Document;

	/**
	 * 修改 particleConfig 操作
	 * @author zhanghaocong
	 *
	 */
	public class ChangeFrameParticleConfig extends ChangeFrameProperty
	{
		/**
		 * constructor
		 * @param doc
		 * @param frames
		 * @param value
		 *
		 */
		public function ChangeFrameParticleConfig(doc:Document, frames:Vector.<FrameInfoEditable>, value:*)
		{
			super(doc, frames, value, "particleConfig");
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function get name():String
		{
			return "修改粒子设置";
		}
	}
}
