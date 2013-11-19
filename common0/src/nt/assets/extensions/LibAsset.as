package nt.assets.extensions
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import nt.assets.Asset;
	import nt.assets.AssetState;

	/**
	 * 用于加载库的 Asset
	 * @author KK
	 *
	 */
	public class LibAsset extends Asset
	{
		/**
		 * 用于加载内容的 Loader
		 */
		protected var loader:Loader;

		/**
		 * 加载时使用的 LoaderContext
		 */
		protected var context:LoaderContext;

		/**
		 * constructor
		 * @param path
		 * @param priority
		 *
		 */
		public function LibAsset(path:String, priority:int)
		{
			super(path, priority);
		}

		/**
		 * @inheritDoc
		 * @param event
		 *
		 */
		protected override function onComplete(event:Event):void
		{
			// 读取全部字节后
			stream.readBytes(raw);
			// 回收掉 stream 占的内存
			removeStream();
			// 再利用 loader 转换成类
			addLoader();
		}

		/**
		 * 创建 Loader
		 *
		 */
		protected function addLoader():void
		{
			if (loader)
			{
				throw new Error("loader 已存在，不能重复调用 addLoader");
			}
			context = createLoaderContext();
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_onComplete);
			loader.loadBytes(raw, context);
		}

		/**
		 * 创建 LoaderContext
		 * @return
		 *
		 */
		protected function createLoaderContext():LoaderContext
		{
			var result:LoaderContext = new LoaderContext(false, new ApplicationDomain(ApplicationDomain.currentDomain));
			result.allowCodeImport = true;
			return result;
		}

		/**
		 * Loader 加载完毕时回调
		 * @param event
		 *
		 */
		protected function loader_onComplete(event:Event):void
		{
			if (isDisposed)
			{
				return;
			}
			// raw 已经没用了，可以先清掉，但是要保留引用，否则 dispose 时会出错
			raw.clear();
			raw = null;
			// loader 也没用了
			removeLoader();
			// 标记为加载完毕
			_state = AssetState.LOADED;
			// 通知其他用户
			notifyLoadComplete();
		}

		/**
		 * 删除 Loader
		 *
		 */
		protected function removeLoader():void
		{
			if (!loader)
			{
				throw new Error("loader 不存在，不能重复调用 removeLoader");
			}
			loader.unloadAndStop(true);
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loader_onComplete);
			loader = null;
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
			_state = AssetState.DISPOSED;
			context = null;
			removeRef();
			notifyDispose();

			if (loader)
			{
				removeLoader();
			}

			if (stream)
			{
				removeStream();
			}

			if (raw)
			{
				removeRaw();
			}
			trace("[Lib] 已释放 " + path);
		}

		/**
		 * 从当前库中获得一个 Class
		 * @param name
		 * @return
		 *
		 */
		public function getClass(name:String):Class
		{
			return getDefintion(name) as Class;
		}

		/**
		 * 从当前库中获得一个 Function
		 * @param name
		 * @return
		 *
		 */
		public function getFunction(name:String):Function
		{
			return getDefintion(name) as Function;
		}

		/**
		 * 检查当前库中是否有 name 的定义
		 * @param name
		 * @return
		 *
		 */
		public function hasDefintion(name:String):Boolean
		{
			return context.applicationDomain.hasDefinition(name);
		}

		/**
		 * 从当前库中获得一个定义，如果没有加载完毕会报错
		 * @param name
		 * @return
		 *
		 */
		protected function getDefintion(name:String):*
		{
			if (_state != AssetState.LOADED)
			{
				throw new Error("尚未加载完毕或已被回收");
			}
			return context.applicationDomain.getDefinition(name);
		}

		/**
		 * 当前库的 domain
		 * @return
		 *
		 */
		public function get domain():ApplicationDomain
		{
			return context.applicationDomain;
		}

		/**
		 * 根据路径获得 <tt>LibAsset</tt>
		 * @param path 相对于 <tt>AssetConfig.root</tt> 的路径
		 * @return
		 *
		 */
		public static function get(path:String):LibAsset
		{
			return Asset.get(path, 0, LibAsset) as LibAsset;
		}
	}
}
