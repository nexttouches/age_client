package ageb.components
{
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.utils.Dictionary;
	import mx.controls.Alert;
	import mx.events.CollectionEvent;
	import mx.events.FlexEvent;
	import spark.events.GridSelectionEvent;
	import age.data.TextureAsset;
	import age.data.TextureAtlasConfig;
	import ageb.modules.Modules;
	import ageb.utils.FileUtil;
	import ageb.utils.FlashTip;
	import nt.assets.IAsset;
	import nt.assets.IAssetUser;

	/**
	 * 贴图浏览器<br>
	 * 提供一个界面，可以快速浏览并选择贴图
	 * @author zhanghaocong
	 *
	 */
	public class TextureBrowser extends TextureBrowserTemplate implements IAssetUser
	{
		private var rects:Dictionary;

		public function TextureBrowser()
		{
			super();
			textures.addEventListener(CollectionEvent.COLLECTION_CHANGE, textures_onChange);
		}

		override protected function openRecent():void
		{
			file = new File(settings.lastTexturePath);
		}

		protected function textures_onChange(event:CollectionEvent):void
		{
			var rect:SubTextureIndicator;

			// 删旧
			for each (rect in rects)
			{
				rect.removeEventListener(MouseEvent.CLICK, rect_onClick);
			}
			rectsGroup.removeAllElements();
			rects = new Dictionary();

			// 增新
			for each (var node:XML in textures)
			{
				rect = new SubTextureIndicator();
				rect.node = node;
				rect.addEventListener(MouseEvent.CLICK, rect_onClick);
				rectsGroup.addElement(rect);
				rects[node] = rect;
			}
		}

		protected function rect_onClick(event:MouseEvent):void
		{
			var rect:SubTextureIndicator = event.currentTarget as SubTextureIndicator;

			if (event.ctrlKey)
			{
				// 反选
				if (texturesField.selectedItems && texturesField.selectedItems.indexOf(rect.node) != -1)
				{
					texturesField.removeSelectedIndex(textures.getItemIndex(rect.node));
				}
				// 新增
				else
				{
					texturesField.addSelectedIndex(textures.getItemIndex(rect.node));
				}
			}
			else
			{
				texturesField.selectedItem = event.currentTarget.node;
			}
			texturesField_onChange();
		}

		override protected function texturesField_onChange(event:GridSelectionEvent = null):void
		{
			for each (var rect:SubTextureIndicator in rects)
			{
				rect.isSelected = false;
			}

			for each (var node:XML in texturesField.selectedItems)
			{
				SubTextureIndicator(rects[node]).isSelected = true;
			}
		}

		override public function browse():void
		{
			FileUtil.browseFile(settings.lastTexturePath, [ new FileFilter("xml 文件", "*.xml")], function(f:File):void
			{
				file = f;
			});
		}

		private var _file:File;

		/**
		 * 设置或获取当前要渲染的文件
		 * @return
		 *
		 */
		public function get file():File
		{
			return _file;
		}

		public function set file(value:File):void
		{
			if (_file)
			{
				asset = null;
			}

			if (!value)
			{
				textures = null;
				return;
			}
			settings.lastTexturePath = value.nativePath;
			openRecentButton.label = "最近打开：" + value.parent.name + "/" + value.name;
			nativePathField.text = value.nativePath;
			var content:XML = FileUtil.readXML(value);

			if (content)
			{
				const SCENE_FOLDER:String = "scenes";
				const AVATARS_FOLDER:String = "avatars";
				var path:String = value.name.split(".")[0];
				// 根据父级目录，判断并创建对应的 Assets
				// 有点 2B
				// 反正没几个类型，就先这样写了
				var a:TextureAsset;

				if (value.parent.name == SCENE_FOLDER)
				{
					a = TextureAsset.get("src/" + SCENE_FOLDER + "/" + path);
					a.useThumb = false;
				}
				else if (value.parent.name == AVATARS_FOLDER)
				{
					Alert.show("只能选择 scene 目录下的背景图片", "错误");
					return;
				}
				else
				{
					Alert.show("没有匹配到资源类型（" + value.nativePath + "）", "错误");
					return;
				}
				TextureAtlasConfig.addAtlas(a.path, content);
				textures.source = TextureAtlasConfig.getAtlas(a.path).children();
				asset = a;
			}
			else
			{
				Alert.show("文件不存在或是空的（" + value.nativePath + "）", "错误");
				return;
			}
			_file = value;
		}

		private var _asset:TextureAsset;

		/**
		 * 设置或获取当前要渲染的 asset
		 * @return
		 *
		 */
		public function get asset():TextureAsset
		{
			return _asset;
		}

		public function set asset(value:TextureAsset):void
		{
			if (_asset)
			{
				_asset.removeUser(this);
				_asset = null;
			}
			_asset = value;

			if (_asset)
			{
				_asset.addUser(this);

				if (_asset.isComplete)
				{
					onAssetLoadComplete(_asset);
				}
				else
				{
					_asset.load();
				}
			}
		}

		protected function get settings():Object
		{
			return Modules.getInstance().settings.getData(this);
		}

		protected function saveSettings():void
		{
			Modules.getInstance().settings.save();
		}

		public function onAssetDispose(asset:IAsset):void
		{
			asset = null;
		}

		public function onAssetLoadComplete(asset:IAsset):void
		{
			bitmap.source = _asset.bitmapData;
		}

		public function onAssetLoadError(asset:IAsset):void
		{
		}

		public function onAssetLoadProgress(asset:IAsset, bytesLoaded:uint, bytesTotal:uint):void
		{
		}

		override protected function onRemove(event:FlexEvent):void
		{
			file = null;
		}

		override protected function importAutoButton_onClick(event:MouseEvent):void
		{
			if (texturesField.selectedIndex == -1)
			{
				FlashTip.show("没有选择任何贴图");
				return;
			}
			onImportAuto.dispatch(selectedTextures);
			onClose(null);
		}

		override protected function importHereButton_onClick(event:MouseEvent):void
		{
			if (texturesField.selectedIndex == -1)
			{
				FlashTip.show("没有选择任何贴图");
				return;
			}
			onImportHere.dispatch(selectedTextures);
			onClose(null);
		}

		private function get selectedTextures():Vector.<String>
		{
			var result:Vector.<String> = new Vector.<String>();

			for each (var node:XML in texturesField.selectedItems)
			{
				result.push(asset.path.split("/").pop() + "#" + node.@name);
			}
			return result;
		}
	}
}
