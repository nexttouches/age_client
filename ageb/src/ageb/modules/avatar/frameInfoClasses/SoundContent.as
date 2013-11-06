package ageb.modules.avatar.frameInfoClasses
{
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.text.ReturnKeyLabel;
	import spark.components.Button;
	import spark.components.TextInput;
	import ageb.modules.ae.ActionInfoEditable;
	import ageb.modules.ae.FrameInfoEditable;
	import ageb.utils.FileUtil;

	/**
	 * 类型为 SOUND 的 FrameInfo 的面板
	 * @author zhanghaocong
	 *
	 */
	public class SoundContent extends FrameInfoPanelContent
	{

		[SkinPart(required="true")]
		public var playButton:Button;

		[SkinPart(required="true")]
		public var assetPathField:TextInput;

		[SkinPart(required="true")]
		public var browseButton:Button;

		/**
		 * 创建一个新的 SoundContent
		 *
		 */
		public function SoundContent()
		{
			super();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			playButton.addEventListener(MouseEvent.CLICK, playButton_onClick);
			browseButton.addEventListener(MouseEvent.CLICK, browseButton_onClick);
		}

		/**
		 * @private
		 *
		 */
		protected function browseButton_onClick(event:MouseEvent):void
		{
			FileUtil.browseFile(expectFolder.nativePath, [ new FileFilter("MP3 Files", "*.mp3")], onBrowseComplete);
		}

		/**
		 * 用户选择文件后调用
		 * @param f
		 *
		 */
		private function onBrowseComplete(f:File):void
		{
			if (expectFolder.nativePath != f.parent.nativePath)
			{
			}
		}

		/**
		 * @private
		 *
		 */
		protected function playButton_onClick(event:MouseEvent):void
		{
			if (!keyframe)
			{
				return;
			}
			// TODO 播放该帧的 MP3
		}

		/**
		 * @inheritDoc
		 * @param value
		 *
		 */
		override public function set keyframes(value:Vector.<FrameInfoEditable>):void
		{
			if (keyframe)
			{
				keyframe.onAssetPathChange.remove(onAssetPathChange);
			}
			super.keyframes = value;

			if (keyframe)
			{
				keyframe.onAssetPathChange.add(onAssetPathChange);
			}
			onAssetPathChange();
		}

		/**
		 * @private
		 *
		 */
		private function onAssetPathChange():void
		{
			if (keyframe)
			{
				assetPathField.text = keyframe.assetPath;
			}
			else
			{
				assetPathField.text = "";
			}
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override protected function get skinClass():Class
		{
			return SoundContentSkin;
		}

		/**
		 * 当前动作资源期待的目录，浏览时会用到
		 * @return
		 *
		 */
		public function get expectFolder():File
		{
			return ActionInfoEditable(keyframe.parent.parent).expectFolder;
		}
	}
}
