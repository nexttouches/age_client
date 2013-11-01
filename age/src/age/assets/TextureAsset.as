package age.assets
{
	import flash.debugger.enterDebugger;
	import age.AGE;
	import age.utils.updateNativeTexture;
	import nt.assets.Asset;
	import nt.assets.AssetState;
	import nt.assets.extensions.ErrorImage;
	import nt.assets.extensions.ImageAsset;
	import nt.assets.extensions.LazyCallQueue;
	import nt.assets.extensions.ProgressiveImageAsset;
	import starling.textures.ConcreteTexture;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	/**
	 * TextureAsset 表示一个贴图资源<br/>
	 * @author zhanghaocong
	 *
	 */
	public class TextureAsset extends ProgressiveImageAsset
	{
		/**
		 * constructor
		 * @param path
		 * @param priority
		 *
		 */
		public function TextureAsset(path:String, priority:int)
		{
			super(path, priority);
		}

		/**
		 * 获得实际用于创建 TextureAtlas 的类
		 * @return
		 *
		 */
		public function get textureAtlasClass():Class
		{
			return TextureAtlas;
		}

		/**
		 * 获得当前图片的 Texture<br>
		 * 根据加载进度，可能返回 full，thumb 的 texture<br>
		 * 从 thumb 加载到 full 时，会触发 onBitmapDataChange<br>
		 * 内部将自动上传到显卡，所有使用该贴图的对象的显示将得到自动更新<br>
		 * @return
		 *
		 */
		public var texture:starling.textures.Texture;

		private var _textureAtlas:TextureAtlas;

		/**
		 * 贴图集
		 * @return
		 *
		 */
		public function get textureAtlas():TextureAtlas
		{
			// 搜索 textureAtlas
			if (!_textureAtlas)
			{
				if (TextureAtlasConfig.getAtlas(path))
				{
					_textureAtlas = new textureAtlasClass(texture, TextureAtlasConfig.getAtlas(path));
				}
			}
			return _textureAtlas;
		}

		/**
		 * @inheritDoc
		 * @param asset
		 *
		 */
		override protected function onFullComplete(asset:ImageAsset):void
		{
			uploadTexture();
			super.onFullComplete(asset);
		}

		/**
		 * @inheritDoc
		 * @param asset
		 *
		 */
		override protected function onThumbComplete(asset:ImageAsset):void
		{
			uploadTexture();
			super.onThumbComplete(asset);
		}

		/**
		 * （重新）上传贴图到 texture
		 *
		 */
		protected function uploadTexture():void
		{
			if (bitmapData)
			{
				if (!texture)
				{
					if (AGE.s.context.driverInfo != "Disposed")
					{
						try
						{
							texture = Texture.fromBitmapData(bitmapData, false, false, 1);
							Asset.vram += vram;
						}
						catch (error:Error)
						{
							// FIXME 贴图上传失败时需要广播事件
							return;
						}
						texture.root.onRestore = texture_onRestore;
						// 错误图片使用平铺
						texture.repeat = bitmapData == ErrorImage.getInstance();
					}
				}
				else
				{
					updateNativeTexture(texture, bitmapData);
				}
			}
		}

		/**
		 * 恢复 context 时，再次上传贴图
		 *
		 */
		private function texture_onRestore():void
		{
			if (!isDisposed)
			{
				updateNativeTexture(texture, bitmapData);
			}
			else
			{
				texture.root.onRestore = null;
			}
		}

		override public function dispose():void
		{
			if (isDisposed)
			{
				enterDebugger();
			}
			_state = AssetState.DISPOSED;
			Asset.vram -= vram;

			if (_textureAtlas)
			{
				_textureAtlas.dispose();
				_textureAtlas = null;
			}
			texture.root.onRestore = null;
			texture = null;
			texturesCache = null;
			super.dispose();
		}

		/**
		 * 序列帧缓存对象
		 */
		private var texturesCache:Object = {};

		/**
		 * 获得序列帧，自带缓存
		 * @param char
		 *
		 */
		public function getTextures(prefix:String):Vector.<starling.textures.Texture>
		{
			if (!texturesCache[prefix])
			{
				texturesCache[prefix] = textureAtlas.getTextures(prefix);
			}
			return texturesCache[prefix];
		}

		/**
		 * 延迟解码队列
		 */
		private static var decodeQueue:LazyCallQueue = new LazyCallQueue();

		/**
		 * 根据完整路径获得 TextureAsset
		 * @param texturePath
		 * @return
		 *
		 */
		public static function get(texturePath:String):TextureAsset
		{
			return Asset.get(texturePath, 0, TextureAsset) as TextureAsset;
		}

		/**
		 * 返回占用的显存
		 * @return
		 *
		 */
		public function get vram():uint
		{
			return texture ? texture.width * texture.height * 4 : 0;
		}
	}
}
