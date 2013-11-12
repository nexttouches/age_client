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
			x = s.nativeStage.stageWidth / 2;
			y = s.nativeStage.stageHeight / 2;
			var p:ParticleSystem3D = new ParticleSystem3D(new Particle3DConfig());
			Starling.current.juggler.add(p);
			p.start();
			addChild(p);
		}
	}
}
