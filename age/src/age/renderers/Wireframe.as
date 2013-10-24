package age.renderers
{

	public class Wireframe extends Quad3D
	{
		public function Wireframe(width:Number, height:Number, color:uint = 0xffffff, premultipliedAlpha:Boolean = true)
		{
			super(width, height, color, premultipliedAlpha);
			uniqueIndex += ZIndexHelper.ANIMATION_OFFSET;
		}
	}
}
