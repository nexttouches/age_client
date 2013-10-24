package age.extensions
{
	import nt.assets.IAsset;
	import nt.assets.IAssetUser;

	internal class DummyUser implements IAssetUser
	{
		public function DummyUser()
		{
		}

		private var _asset:IAsset;

		public function get asset():IAsset
		{
			return _asset;
		}

		public function set asset(value:IAsset):void
		{
			if (_asset)
			{
				_asset.removeUser(this);
			}
			_asset = value;

			if (_asset)
			{
				_asset.addUser(this);
			}
		}

		public function onAssetLoadComplete(asset:IAsset):void
		{
		}

		public function onAssetDispose(asset:IAsset):void
		{
			// asset 主动调用 dispose
			// 只需解引用
			// 一般来说不会发生该状况
			_asset = null;
		}

		public function onAssetLoadError(asset:IAsset):void
		{
		}

		public function onAssetLoadProgress(asset:IAsset, bytesLoaded:uint, bytesTotal:uint):void
		{
		}
	}
}
