package nt.assets
{

	/**
	 * IAssetUser 是 Asset 的使用者
	 * @author zhanghaocong
	 *
	 */
	public interface IAssetUser
	{
		/**
		 * asset 加载完毕后的回调方法
		 * @param asset
		 *
		 */
		function onAssetLoadComplete(asset:IAsset):void;
		/**
		 * asset 被回收后的回调方法
		 * @param asset
		 *
		 */
		function onAssetDispose(asset:IAsset):void;
		/**
		 * asset 加载出现错误时的回调方法
		 * @param asset
		 *
		 */
		function onAssetLoadError(asset:IAsset):void;
		/**
		 * asset 加载过程中的回调方法
		 * @param asset
		 *
		 */
		function onAssetLoadProgress(asset:IAsset, bytesLoaded:uint, bytesTotal:uint):void;
	}
}
