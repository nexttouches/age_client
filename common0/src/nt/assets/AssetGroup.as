package nt.assets
{
	import flash.system.Capabilities;

	/**
	 * AssetGroup 表示一组 Asset，提供了一些诸如统计下载进度之类的实用方法，是更接近视图的实现
	 * @author zhanghaocong
	 *
	 */
	public class AssetGroup extends AbstractAsset implements IAssetUser
	{
		/**
		* 当前 group 关联的 assets，可通过调用 dispose 取消所有关联
		*/
		public var assets:Vector.<Asset>;

		/**
		 * 创建一个新的 AssetGroup
		 * @param assets 可选，一组 Asset
		 *
		 */
		public function AssetGroup(assets:Vector.<Asset> = null)
		{
			if (assets != null)
			{
				for (var i:int = 0; i < assets.length; i++)
				{
					addAsset(assets[i]);
				}
			}
		}

		/**
		 * 加载组里所有资源
		 * @param queue
		 *
		 */
		override public function load(queue:AssetLoadQueue = null):void
		{
			// 空的组，直接退
			if (!assets)
			{
				return;
			}

			// 如果该组已经下载完成，则可以提早处理
			if (isComplete)
			{
				for each (var user:IAssetUser in _users)
				{
					user.onAssetLoadComplete(this);
				}
				return;
			}

			if (!queue)
			{
				queue = AssetLoadQueue.get();
			}
			assets.sort(sortByPriority);
			var n:int = assets.length;

			for (var i:int = 0; i < n; i++)
			{
				queue.addAsset(assets[i]);

				if (assets[i].isComplete)
				{
					onAssetLoadComplete(assets[i]);
				}
			}
		}

		/**
		 * 添加一个路径，重复添加会报错
		 * @param path
		 *
		 */
		public function addPath(path:String, priority:int = 0):Asset
		{
			var result:Asset = Asset.get(path, priority || -assets.length)
			addAsset(result);
			return result;
		}

		/**
		 * 添加一个 asset，重复添加会报错
		 * @param asset
		 *
		 */
		public function addAsset(asset:IAsset):void
		{
			if (!assets)
			{
				assets = new Vector.<Asset>;
			}

			if (assets.indexOf(asset) == -1 && _currentLoadings.indexOf(asset) == -1)
			{
				assets.push(asset);
				asset.addUser(this);
				_bytesTotal += asset.bytesTotal;
			}
			else
			{
				if (Capabilities.isDebugger)
				{
					trace("[AssetGroup] 已忽略重复", asset);
				}
			}
		}

		/**
		 * 清空当前组下所有的 assets
		 *
		 */
		public function empty():void
		{
			const n:int = length;

			for (var i:int = 0; i < n; i++)
			{
				assets[i].removeUser(this);
			}

			if (n > 0)
			{
				assets.length = 0;
			}
			_currentLoadings.length = 0;
			_lastCompleted = null;
			_bytesTotal = 0;
		}

		protected var _lastCompleted:IAsset;

		/**
		 * 在当前组中获得最后一个完成了的 Asset，如果为 null 说明一个都没有完成
		 * @return
		 *
		 */
		public function get lastCompleted():IAsset
		{
			return _lastCompleted;
		}

		protected var _currentLoadings:Vector.<Asset> = new Vector.<Asset>;

		/**
		 * 在当前组中获得正在加载的 Assets<br/>
		 * length 为 0 表示当前没有任何 asset 正在加载
		 * @return
		 *
		 */
		public function get currentLoadings():Vector.<Asset>
		{
			return _currentLoadings;
		}

		/**
		 * [实时统计] 获得当前组已经失败的数目
		 * @return
		 *
		 */
		public function get numFailed():int
		{
			var result:int = 0;

			for each (var a:Asset in assets)
			{
				if (a.isError)
				{
					result++;
				}
			}
			return result;
		}

		/**
		 * [实时统计] 获取当前组已经完成的数目
		 */
		public function get numCompleted():int
		{
			var result:int = 0;

			for each (var a:Asset in assets)
			{
				if (a.isComplete)
				{
					result++;
				}
			}
			return result;
		}

		/**
		 * 获得当前组中 Asset 数目
		 * @return
		 *
		 */
		public function get length():uint
		{
			return assets ? assets.length : 0;
		}

		/**
		 * 获得当前组是否已完成<br>
		 * 下载失败的也视作完成
		 * @return
		 *
		 */
		override public function get isComplete():Boolean
		{
			return length != 0 && length == (numCompleted + numFailed);
		}

		/**
		 * 检查当前组是否为空<br>
		 * 当 length == 0 时，返回 true
		 * @return
		 *
		 */
		public function get isEmpty():Boolean
		{
			return length == 0;
		}

		/**
		 * 设定只要有一个或多个资源被释放，整个组也要被释放
		 * @param asset
		 *
		 */
		public function onAssetDispose(asset:IAsset):void
		{
			dispose();
		}

		/**
		 * 本组 assets 全部下载完毕后广播所有用户
		 * @param asset
		 *
		 */
		public function onAssetLoadComplete(asset:IAsset):void
		{
			_lastCompleted = asset;
			// 从 currentLoadings 中删除 asset
			var index:int = _currentLoadings.indexOf(asset);

			// 如果为 -1 表示这个资源早已完成
			if (index >= 0)
			{
				_currentLoadings.splice(index, 1);
			}

			// 全部加载完毕后广播完成事件
			if (isComplete)
			{
				for each (var user:IAssetUser in _users)
				{
					user.onAssetLoadComplete(this);
				}
			}
		}

		/**
		 * 有一个或多个 assets 下载发生错误时广播给所有用户
		 * @param asset
		 *
		 */
		public function onAssetLoadError(asset:IAsset):void
		{
			// 从 currentLoadings 中删除 asset
			var index:int = _currentLoadings.indexOf(asset);

			// -1 一般是 404 错误，否则是下载中断，这里要清掉数组里的 asset
			if (index != -1)
			{
				_currentLoadings.splice(index, 1);
			}

			// 通知所有用户出错了
			for each (var user:IAssetUser in _users)
			{
				user.onAssetLoadError(this);
			}
		}

		/**
		 * 加载进度发生变化时，把当前组的加载进度广播给所有用户
		 * @param asset
		 * @param bytesLoaded
		 * @param bytesTotal
		 *
		 */
		public function onAssetLoadProgress(asset:IAsset, bytesLoaded:uint, bytesTotal:uint):void
		{
			// 往 _currentLoadings 里加入 asset
			var index:int = _currentLoadings.indexOf(asset);
			_bytesLoaded = 0;

			// 统计总已加载字节数
			for each (var asset:IAsset in assets)
			{
				_bytesLoaded += asset.bytesLoaded;
			}

			// 不重复添加
			if (index == -1)
			{
				_currentLoadings.push(asset);
			}

			// 这里广播的是当前组的加载进度
			for each (var user:IAssetUser in _users)
			{
				user.onAssetLoadProgress(this, _bytesLoaded, _bytesTotal);
			}
		}

		/**
		 * 释放资源，这会使 AssetGroup 取消对所有 Asset 的关联，并且通知所有用户<br>
		 * 该方法<b>并不会</b>释放其下的其他资源
		 *
		 */
		override public function dispose():void
		{
			// 通知所有 user
			for each (var user:IAssetUser in _users)
			{
				user.onAssetDispose(this);
			}
			empty();
			// 最后取消所有用户的关联
			super.dispose();
		}

		/**
		 * 用于按优先级排序的东西
		 * @param a
		 * @param b
		 * @return
		 *
		 */
		internal static function sortByPriority(a:Asset, b:Asset):Number
		{
			return b.priority - a.priority;
		}

		/**
		 * 获得当前组中所有 Asset 是否已完成
		 * @return
		 *
		 */
		override public function get isSuccess():Boolean
		{
			return length == numCompleted;
		}
	}
}
