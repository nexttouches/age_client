package nt.assets.extensions
{
	import nt.assets.IAssetUser;

	/**
	 * IProgressiveImageAssetUser
	 * @author zhanghaocong
	 *
	 */
	public interface IProgressiveImageAssetUser extends IAssetUser
	{
		/**
		 * 当 ProgressiveImageAsset.bitmapData 发生变化时，调用该方法<br>
		 * 当 ProgressiveImageAsset 加载完毕或加载出错时，也会调用该方法<br>
		 * 调用顺序是在 onAssetLoadComplete 或 onAssetLoadError 后
		 * @param asset
		 *
		 */
		function onBitmapDataChange(asset:ProgressiveImageAsset):void;
	}
}
