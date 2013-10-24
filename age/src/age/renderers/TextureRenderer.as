package age.renderers
{
	import flash.events.MouseEvent;
	import age.assets.TextureAsset;
	import nt.assets.IAsset;
	import nt.assets.extensions.IProgressiveImageAssetUser;
	import nt.assets.extensions.ProgressiveImageAsset;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;

	/**
	 * TextureRenderer 是基于 Image 的基本贴图渲染器<br/>
	 * @author zhanghaocong
	 *
	 */
	public class TextureRenderer extends Image3D implements IProgressiveImageAssetUser
	{
		public function TextureRenderer()
		{
			super();
		}

		protected var _onAttach:Signal;

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

		public function onAssetDispose(asset:IAsset):void
		{
		}

		public function onAssetLoadComplete(asset:IAsset):void
		{
		}

		public function onAssetLoadError(asset:IAsset):void
		{
		}

		public function onAssetLoadProgress(asset:IAsset, bytesLoaded:uint, bytesTotal:uint):void
		{
		}

		public function onBitmapDataChange(asset:ProgressiveImageAsset):void
		{
		}
	}
}
