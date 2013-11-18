package ageb.modules.ae
{
	import age.data.FrameInfo;
	import age.data.FrameLayerInfo;
	import age.renderers.ParticleLayerRenderer;

	/**
	 * ParticleLayerRendererEditable
	 * @author zhanghaocong
	 *
	 */
	public class ParticleLayerRendererEditable extends ParticleLayerRenderer
	{
		/**
		 * constructor
		 *
		 */
		public function ParticleLayerRendererEditable()
		{
			super();
		}

		/**
		 * 缓存当前 info 是否已经加载完毕
		 */
		private var info_isComplete:Boolean;

		private var _frames:Vector.<FrameInfo>;

		/**
		 * 当前所有帧，我们要侦听每帧的 onParticleConfigChange 事件
		 */
		public function get frames():Vector.<FrameInfo>
		{
			return _frames;
		}

		/**
		 * @private
		 */
		public function set frames(value:Vector.<FrameInfo>):void
		{
			var i:int;

			if (_frames)
			{
				// 一些兼容处理
				if (_frames[0] is FrameInfoEditable)
				{
					for (i = 0; i < _frames.length; i++)
					{
						FrameInfoEditable(_frames[i]).onParticleConfigChange.remove(validateCurrentFrame);
						FrameInfoEditable(_frames[i]).onBoxChange.remove(validateCurrentFrame);
					}
				}
			}
			_frames = value;

			if (_frames)
			{
				if (_frames[0] is FrameInfoEditable)
				{
					for (i = 0; i < _frames.length; i++)
					{
						FrameInfoEditable(_frames[i]).onParticleConfigChange.add(validateCurrentFrame);
						FrameInfoEditable(_frames[i]).onBoxChange.add(validateCurrentFrame);
					}
				}
			}
		}

		/**
		* @inheritDoc
		*
		*/
		override public function set info(value:FrameLayerInfo):void
		{
			if (info)
			{
				info.onTexturesChange.remove(onTexturesChange);
			}

			if (infoEditable)
			{
				infoEditable.onFramesChange.remove(onFramesChange);
				infoEditable.onIndexChange.remove(onIndexChange);
			}
			super.info = value;

			if (info)
			{
				info.onTexturesChange.add(onTexturesChange);
				infoEditable.onIndexChange.add(onIndexChange);
			}

			if (infoEditable)
			{
				infoEditable.onFramesChange.add(onFramesChange);
			}
			onFramesChange();
			onTexturesChange();
		}

		/**
		 * @private
		 *
		 */
		private function onIndexChange():void
		{
			// 重新缓存当前索引
			layerIndex = info.index;
		}

		/**
		 * @private
		 *
		 */
		private function onFramesChange(target:FrameLayerInfoEditable = null):void
		{
			frames = info ? info.frames : null;
		}

		/**
		 * @private
		 * @return
		 *
		 */
		protected function get infoEditable():FrameLayerInfoEditable
		{
			return info as FrameLayerInfoEditable;
		}

		/**
		 * @private
		 *
		 */
		private function onTexturesChange():void
		{
			info_isComplete = info && info.isComplete && info.textures != null;
			validateCurrentFrame();
		}
	}
}
