package nt.assets.extensions
{
	import flash.display.BitmapData;
	import nt.assets.Asset;
	import nt.assets.AssetLoadQueue;
	import nt.assets.AssetState;
	import nt.assets.IAsset;
	import nt.assets.IAssetUser;

	/**
	 * 渐进式的下载图片<br>
	 * 和一般图片不同的是，他会先下载带有 _thumb 后缀的小图，然后再下载大图<br>
	 * 小图加载完成后视为加载完成，提示 onAssetComplete() 和 onBitmapDataChange()<br>
	 * 大图加载完成后，提示 onBitmapDataChange()<br>
	 * @author zhanghaocong
	 * @see IProgressiveImageAssetUser
	 */
	public class ProgressiveImageAsset extends Asset implements IAssetUser
	{
		/**
		 * 小图的后缀（不含扩展名）
		 */
		public static const THUMB_SURFIX:String = "_thumb";

		/**
		 * 小图后缀（含扩展名）
		 */
		public static const THUMB_EXTENSION:String = THUMB_SURFIX + ".png";

		/**
		 * 点
		 */
		public static const DOT:String = ".";

		/**
		 * 斜杠
		 */
		public static const SLASH:String = "/";

		/**
		 * 下划线
		 */
		public static const UNDERLINE:String = "_";

		/**
		 * TextureAsset 的自定义扩展名是 png
		 */
		public static const EXTENSION:String = "png";

		/**
		 * 小图
		 */
		public var thumb:ImageAsset;

		/**
		 * 原图
		 */
		public var full:ImageAsset;

		/**
		 * 设置是否下载小图<br>
		 * 默认使用
		 */
		public var useThumb:Boolean = true;

		/**
		 * constructor
		 * @param path
		 * @param priority
		 *
		 */
		public function ProgressiveImageAsset(path:String, priority:int)
		{
			super(path, priority);
			// 分别创建小图和大图
			full = createFull();
			full.addUser(this);

			// 如果大图没有完成才需要创建小图
			if (!full.isComplete)
			{
				thumb = createThumb();
				thumb.addUser(this);
			}
		}

		/**
		 * 获得当前图片的 bitmapData<br>
		 * 根据加载进度，可能返回 full，thumb 的 bitmapData<br>
		 * 当 bitmapData 发生变化时，将触发 onBitmapDataChange
		 * @return
		 *
		 */
		public function get bitmapData():BitmapData
		{
			if (full.isComplete)
			{
				return full.result;
			}
			else if (thumb.isComplete)
			{
				return thumb.result;
			}
			return null;
		}

		/**
		 * 创建小图，如果没有小图，可以返回 null<br/>
		 * 子类可以覆盖该方法创建自己的小图<br/>
		 * 默认情况下，将自动添加 _thumb 后缀作为缩略图名字<br>
		 * 如 foo/bar 的资源将获得 foo/bar_thumb.png 作为 thumb, foo/bar.png 作为完整图片
		 * @return
		 *
		 */
		protected function createThumb():ImageAsset
		{
			// 此处 path 不含扩展名
			return Asset.get(path + THUMB_EXTENSION, 0, ImageAsset) as ImageAsset;
		}

		/**
		 * 删除 thumb
		 * @param isDispose
		 * @return
		 *
		 */
		protected function removeThumb(needDispose:Boolean = false):void
		{
			if (thumb)
			{
				thumb.removeUser(this);

				if (needDispose)
				{
					if (thumb.isDisposable)
					{
						thumb.dispose();
					}
					else
					{
						thumb.printDebugInfo("无法主动释放 thumb", thumb.path);
					}
				}
				thumb = null;
			}
		}

		/**
		 * 创建大图
		 * @return
		 *
		 */
		protected function createFull():ImageAsset
		{
			return Asset.get(path + DOT + EXTENSION, int.MAX_VALUE, ImageAsset) as ImageAsset;
		}

		/**
		 * 删除 full
		 * @param isDispose
		 * @return
		 *
		 */
		protected function removeFull(needDispose:Boolean = false):void
		{
			if (full)
			{
				full.removeUser(this);

				if (needDispose)
				{
					if (full.isDisposable)
					{
						full.dispose();
					}
					else
					{
						full.printDebugInfo("无法主动释放 thumb", full.path);
					}
				}
				full = null;
			}
		}

		/**
		 * AssetLoadQueue 加载的时候调用该方法<br>
		 * 这边覆盖掉，增加一些逻辑
		 *
		 */
		override public function doLoad():void
		{
			if (_state != AssetState.NOT_LOADED)
			{
				return;
			}

			// 大图完毕 - 复制状态跳过
			if (full.isComplete)
			{
				onAssetLoadComplete(full);
				return;
			}

			// 小图完毕 - 复制状态跳过
			if (thumb.isComplete)
			{
				onAssetLoadComplete(thumb);
				return;
			}

			// 小图载入中 - 复制状态跳过
			if (thumb.isLoading)
			{
				_state = thumb.state;
				return;
			}

			// 使用小图
			if (useThumb)
			{
				// 小图未好 - 复制状态，载小图
				thumb.doLoad();
				_state = thumb.state;
			}
			else
			{
				full.doLoad();
				_state = full.state;
			}
		}

		/**
		 * @inheritDoc
		 * @param asset
		 *
		 */
		public function onAssetDispose(asset:IAsset):void
		{
			switch (asset)
			{
				case thumb:
					thumb.removeUser(this);
					thumb = null;
					break;
				case full:
					full.removeUser(this);
					full = null;
				default:
					throw new ArgumentError("asset 不是可接受的类型");
					break;
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function onAssetLoadComplete(asset:IAsset):void
		{
			_state = AssetState.LOADED;

			switch (asset)
			{
				case thumb:
					onThumbComplete(asset as ImageAsset);
					break;
				case full:
					onFullComplete(asset as ImageAsset);
					break;
				default:
					throw new ArgumentError("asset 不是可接受的类型");
					break;
			}
		}

		/**
		 * 大图加载完毕
		 * @param asset
		 *
		 */
		protected function onFullComplete(asset:ImageAsset):void
		{
			notifyBitmapDataChange();

			if (!useThumb)
			{
				notifyLoadComplete();
			}
			// 大图完成后就不需要小图了
			removeThumb();
		}

		/**
		 * 小图加载完毕
		 * @param asset
		 *
		 */
		protected function onThumbComplete(asset:ImageAsset):void
		{
			notifyLoadComplete();
			notifyBitmapDataChange();

			// 利用独立线程加载大图
			if (!full.isComplete)
			{
				full.load(AssetLoadQueue.get("FullAsset2", 2));
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function dispose():void
		{
			if (!isDisposable)
			{
				printDebugInfo(null, path);
				throw new Error("资源无法被释放");
			}
			// 此时 thumb 应只有一个用户 this
			removeThumb(true);
			// 此时 full 应只有一个用户 this
			removeFull(true);
			removeRef();
			notifyDispose();
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function onAssetLoadError(asset:IAsset):void
		{
			// thumb 和 full 是 ImageAsset，是不会出现加载错误的。这里不做任何事。
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function onAssetLoadProgress(asset:IAsset, bytesLoaded:uint, bytesTotal:uint):void
		{
			switch (asset)
			{
				case thumb:
					// 复制小图的加载进度作为当前资源的加载进度
					_bytesLoaded = asset.bytesLoaded;
					_bytesTotal = asset.bytesTotal;
					notifyLoadProgress();
					break;
				case full:
					// 没有小图的话，复制大图的进度作为当前资源的进度
					if (!thumb)
					{
						_bytesLoaded = asset.bytesLoaded;
						_bytesTotal = asset.bytesTotal;
						notifyLoadProgress();
					}
					else
					{
						// 不做任何事
					}
					break;
				default:
					throw new ArgumentError("asset 不是可接受的类型");
					break;
			}
		}

		/**
		 * 提示所有用户 bitmapData 变化
		 *
		 */
		protected function notifyBitmapDataChange():void
		{
			trace("[ProgressiveImageAsset] onBitmapDataChange " + info.url, "(", int(bytesLoaded / 1024), "k)");

			for each (var user:IAssetUser in _users)
			{
				if (user is IProgressiveImageAssetUser)
				{
					IProgressiveImageAssetUser(user).onBitmapDataChange(this);
				}
			}
		}

		/**
		 * 延迟解码队列，用来缓解顺卡的问题
		 */
		private static var decodeQueue:LazyCallQueue = new LazyCallQueue();

		/**
		 * 根据完整路径获得 ProgressiveImage<br>
		 * 该路径<strong>不包含</strong>png 的后缀名
		 * @param texturePath
		 * @return
		 *
		 */
		public static function get(texturePath:String):ProgressiveImageAsset
		{
			var result:ProgressiveImageAsset = Asset.get(texturePath, 0, ProgressiveImageAsset) as ProgressiveImageAsset
			return result;
		}
	}
}
