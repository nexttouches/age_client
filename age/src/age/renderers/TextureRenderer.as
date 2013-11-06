package age.renderers
{
	import age.data.TextureAsset;
	import nt.assets.IAsset;
	import nt.assets.extensions.IProgressiveImageAssetUser;
	import nt.assets.extensions.ProgressiveImageAsset;
	import org.osflash.signals.Signal;

	/**
	 * TextureRenderer 是基于 Image 的基本贴图渲染器<br/>
	 * @author zhanghaocong
	 *
	 */
	public class TextureRenderer extends Image3D implements IProgressiveImageAssetUser
	{
		/**
		 * constructor
		 *
		 */
		public function TextureRenderer()
		{
			super();
		}

		protected var _onAttach:Signal;

		/**
		 * 贴图显示时调用
		 * @return
		 *
		 */
		public function get onAttach():Signal
		{
			return _onAttach ||= new Signal(AnimationLayerRenderer);
		}

		protected var _asset:TextureAsset;

		/**
		 * 设置或获取要渲染的 asset
		 */
		final public function get asset():TextureAsset
		{
			return _asset;
		}

		/**
		 * @private
		 */
		public function set asset(value:TextureAsset):void
		{
			attach(value);

			if (!_asset) // 使用空 Texture
			{
				setTexture(emptyTexture);
			}
		}

		/**
		 * 设置新贴图
		 * @param newAsset
		 *
		 */
		protected function attach(newAsset:TextureAsset):void
		{
			if (_asset)
			{
				_asset.removeUser(this);
			}
			_asset = newAsset;

			if (_asset)
			{
				_asset.addUser(this);

				// 如果已完成马上刷一下贴图
				if (_asset.isComplete)
				{
					onAssetLoadComplete(_asset);
				}
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function onAssetDispose(asset:IAsset):void
		{
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function onAssetLoadComplete(asset:IAsset):void
		{
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

		/**
		 * @inheritDoc
		 *
		 */
		public function onBitmapDataChange(asset:ProgressiveImageAsset):void
		{
		}
	}
}
