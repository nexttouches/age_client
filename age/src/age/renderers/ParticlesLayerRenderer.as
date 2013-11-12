package age.renderers
{
	import age.data.FrameLayerInfo;
	import starling.textures.Texture;

	/**
	 * 粒子图层
	 * @author zhanghaocong
	 *
	 */
	public class ParticlesLayerRenderer extends ParticleSystem3D
	{
		/**
		 * constructor
		 *
		 */
		public function ParticlesLayerRenderer(config:XML = null, texture:Texture = null)
		{
			super();
		}

		private var _info:FrameLayerInfo;

		/**
		 * 设置或获取渲染的 FrameLayerInfo
		 */
		public function get info():FrameLayerInfo
		{
			return _info;
		}

		/**
		 * @private
		 */
		public function set info(value:FrameLayerInfo):void
		{
			_info = value;
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
		}
	}
}
