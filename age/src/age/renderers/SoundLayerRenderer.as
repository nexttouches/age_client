package age.renderers
{
	import age.data.FrameLayerInfo;
	import nt.assets.IAsset;
	import nt.assets.IAssetUser;
	import nt.lib.util.IDisposable;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	/**
	 * 声音图层是虚拟图层，并不显示在场景中
	 * @author zhanghaocong
	 *
	 */
	public class SoundLayerRenderer implements IDisposable, IAssetUser
	{
		/**
		 * constructor
		 *
		 */
		public function SoundLayerRenderer()
		{
		}

		private var _currentFrame:int;

		/**
		 * 设置或获取当前帧
		 * @return
		 *
		 */
		public function get currentFrame():int
		{
			return _currentFrame;
		}

		public function set currentFrame(value:int):void
		{
			_currentFrame = value;

			if (info_isComplete)
			{
				if (_info.sounds[_currentFrame])
				{
					_info.sounds[_currentFrame].play();
				}
			}
		}

		private var _info:FrameLayerInfo;

		/**
		 * 设置或获取当前播放的 FrameLayerInfo
		 * @return
		 *
		 */
		public function get info():FrameLayerInfo
		{
			return _info;
		}

		public function set info(value:FrameLayerInfo):void
		{
			if (_info)
			{
				info_isComplete = false;
				_info.removeUser(this);
			}
			_info = value;

			if (_info)
			{
				_info.addUser(this);

				if (_info.isComplete)
				{
					onAssetLoadComplete(_info);
				}
				else
				{
					_info.load();
				}
			}
		}

		private var _isDisposed:Boolean;

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		public function dispose():Boolean
		{
			info = null;
			return _isDisposed = true;
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		public function get isDisposed():Boolean
		{
			return _isDisposed;
		}

		private var _onDispose:Signal;

		protected var info_isComplete:Boolean;

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		public function get onDispose():ISignal
		{
			return _onDispose ||= new Signal();
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function onAssetDispose(asset:IAsset):void
		{
			_info = null;
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function onAssetLoadComplete(asset:IAsset):void
		{
			info_isComplete = true;
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function onAssetLoadError(asset:IAsset):void
		{
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function onAssetLoadProgress(asset:IAsset, bytesLoaded:uint, bytesTotal:uint):void
		{
		}
	}
}
