package age.renderers
{
	import age.data.FrameLayerInfo;
	import nt.lib.util.IDisposable;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	public class SoundLayerRenderer implements IDisposable
	{
		public function SoundLayerRenderer()
		{
		}

		private var _currentFrame:int;

		public function get currentFrame():int
		{
			return _currentFrame;
		}

		public function set currentFrame(value:int):void
		{
			_currentFrame = value;
			trace(info.index, info.frames[currentFrame].texture, info.numFrames);
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
			_info = value;
		}

		private var _isDisposed:Boolean;

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		public function dispose():Boolean
		{
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

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		public function get onDispose():ISignal
		{
			return _onDispose ||= new Signal();
		}
	}
}
