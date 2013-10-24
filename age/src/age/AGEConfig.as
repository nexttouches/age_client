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
		public function AGEConfig(raw:Object = null)
		{
			fromJSON(raw);
		}

		/**
		 * isDebugMode 变化时广播
		 */
		public var onIsDebugModeChange:Signal = new Signal();

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
		 * isMute 变化时广播
		 */
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

		public function toJSON(k:*):*
		{
			return { isMute: isMute, sfxVolumn: sfxVolumn, bgmVolumn: bgmVolumn };
		}
	}
}
