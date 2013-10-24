package ageb.modules.avatar.op
{
	import flash.utils.Dictionary;
	import ageb.modules.ae.FrameInfoEditable;
	import ageb.modules.document.Document;

	/**
	 * 修改帧是否是关键帧
	 * @author zhanghaocong
	 *
	 */
	public class ChangeFrameIsKeyframe extends ChangeFrameProperty
	{
		/**
		 * 修改为非关键帧时会删除 box，这里保存一份以便 undo 使用
		 */
		private var oldBoxes:Dictionary;

		/**
		 * 修改为非关键帧时会删除 texture，这里保存一份以便 undo 使用
		 */
		private var oldTextures:Dictionary;

		/**
		 * constructor
		 * @param doc
		 * @param frames
		 * @param value
		 *
		 */
		public function ChangeFrameIsKeyframe(doc:Document, frames:Vector.<FrameInfoEditable>, value:*)
		{
			super(doc, frames, value, "isKeyframe");
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function saveOld():void
		{
			super.saveOld();
			// 额外储存 2 个值
			oldBoxes = new Dictionary;
			oldTextures = new Dictionary;

			for (var i:int = 0, n:int = frames.length; i < n; i++)
			{
				const info:FrameInfoEditable = frames[i];
				oldBoxes[info] = info.box;
				oldTextures[info] = info.texture;
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function undo():void
		{
			for (var i:int = 0, n:int = frames.length; i < n; i++)
			{
				const info:FrameInfoEditable = frames[i];
				info.texture = oldTextures[info];
				info.box = oldBoxes[info];
			}
			super.undo();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function redo():void
		{
			for (var i:int = 0, n:int = frames.length; i < n; i++)
			{
				const info:FrameInfoEditable = frames[i];

				// 不修改第一帧
				if (info.isHead)
				{
					continue;
				}

				// 设置为关键帧，需提取上一个关键帧的数据
				if (value == true)
				{
					if (info.prevKeyFrame.box)
					{
						info.box = info.prevKeyFrame.box.clone1();
					}
					info.texture = info.prevKeyFrame.texture;
				}
				// 否则删除 texture 和 box 属性
				else
				{
					info.box = null;
					info.texture = null;
				}
			}
			super.redo();
		}
	}
}
