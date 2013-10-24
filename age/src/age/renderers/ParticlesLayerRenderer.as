package age.renderers
{
	import starling.textures.Texture;

	public class ParticlesLayerRenderer extends PDParticleSystem3D
	{
		public function ParticlesLayerRenderer(config:XML, texture:Texture)
		{
			super(config, texture);
		}

		private var _currentFrame:int;

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
