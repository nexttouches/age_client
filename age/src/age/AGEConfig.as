package age
{
	import org.osflash.signals.Signal;

	/**
	 * AE 配置类
	 * @author zhanghaocong
	 *
	 */
	public class AGEConfig
	{
		/**
		 * constructor
		 * @param raw
		 *
		 */
		public function AGEConfig(raw:Object = null)
		{
			fromJSON(raw);
		}

		private var _isDebugMode:Boolean;

		/**
		 * 设置或获取是否调试模式
		 * @return
		 *
		 */
		public function get isDebugMode():Boolean
		{
			return _isDebugMode;
		}

		public function set isDebugMode(value:Boolean):void
		{
			_isDebugMode = value;
			onIsDebugModeChange.dispatch();
		}

		/**
		 * isShowWireframe 变化时广播<br>
		 * 请注意：isDebugMode 是总开关
		 */
		[Transient]
		public var onIsShowWireframe:Signal = new Signal();

		private var _isShowWireframe:Boolean;

		/**
		 * 设置或获取是否显示线框，默认 false
		 */
		public function get isShowWireframe():Boolean
		{
			return _isShowWireframe;
		}

		/**
		 * @private
		 */
		public function set isShowWireframe(value:Boolean):void
		{
			if (_isShowWireframe != value)
			{
				_isShowWireframe = value;
				onIsShowWireframe.dispatch();
			}
		}

		/**
		 * isDebugMode 变化时广播
		 */
		[Transient]
		public var onIsDebugModeChange:Signal = new Signal();

		/**
		 * isMute 变化时广播
		 */
		[Transient]
		public var onIsMuteChange:Signal = new Signal();

		private var _isMute:Boolean;

		/**
		 * 设置或获取是否静音
		 * @return
		 *
		 */
		public function get isMute():Boolean
		{
			return _isMute;
		}

		public function set isMute(value:Boolean):void
		{
			_isMute = value;
			onIsMuteChange.dispatch();
		}

		/**
		 * sfxVolumn 变化时广播
		 */
		[Transient]
		public var onSFXVolumnChange:Signal = new Signal();

		private var _sfxVolumn:Number;

		/**
		 * 设置或获取音效音量
		 * @return
		 *
		 */
		public function get sfxVolumn():Number
		{
			return _sfxVolumn;
		}

		public function set sfxVolumn(value:Number):void
		{
			_sfxVolumn = value;
			onSFXVolumnChange.dispatch();
		}

		/**
		 * bgmVolumn 变化时广播
		 */
		[Transient]
		public var onBGMVolumnChange:Signal = new Signal();

		private var _bgmVolumn:Number;

		/**
		 * 设置或获取 bgm 音量
		 * @return
		 *
		 */
		public function get bgmVolumn():Number
		{
			return _bgmVolumn;
		}

		public function set bgmVolumn(value:Number):void
		{
			_bgmVolumn = value;
			onBGMVolumnChange.dispatch();
		}

		/**
		 * 从 JSON 反序列化
		 * @param raw
		 *
		 */
		public function fromJSON(raw:Object):void
		{
			if (!raw)
			{
				return;
			}
			restore(raw, this, "isMute");
			restore(raw, this, "sfxVolumn");
			restore(raw, this, "bgmVolumn");
		}
	}
}
