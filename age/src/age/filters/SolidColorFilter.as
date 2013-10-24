package age.filters
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	import starling.filters.FragmentFilter;
	import starling.textures.Texture;
	import starling.utils.Color;

	/**
	 * 纯色滤镜<br>
	 * 覆盖贴图到指定的颜色
	 * @author kk
	 *
	 */
	public class SolidColorFilter extends FragmentFilter
	{
		/**
		 * @private
		 */
		private var shaderProgram:Program3D;

		/**
		 * 0 1 2 3
		 * r g b a
		 */
		private var shaderMatrix:Vector.<Number>;

		/**
		 * 创建一个新的 SolidColorFilter
		 *
		 */
		public function SolidColorFilter(color:uint = 0x66ffffff)
		{
			shaderMatrix = new <Number>[];
			this.color = color;
		}

		/**
		 * @inheritDoc
		 *
		 */
		public override function dispose():void
		{
			if (shaderProgram)
				shaderProgram.dispose();
			super.dispose();
		}

		/**
		 * @private
		 *
		 */
		protected override function createPrograms():void
		{
			// fc0: 新色值
			const fragmentProgramCode:String = "tex ft0, v0, fs0 <2d, clamp, linear, mipnone>  \n" + // 抓贴图颜色
				"div ft0.xyz, ft0.xyz, ft0.www  \n" + // 恢复 PMA 之前的值，并把 alpha 暂存
				"mul ft0.www, ft0.www, fc0.www  \n" + // 乘以新 alpha
				"mov ft0.xyz, fc0.xyz           \n" + // 设置成我们要的颜色
				"mul ft0.xyz, ft0.xyz, ft0.www  \n" + // 恢复 PMA 的 alpha（已包含新 alpha）
				"mov oc, ft0                    \n"; // 输出
			shaderProgram = assembleAgal(fragmentProgramCode);
		}

		/**
		 * @private
		 * @param pass
		 * @param context
		 * @param texture
		 *
		 */
		protected override function activate(pass:int, context:Context3D, texture:Texture):void
		{
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, shaderMatrix);
			context.setProgram(shaderProgram);
		}

		/**
		 * 根据 color 更新 shaderMatrix
		 *
		 */
		public function updateShaderMatrix():void
		{
			shaderMatrix.length = 0;
			shaderMatrix.push(r / 255.0, g / 255.0, b / 255.0, a / 255.0);
		}

		private var _color:uint;

		/**
		 * 设置或获取颜色<br>
		 * 这里的颜色采用 ARGB 形式：如 0x66ffffff 表示填充半透明白色
		 * @return
		 *
		 */
		public function get color():uint
		{
			return _color;
		}

		public function set color(value:uint):void
		{
			_color = value;
			r = Color.getRed(_color);
			g = Color.getGreen(_color);
			b = Color.getBlue(_color);
			a = Color.getAlpha(_color);
			updateShaderMatrix();
		}

		public var r:Number = 0;

		public var g:Number = 0;

		public var b:Number = 0;

		public var a:Number = 0;
	}
}
