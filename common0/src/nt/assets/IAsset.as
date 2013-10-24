package nt.assets
{
	import flash.utils.Dictionary;

	/**
	 * IAsset 定义了 Asset 的基本接口
	 * @author zhanghaocong
	 *
	 */
	public interface IAsset
	{
		/**
		 * 增加一个用户
		 * @param user
		 *
		 */
		function addUser(user:IAssetUser):void;
		/**
		 * 删除一个用户
		 * @param user
		 *
		 */
		function removeUser(user:IAssetUser):void;
		/**
		 * 检查是否有指定的用户
		 * @param user
		 * @return
		 *
		 */
		function hasUser(user:IAssetUser):Boolean;
		/**
		 * 释放资源
		 *
		 */
		function dispose():void;
		/**
		 * 正在使用当前 Asset 的用户数
		 * @return
		 *
		 */
		function get numUsers():uint;
		/**
		 * 正在使用当前 Asset 的用户列表
		 * @return
		 *
		 */
		function get users():Dictionary;
		/**
		 * 已加载大小
		 * @return
		 *
		 */
		function get bytesLoaded():uint;
		/**
		 * 总大小
		 * @return
		 *
		 */
		function get bytesTotal():uint;
		/**
		 * Asset 的状态
		 * @see AssetState
		 */
		function get state():int;
		/**
		 * 获取当前 Asset 是否已加载完毕<br>
		 * 加载失败也视作加载完成，但是 isSuccess 应返回 false
		 * @return
		 *
		 */
		function get isComplete():Boolean;
		/**
		 * 获取当前 Asset 是否已加载成功
		 * @return
		 *
		 */
		function get isSuccess():Boolean;
		/**
		 * 是否可以被释放
		 * @return
		 *
		 */
		function get isDisposable():Boolean;
	}
}
