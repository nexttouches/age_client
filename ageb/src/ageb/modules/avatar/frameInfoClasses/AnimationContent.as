package ageb.modules.avatar.frameInfoClasses
{
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.TextInput;
	import spark.primitives.BitmapImage;
	import age.data.AvatarInfo;
	import age.data.TextureAsset;
	import ageb.modules.ae.ActionInfoEditable;
	import ageb.modules.ae.FrameInfoEditable;
	import ageb.modules.avatar.op.ChangeFrameTexture;
	import ageb.utils.FileUtil;
	import ageb.utils.FlashTip;
	import nt.assets.IAsset;
	import nt.assets.extensions.IProgressiveImageAssetUser;
	import nt.assets.extensions.ProgressiveImageAsset;
	import nt.lib.util.assert;

	/**
	 * 类型为 ANIMATION 的 FrameInfo 的面板<br>
	 * 在 VirutalContent 的基础上增加了 texture 属性的操作
	 * @author zhanghaocong
	 *
	 */
	public class AnimationContent extends VirutalContent implements IProgressiveImageAssetUser
	{

		/**
		 * @private
		 */
		[SkinPart(required="true")]
		public var textureField:TextInput;

		/**
		 * @private
		 */
		[SkinPart(required="true")]
		public var texturePreview:BitmapImage;

		/**
		 * @private
		 */
		[SkinPart(required="true")]
		public var texturePreviewGroup:Group;

		/**
		 * @private
		 */
		[SkinPart(required="true")]
		public var browseTextureButton:Button;

		/**
		 * @private
		 */
		[SkinPart(required="true")]
		public var removeTextureButton:Button;

		/**
		 * 创建一个新的 AnimationContent
		 *
		 */
		public function AnimationContent()
		{
			super();
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override protected function get skinClass():Class
		{
			return AnimationContentSkin;
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			browseTextureButton.addEventListener(MouseEvent.CLICK, browseTextureButton_onClick);
			removeTextureButton.addEventListener(MouseEvent.CLICK, removeTextureButton_onClick);
		}

		/**
		 * @private
		 * @param event
		 *
		 */
		protected function removeTextureButton_onClick(event:MouseEvent):void
		{
			doChangeTexture(new Vector.<File>);
		}

		/**
		 * 浏览贴图<br>
		 * 满足一定条件可以多选更换贴图
		 * @param event
		 *
		 */
		protected function browseTextureButton_onClick(event:MouseEvent):void
		{
			if (keyframes.length == 1 || isCrossLayer)
			{
				FileUtil.browseFile(expectFolder.nativePath, [ new FileFilter("PNG Files", "*.png")], onBrowseComplete);
			}
			else
			{
				FileUtil.browseFileMultiple(expectFolder.nativePath, [ new FileFilter("PNG Files", "*.png")], onBrowseComplete);
			}
		}

		/**
		 * 期待的目录，所有的贴图文件应在该目录下
		 */
		public var expectFolder:File;

		/**
		 * 检查文件列表是否在期待的目录中
		 * @param f
		 * @return
		 *
		 */
		public function isInExpectFolder(files:Vector.<File>):Boolean
		{
			for (var i:int = 0; i < files.length; i++)
			{
				const f:File = files[i] as File;

				if (expectFolder.nativePath != f.parent.nativePath)
				{
					return false;
				}
			}
			return true;
		}

		private function onBrowseComplete(files:*):void
		{
			// 单个打开的情况下不是数组，做个兼容
			if (files is File)
			{
				files = new <File>[ files ];
			}

			if (isInExpectFolder(files))
			{
				doChangeTexture(files);
			}
			else
			{
				Alert.show("选择的图片不在动作目录中，要复制过去吗？", "提示", Alert.YES | Alert.CANCEL, null, function(event:CloseEvent):void
				{
					if (event.detail == Alert.YES)
					{
						try
						{
							doChangeTexture(files);
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
		 * 更换贴图
		 * @param files 要更换的贴图，如果长度为 0 表示删除贴图
		 *
		 */
		private function doChangeTexture(files:Vector.<File>):void
		{
			assert(!!files, "files 不能为 null");
			new ChangeFrameTexture(doc, keyframes, expectFolder, files).execute();
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
				expectFolder = null;
				keyframe.onTextureChange.remove(onTextureChange);
			}
			super.keyframes = value;

			if (keyframe)
			{
				expectFolder = ActionInfoEditable(keyframe.parent.parent).expectFolder;
				keyframe.onTextureChange.add(onTextureChange);
			}
			onTextureChange();
		}

		/**
		 * @private
		 *
		 */
		private function onTextureChange():void
		{
			if (keyframe && keyframe.texture)
			{
				ta = TextureAsset.get(AvatarInfo.folder + "/" + keyframe.texturePath);
				ta.useThumb = false;
				ta.load();
			}
			else
			{
				ta = null;
			}
		}

		private var _ta:TextureAsset;

		/**
		 * 设置或获取当前渲染的贴图
		 * @return
		 *
		 */
		public function get ta():TextureAsset
		{
			return _ta;
		}

		public function set ta(value:TextureAsset):void
		{
			if (_ta)
			{
				textureField.text = "";
				_ta.removeUser(this);
				onBitmapDataChange(null);
			}
			_ta = value;

			if (_ta)
			{
				textureField.text = keyframe.texture;
				_ta.addUser(this);

				if (_ta.isComplete)
				{
					onBitmapDataChange(_ta);
				}
			}
		}

		/**
		 * @inheritDoc
		 * @param asset
		 *
		 */
		public function onAssetDispose(asset:IAsset):void
		{
			ta = null;
		}

		/**
		 * @inheritDoc
		 * @param asset
		 *
		 */
		public function onAssetLoadComplete(asset:IAsset):void
		{
		}

		/**
		 * @inheritDoc
		 * @param asset
		 *
		 */
		public function onAssetLoadError(asset:IAsset):void
		{
		}

		/**
		 * @inheritDoc
		 * @param asset
		 *
		 */
		public function onAssetLoadProgress(asset:IAsset, bytesLoaded:uint, bytesTotal:uint):void
		{
		}

		/**
		 * @inheritDoc
		 * @param asset
		 *
		 */
		public function onBitmapDataChange(asset:ProgressiveImageAsset):void
		{
			if (asset)
			{
				texturePreview.source = _ta.bitmapData;
				texturePreview.width = _ta.bitmapData.width;
				texturePreview.height = _ta.bitmapData.height;
			}
			else
			{
				texturePreview.source = null;
				texturePreview.width = 0;
				texturePreview.height = 0;
			}
		}
	}
}
