package ageb.modules.avatar.frameInfoClasses
{
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import spark.components.Button;
	import spark.components.TextInput;
	import age.data.AvatarInfo;
	import ageb.modules.ae.ActionInfoEditable;
	import ageb.modules.ae.FrameInfoEditable;
	import ageb.modules.avatar.op.ChangeFrameSound;
	import ageb.utils.FileUtil;
	import ageb.utils.FlashTip;
	import nt.assets.IAsset;
	import nt.assets.IAssetUser;
	import nt.assets.extensions.SoundAsset;

	/**
	 * 类型为 SOUND 的 FrameInfo 的面板
	 * @author zhanghaocong
	 *
	 */
	public class SoundContent extends FrameInfoPanelContent implements IAssetUser
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
			if (expectFolder.nativePath == f.parent.nativePath)
			{
				doChangeSound(f);
			}
			else
			{
				Alert.show("选择的资源不在期待目录中，要复制过去吗？", "提示", Alert.YES | Alert.CANCEL, null, function(event:CloseEvent):void
				{
					if (event.detail == Alert.YES)
					{
						try
						{
							doChangeSound(f);
						}
						catch (e:Error)
						{
							Alert.show("执行过程中发生错误，操作已取消\n（" + e.message + "）", "错误");
						}
					}
					else
					{
						FlashTip.show("操作已取消");
					}
				});
			}
		}

		/**
		 * @private
		 *
		 */
		private function doChangeSound(source:File):void
		{
			new ChangeFrameSound(doc, keyframes, expectFolder, source).execute();
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

			if (keyframe.sound)
			{
				isPlay = true;
				sa = SoundAsset.get(AvatarInfo.folder + "/" + keyframe.soundPath);
				sa.load();
			}
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
				keyframe.onSoundChange.remove(onSoundPathChange);
			}
			super.keyframes = value;

			if (keyframe)
			{
				keyframe.onSoundChange.add(onSoundPathChange);
			}
			onSoundPathChange();
		}

		/**
		 * @private
		 *
		 */
		private function onSoundPathChange():void
		{
			if (keyframe)
			{
				assetPathField.text = keyframe.sound;
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

		private var _sa:SoundAsset;

		private var isPlay:Boolean;

		/**
		 * 声音资源
		 * @return
		 *
		 */
		public function get sa():SoundAsset
		{
			return _sa;
		}

		public function set sa(value:SoundAsset):void
		{
			if (_sa)
			{
				_sa.removeUser(this);
			}
			_sa = value;

			if (_sa)
			{
				_sa.addUser(this);

				if (_sa.isComplete)
				{
					onAssetLoadComplete(_sa);
				}
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function onAssetDispose(asset:IAsset):void
		{
			_sa = null;
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function onAssetLoadComplete(asset:IAsset):void
		{
			if (isPlay)
			{
				isPlay = false;
				_sa.sound.play();
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function onAssetLoadError(asset:IAsset):void
		{
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function onAssetLoadProgress(asset:IAsset, bytesLoaded:uint, bytesTotal:uint):void
		{
		}
	}
}
