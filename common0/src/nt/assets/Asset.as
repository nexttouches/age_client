package nt.assets
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import nt.assets.util.URLUtil;

	/**
	 * Asset 表示一个可以加载的资源
	 * @author zhanghaocong
	 *
	 */
	public class Asset extends AbstractAsset
	{
		/**
		 * 实际用于处理加载的 URLStream
		 */
		protected var stream:URLStream

		/**
		 * 相对于资源目录的路径
		 */
		public var path:String;

		/**
		 * 下载了的原始数据
		 */
		public var raw:ByteArray;

		/**
		 * 设置或获取当前 Asset 的优先级
		 */
		public var priority:int;

		/**
		 * constructor
		 *
		 */
		public function Asset(path:String, priority:int)
		{
			this.path = path;
			this.priority = priority;
			_state = AssetState.NotLoaded;
			_bytesTotal = info.size;
		}

		/**
		 * 把当前 Asset 加入到指定的队列中
		 * @param queue
		 *
		 */
		override public function load(queue:AssetLoadQueue = null):void
		{
			if (!queue)
			{
				queue = AssetLoadQueue.get();
			}
			queue.addAsset(this);
		}

		/**
		 * 实际由 AssetLoadQueue 调用实际用于加载的方法
		 *
		 */
		public function loadNow():void
		{
			if (_state != AssetState.NotLoaded)
			{
				return;
			}
			trace("[Asset] 正在加载", info.url);
			_state = AssetState.Loading;
			addStream();
			raw = new ByteArray();

			try
			{
				stream.load(new URLRequest(info.url));
			}
			catch (error:Error)
			{
				onIOError(null);
			}
		}

		/**
		 * 创建 stream
		 *
		 */
		protected function addStream():void
		{
			stream = new URLStream();
			stream.addEventListener(Event.COMPLETE, onComplete);
			stream.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			stream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			stream.addEventListener(ProgressEvent.PROGRESS, onProgress);
		}

		/**
		 * 删除 stream
		 *
		 */
		protected function removeStream():void
		{
			if (!stream)
			{
				throw new Error("stream 不存在");
			}

			try
			{
				stream.close();
			}
			catch (error:Error)
			{
			}
			stream.removeEventListener(Event.COMPLETE, onComplete);
			stream.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			stream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			stream.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			stream = null;
		}

		/**
		 * @private
		 *
		 */
		protected function onProgress(event:ProgressEvent):void
		{
			_bytesLoaded = event.bytesLoaded;

			if (_bytesTotal == 0)
			{
				_bytesTotal = event.bytesTotal;
			}
			notifyLoadProgress();
		}

		/**
		 * @private
		 *
		 */
		protected function onSecurityError(event:SecurityErrorEvent):void
		{
			_state = AssetState.Error;
			trace("[Asset] Security Error " + info.url);
			notifyLoadError();
		}

		/**
		 * @private
		 *
		 */
		protected function onIOError(event:IOErrorEvent):void
		{
			_state = AssetState.Error;
			trace("[Asset] IO Error " + info.url);
			notifyLoadError();
		}

		/**
		 * @private
		 *
		 */
		protected function onComplete(event:Event):void
		{
			stream.readBytes(raw);
			_state = AssetState.Loaded;
			notifyLoadComplete();
		}

		/**
		 * 调用后可以释放该资源<br>
		 * 如果该资源的用户数目大于 1 将会抛错
		 *
		 */
		override public function dispose():void
		{
			if (!isDisposable)
			{
				printDebugInfo(null, path);
				throw new Error("资源无法被释放");
			}
			removeRef();
			notifyDispose();
			removeStream();
			removeRaw();
			trace("[Asset] 已释放 " + path);
		}

		/**
		 * @private
		 *
		 */
		protected function removeRaw():void
		{
			raw.clear();
			raw = null;
		}

		/**
		 * @private
		 *
		 */
		protected function removeRef():void
		{
			delete assets[path];
		}

		/**
		 * 从 AssetConfig 中获得 AssetInfo
		 * @return
		 *
		 */
		public function get info():AssetInfo
		{
			return AssetConfig.getInfo(path);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function get isDisposable():Boolean
		{
			return numUsers == 0;
		}

		/**
		 * 提示所有用户加载错误
		 *
		 */
		protected function notifyLoadError():void
		{
			for each (var user:IAssetUser in _users)
			{
				user.onAssetLoadError(this);
			}
		}

		/**
		 * 提示所有用户加载进度
		 * @param _bytesLoaded
		 * @param _bytesTotal
		 *
		 */
		protected function notifyLoadProgress():void
		{
			for each (var user:IAssetUser in _users)
			{
				user.onAssetLoadProgress(this, _bytesLoaded, _bytesTotal);
			}
		}

		/**
		 * 提示所有用户加载成功
		 *
		 */
		protected function notifyLoadComplete():void
		{
			trace("[Asset] 加载完成 " + info.url, ", 总", int(bytesLoaded / 1024), "k");

			for each (var user:IAssetUser in _users)
			{
				user.onAssetLoadComplete(this);
			}
		}

		/**
		 * 提示所有用户资源已释放
		 *
		 */
		protected function notifyDispose():void
		{
			// 通知所有 user
			for (var key:Object in _users)
			{
				IAssetUser(key).onAssetDispose(this);
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function toString():String
		{
			return path;
		}

		/**
		 * 已注册的扩展名
		 */
		private static var registeredExtensions:Object = {};

		/**
		 * 为指定的扩展名注册一个 assetClass，如果重复注册会报错
		 * @param extension
		 * @param assetClass
		 *
		 */
		public static function register(extension:String, assetClass:Class):void
		{
			if (registeredExtensions[extension])
			{
				throw new Error("注册失败，已有相同扩展名 " + extension + "的注册");
			}
			registeredExtensions[extension] = assetClass;
		}

		/**
		 * 反注册扩展名
		 * @param extension
		 *
		 */
		public static function unregister(extension:String):void
		{
			if (!registeredExtensions[extension])
			{
				throw new Error("解除注册失败，没有相同扩展名 " + extension + "的注册");
			}
			delete registeredExtensions[extension];
		}

		/**
		 * 根据扩展名获得已注册了的 Asset，如果找不到指定的扩展名之注册会报错
		 * @param extension
		 * @return
		 *
		 */
		public static function getAssetClass(extension:String):Class
		{
			if (!registeredExtensions[extension])
			{
				trace("找不到扩展名 " + extension + " 的注册，将返回默认的 Asset");
				return Asset;
			}
			return registeredExtensions[extension];
		}

		/**
		 * 所有的 Asset 都会在这里建立引用，直到 dispose 被调用
		 */
		public static var assets:Object = {};

		/**
		 * 根据路径从 assetList 获得指定的 Asset，如不存在会自动创建
		 * @param path path
		 * @param priority priority
		 * @param assetClass assetClass 建议使用 register 来处理后缀名，这不是推荐的参数
		 * @param params 构造 assetClass 之后，将要复制给 params 的参数，这不是推荐的参数
		 * @return
		 *
		 */
		public static function get(path:String, priority:int = 0, assetClass:Class = null, params:Object = null):Asset
		{
			if (!assets[path])
			{
				if (!assetClass)
				{
					assetClass = getAssetClass(URLUtil.getExtension(path));
				}
				assets[path] = new assetClass(path, priority);

				// 额外增加复制属性的参数
				if (params)
				{
					for (var key:String in params)
					{
						assets[path][key] = params[key];
					}
				}
			}
			else
			{
				// trace("[Asset] reusing " + path);
				Asset(assets[path]).priority = priority;
			}
			return assets[path];
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function get isSuccess():Boolean
		{
			return _state == AssetState.Loaded;
		}

		/**
		* 是否错误
		* @return
		*
		*/
		public function get isError():Boolean
		{
			return _state == AssetState.Error;
		}

		/**
		 * 记录上一次 GC 的时间
		 */
		private static var lastGC:int = 0;

		/**
		 * gc
		 * @param isForce 是否强制释放
		 *
		 */
		public static function gc(isForce:Boolean):void
		{
			if (isForce)
			{
				forceGC();
				return;
			}

			if (System.totalMemory > GC_CRITCAL)
			{
				if (lastGC + GC_CD <= getTimer())
				{
					forceGC();
				}
			}
		}

		/**
		 * 强制 gc
		 * @param reason
		 *
		 */
		private static function forceGC(reason:String = null):void
		{
			if (Capabilities.isDebugger)
			{
				var gcBefore:Number = System.totalMemoryNumber;
				trace("[Asset] 释放资源");

				if (reason)
				{
					trace(reason);
				}
			}
			lastGC = getTimer();
			var numAssetsBefore:int = 0;
			var a:AbstractAsset;
			var keys:Vector.<String> = new Vector.<String>;

			for (var path:String in assets)
			{
				numAssetsBefore++;
				a = assets[path];

				if (a.isDisposable)
				{
					keys.push(path);
				}
				else
				{
					if (Capabilities.isDebugger)
					{
						// trace("[保留]", a, "(用户数：", a.numUsers, "，状态：", AssetState.NAMES[a.state] + ")");
						a.printDebugInfo("[保留] ", a["path"]);
					}
				}
			}

			for each (path in keys)
			{
				a = assets[path];

				if (Capabilities.isDebugger)
				{
					trace("[释放]", a);
				}
				a.dispose();
				assets[path] = null;
				delete assets[path];
			} //end for key

			if (Capabilities.isDebugger)
			{
				var numAssetsAfter:int = 0;

				for each (a in assets)
				{
					numAssetsAfter++;
				}
				trace("已释放", numAssetsBefore - numAssetsAfter, "个资源，还有", numAssetsAfter, "个资源");
				System.gc();
				setTimeout(function():void
				{
					var memory:Number = gcBefore - System.totalMemoryNumber;
					trace("总计" + memory / 1024 + "k");
				}, 20);
			}
		}

		/**
		 * 资源占用的显存
		 */
		public static var vram:uint = 0;
	}
}

const GC_CRITCAL:int = 300 * 1024 * 1024;

const GC_CD:int = 10000; // 10s
