package age.filters
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	import starling.filters.FragmentFilter;
	import starling.textures.Texture;

	public class BloomFilter extends FragmentFilter
	{
		protected const FRAGMENT_CODE:String = //
			"tex ft0, v0, fs0 <2d,linear,mipnone,clamp>	\n" + // bloom
			"tex ft1, v0, fs1 <2d,linear,mipnone,clamp>	\n" + // original
			// Adjust bloom saturation and intensity.
			"dp3 ft2.x, ft0.xyz, fc0.xyz                \n" + "sub ft3.xyz, ft0.xyz, ft2.xxx              \n" + "mul ft3.xyz, ft3.xyz, fc1.zzz              \n" + "add ft3.xyz, ft3.xyz, ft2.xxx              \n" + "mul ft0.xyz, ft3.xyz, fc1.xxx              \n" + // Adjust original saturation and intensity.
			"dp3 ft2.x, ft1.xyz, fc0.xyz                \n" + "sub ft3.xyz, ft1.xyz, ft2.xxx              \n" + "mul ft3.xyz, ft3.xyz, fc1.www              \n" + "add ft3.xyz, ft3.xyz, ft2.xxx              \n" + "mul ft1.xyz, ft3.xyz, fc1.yyy              \n" + // Darken down the base image in areas where there is a lot of bloom,
			// to prevent things looking excessively burned-out.
			"sat ft2.xyz, ft0.xyz                       \n" + "sub ft2.xyz, fc0.www, ft2.xyz              \n" + "mul ft1.xyz, ft1.xyz, ft2.xyz              \n" + "add oc, ft0, ft1              \n";

		//        
		private var mShaderProgram:Program3D;

		private var mOnes:Vector.<Number> = new <Number>[ 1.0, 1.0, 1.0, 1.0 ];

		private var mMinColor:Vector.<Number> = new <Number>[ 0, 0, 0, 0.0001 ];

		public function BloomFilter(numPasses:int = 1, resolution:Number = 1.0)
		{
			super(numPasses, resolution);
		}

		public override function dispose():void
		{
			if (mShaderProgram)
				mShaderProgram.dispose();
			super.dispose();
		}

		protected override function createPrograms():void
		{
			// One might expect that we could just subtract the RGB values from 1, right?
			// The problem is that the input arrives with premultiplied alpha values, and the
			// output is expected in the same form. So we first have to restore the original RGB
			// values, subtract them from one, and then multiply with the original alpha again.
			var fragmentProgramCode:String = "tex ft0, v0, fs0 <2d, clamp, linear, mipnone>  \n" + // read texture color
				"max ft0, ft0, fc1              \n" + // avoid division through zero in next step
				"div ft0.xyz, ft0.xyz, ft0.www  \n" + // restore original (non-PMA) RGB values
				"sub ft0.xyz, fc0.xyz, ft0.xyz  \n" + // subtract rgb values from '1'
				"mul ft0.xyz, ft0.xyz, ft0.www  \n" + // multiply with alpha again (PMA)
				"mov oc, ft0                    \n"; // copy to output
			mShaderProgram = assembleAgal(FRAGMENT_CODE);
		}

		protected override function activate(pass:int, context:Context3D, texture:Texture):void
		{
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, mOnes, 1);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, mMinColor, 1);
			context.setProgram(mShaderProgram);
		}
	}
}
