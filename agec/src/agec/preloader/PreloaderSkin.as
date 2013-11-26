package agec.preloader
{
	import flash.display.Sprite;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import nt.assets.IAsset;
	import nt.assets.IAssetUser;
	import nt.assets.extensions.LibAsset;

	/**
	 * preloader 的皮肤，也负责加载外部皮肤
	 * @author zhanghaocong
	 *
	 */
	public class PreloaderSkin extends Sprite implements IAssetUser
	{
		/**
		 * 显示的皮肤 Sprite
		 */
		private var skin:Sprite = new NativePreloaderSkin();

		/**
		 * 皮肤
		 *
		 */
		public function PreloaderSkin()
		{
			super();
			addChild(skin);
		}

		/**
		 * 当前进度条
		 * @return
		 *
		 */
		public function get currentProgressBar():Sprite
		{
			return skin.getChildByName("currentProgressBar") as Sprite;
		}

		/**
		 * 当前进度文本框
		 * @return
		 *
		 */
		public function get currentProgressLabel():TextField
		{
			return skin.getChildByName("currentProgressLabel") as TextField;
		}

		/**
		 * 当前进度条
		 * @return
		 *
		 */
		public function get totalProgressBar():Sprite
		{
			return skin.getChildByName("totalProgressBar") as Sprite;
		}

		/**
		 * 总进度文本框
		 * @return
		 *
		 */
		public function get totalProgressLabel():TextField
		{
			return skin.getChildByName("totalProgressLabel") as TextField;
		}

		private var _asset:LibAsset;

		private var _currentProgress:Number;

		/**
		 * 设置或获取当前进度百分比
		 */
		public function get currentProgress():Number
		{
			return _currentProgress;
		}

		/**
		 * @private
		 */
		public function set currentProgress(value:Number):void
		{
			_currentProgress = value;
			currentProgressBar.scaleX = value;
		}

		private var _currentInfo:String;

		/**
		 * 设置或获取当前进度信息
		 */
		public function get currentInfo():String
		{
			return _currentInfo;
		}

		/**
		 * @private
		 */
		public function set currentInfo(value:String):void
		{
			_currentInfo = value;
			currentProgressLabel.text = value;
		}

		private var _totalProgress:Number;

		/**
		 * 设置或获取总进度百分比
		 */
		public function get totalProgress():Number
		{
			return _totalProgress;
		}

		/**
		 * @private
		 */
		public function set totalProgress(value:Number):void
		{
			_totalProgress = value;
			totalProgressBar.scaleX = value;
		}

		private var _totalInfo:String;

		/**
		 * 设置或获取总进度信息
		 */
		public function get totalInfo():String
		{
			return _totalInfo;
		}

		/**
		 * @private
		 */
		public function set totalInfo(value:String):void
		{
			_totalInfo = value;
			totalProgressLabel.text = value;
		}

		/**
		 * 设置或获取皮肤资源
		 * @return
		 *
		 */
		public function get asset():LibAsset
		{
			return _asset;
		}

		public function set asset(value:LibAsset):void
		{
			if (_asset == value)
			{
				return;
			}

			if (_asset)
			{
				_asset.removeUser(this);
			}
			_asset = value;

			if (_asset)
			{
				_asset.addUser(this);

				if (_asset.isComplete)
				{
					onAssetLoadComplete(_asset);
				}
				else
				{
					_asset.load(preloader.queue);
				}
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function onAssetDispose(asset:IAsset):void
		{
			_asset = null;
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function onAssetLoadComplete(asset:IAsset):void
		{
			const externalSkin:Sprite = this.asset.content as Sprite;

			if (isValidSkin(externalSkin))
			{
				removeChild(skin);
				skin = externalSkin;
				addChild(skin);
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function onAssetLoadError(asset:IAsset):void
		{
			trace("[PreloaderSkin] 加载皮肤时发生错误，将不使用外部皮肤");
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function onAssetLoadProgress(asset:IAsset, bytesLoaded:uint, bytesTotal:uint):void
		{
			// 忽略皮肤加载进度
		}

		/**
		 * 释放资源
		 *
		 */
		public function dispose():void
		{
			asset = null;
			removeChild(skin);
			skin = null;
		}

		/**
		 * 检查皮肤是否有效
		 * @param skin
		 * @return
		 *
		 */
		public function isValidSkin(skin:Sprite):Boolean
		{
			// 这些字段都是必须的
			const childNames:Vector.<String> = new <String>[ "currentProgressLabel",
															 "currentProgressBar",
															 "totalProgressLabel",
															 "totalProgressBar" ];

			for each (var childName:String in childNames)
			{
				if (!skin.getChildByName(childName))
				{
					if (Capabilities.isDebugger)
					{
						throw new ArgumentError("[PreloaderSkin] 皮肤资源格式不正确，缺少组件：" + childName);
					}
					return false;
				}
			}
			return true;
		}
	}
}
