package age.renderers
{
	import age.data.Particle3DConfig;
	import age.renderers.ParticleSystem3D;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;

	public class Particle3DTest extends Sprite
	{
		public function Particle3DTest()
		{
			super();
			addChild(new Image(ParticleSystem3D.defaultTexture));
			const s:Starling = Starling.current;
			p.projectY = projectY;
			var p:ParticleSystem3D = new ParticleSystem3D(new Particle3DConfig());
			p.setPosition(s.nativeStage.stageWidth / 2, s.nativeStage.stageHeight / 2, s.nativeStage.stageHeight / 2);
			Starling.current.juggler.add(p);
			p.start();
			addChild(p);
		}

		/**
		* 投影 y, z 到 UI 坐标
		* @param y
		* @param z
		* @return
		*
		*/
		public function projectY(y:Number, z:Number):Number
		{
			return Starling.current.nativeStage.stageHeight - y - z * 0.5;
		}
	}
}
