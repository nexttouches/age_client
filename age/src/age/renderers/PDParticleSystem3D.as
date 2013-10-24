package age.renderers
{
	import starling.extensions.PDParticleSystem;
	import starling.textures.Texture;

	public class PDParticleSystem3D extends PDParticleSystem implements IArrangeable, IDisplayObject3D, IDirectionRenderer
	{
		public function PDParticleSystem3D(config:XML, texture:Texture)
		{
			super(config, texture);
		}

		public function get zIndex():int
		{
			// TODO Auto Generated method stub
			return 0;
		}

		public function get direction():int
		{
			// TODO Auto Generated method stub
			return 0;
		}

		public function set direction(value:int):void
		{
			// TODO Auto Generated method stub
		}

		public function get projectY():Function
		{
			// TODO Auto Generated method stub
			return null;
		}

		public function set projectY(value:Function):void
		{
			// TODO Auto Generated method stub
		}

		public function get z():Number
		{
			// TODO Auto Generated method stub
			return 0;
		}

		public function set z(value:Number):void
		{
			// TODO Auto Generated method stub
		}

		private var _scale:Number;

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		public function get scale():Number
		{
			return _scale;
		}

		public function set scale(value:Number):void
		{
			_scale = value;
			scaleX = value;
			scaleY = value;
		}
	}
}
