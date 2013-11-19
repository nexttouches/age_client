package nt.assets
{

	/**
	 * 资源下载类，主要负责按一定顺序加载指定的资源<br/>
	 * 如果要观察一组资源的加载情况，请使用 AssetGroup<br>
	 * 如果要观察单个资源的加载情况，请直接使用该资源
	 * @author zhanghaocong
	 *
	 */
	final public class AssetLoadQueue implements IAssetUser
	{
		/**
		 * 名字
		 */
		public var name:String;

		/**
		 * 运行中的线程数
		 */
		public var threadsRunning:int;

		/**
		 * 同时加载的线程数
		 */
		public var threadsMax:int;

		/**
		 * 加载队列的状态
		 */
		private var state:int;

		/**
		 * 等待加载的 assets
		 */
		private var assets:Vector.<Asset> = new Vector.<Asset>;

		/**
		 * 创建一个新的 AssetLoadQueue
		 * @param name 名字
		 * @param threadsMax 最大线程数
		 *
		 */
		public function AssetLoadQueue(name:String, threadsMax:int)
		{
			this.name = name;
			this.threadsMax = threadsMax;
		}

		/**
		 * 添加一个 Asset，重复添加及正在加载中的资源将被忽略
		 * @param asset
		 *
		 */
		public function addAsset(asset:Asset):void
		{
			// 资源正在加载或已经完毕，直接跳过（不出提示）
			if (!asset.isNotLoaded)
			{
				return;
			}

			// 检查是否在队列中
			if (assets.indexOf(asset) == -1)
			{
				assets.push(asset);
				asset.addUser(this);
				loadNext();
			}
			else
			{
				trace("[Queue] 该资源已在加载队列中，忽略 (" + asset.path + ")");
			}
		}

		/**
		 * 空闲中的线程数
		 * @return
		 *
		 */
		public function get threadsIdle():int
		{
			return threadsMax - threadsRunning;
		}

		/**
		 * 加载下一个
		 *
		 */
		private function loadNext():void
		{
			if (threadsIdle > 0)
			{
				assets.sort(AssetGroup.sortByPriority);

				while (threadsIdle > 0)
				{
					if (assets.length > 0)
					{
						var asset:Asset = assets.shift();

						// 跳过已完成的资源
						if (asset.state != AssetState.NOT_LOADED)
						{
							onAssetLoadComplete(asset);
						}
						else
						{
							threadsRunning++;
							asset.loadNow();

							if (state != AssetLoaderState.Busy)
							{
								state = AssetLoaderState.Busy;
							}
						}
					}
					else
					{
						if (state != AssetLoaderState.Idle)
						{
							state = AssetLoaderState.Idle;
						}
						break;
					}
				}
			}
		}

		/**
		 * @inheritDoc
		 * @param asset
		 *
		 */
		public function onAssetLoadError(asset:IAsset):void
		{
			// 出现任何错误直接进入下一个
			asset.removeUser(this);
			threadsRunning--;
			loadNext();
		}

		/**
		 * @inheritDoc
		 * @param asset
		 *
		 */
		public function onAssetLoadProgress(asset:IAsset, bytesLoaded:uint, bytesTotal:uint):void
		{
			// 不侦听加载进度
		}

		/**
		 * @inheritDoc
		 * @param asset
		 *
		 */
		public function onAssetDispose(asset:IAsset):void
		{
			// 任何加载中的资源或没有加载的资源都不应被释放
			// 此时应该是出错了
			// 需开发者检查
			throw new Error("不应该进到这里");
		}

		/**
		 * @inheritDoc
		 * @param asset
		 *
		 */
		public function onAssetLoadComplete(asset:IAsset):void
		{
			// 加载成功后进入下一个
			asset.removeUser(this);
			threadsRunning--;
			loadNext();
		}

		/**
		 * 默认线程数
		 */
		public static const DefaultThreads:int = 2;

		/**
		 * 储存所有 AssetLoadQueue 实例
		 */
		private static var instances:Object = {};

		/**
		 * 得到一个 AssetLoader 的实例
		 * @param name
		 * @return
		 *
		 */
		public static function get(name:String = AssetLoaderNames.BlockUserOperation, threadsMax:int = DefaultThreads):AssetLoadQueue
		{
			if (!instances.hasOwnProperty(name))
			{
				instances[name] = new AssetLoadQueue(name, threadsMax);
			}
			return instances[name];
		}
	}
}
