package age.data
{
	import flash.display3D.Context3DBlendFactor;
	import nt.lib.reflect.Type;
	import starling.extensions.ColorArgb;

	/**
	 * 粒子配置
	 * @author zhanghaocong
	 *
	 */
	public class Particle3DConfig
	{
		/**
		 * 获得指定字段的翻译文本
		 * @param field
		 * @return
		 *
		 */
		public static function T(field:String):String
		{
			return Type.of(Particle3DConfig).getProperty(field).getMetadata("T").getArg("");
		}

		[T("使用内置贴图")]
		public var isUseNativeTexture:Boolean = true;

		// 发射器设置
		[T("发射类型")]
		public var emitterType:int = EmitterType.GRAVITY;

		// 粒子设置
		[T("最大粒子数")]
		public var maxNumParticles:int = 250;

		[T("寿命")]
		public var lifespan:Number = 2;

		[T("寿命随机量")]
		public var lifespanVariance:Number = 2;

		[T("初始大小")]
		public var startSize:Number = 70;

		[T("初始大小随机量")]
		public var startSizeVariance:Number = 50;

		[T("结束大小")]
		public var endSize:Number = 10;

		[T("结束大小随机量")]
		public var endSizeVariance:Number = 5;

		[T("发射方向")]
		public var emitAngle:Number = 270;

		[T("发射方向随机量")]
		public var emitAngleVariance:Number = 0;

		[T("初始旋转角度")]
		public var startRotation:Number = 0;

		[T("初始旋转角度随机量")]
		public var startRotationVariance:Number = 0;

		[T("结束旋转角度")]
		public var endRotation:Number = 0;

		[T("结束旋转角度随机量")]
		public var endRotationVariance:Number = 0;

		// 发射类型为 GRAVITY 的设置
		[T("发射 x 随机量")]
		public var emitterXVariance:Number = 10;

		[T("发射 y 随机量")]
		public var emitterYVariance:Number = 10;

		[T("速度")]
		public var speed:Number = 50;

		[T("速度随机量")]
		public var speedVariance:Number = 15;

		[T("重力 X")]
		public var gravityX:Number = 0;

		[T("重力 Y")]
		public var gravityY:Number = 0;

		[T("径向加速度")]
		public var radialAcceleration:Number = 0;

		[T("径向加速度随机量")]
		public var radialAccelerationVariance:Number = 0;

		[T("切向加速度")]
		public var tangentialAcceleration:Number = 0;

		[T("切向加速度随机量")]
		public var tangentialAccelerationVariance:Number = 0;

		// 发射类型为 radial 的设置
		[T("最大半径")]
		public var maxRadius:Number = 100;

		[T("最大半径随机量")]
		public var maxRadiusVariance:Number = 0;

		[T("最小半径")]
		public var minRadius:Number = 0;

		[T("每秒旋转")]
		public var rotatePerSecond:Number = 0;

		[T("每秒旋转随机量")]
		public var rotatePerSecondVariance:Number = 0;

		// color configuration
		[T("初始颜色")]
		public var startColor:ColorArgb = ColorArgb.fromArgb(0x66ff6600);

		[T("初始颜色随机量")]
		public var startColorVariance:ColorArgb = ColorArgb.fromArgb(0x00000022);

		[T("结束颜色")]
		public var endColor:ColorArgb = ColorArgb.fromArgb(0x00ff2200);

		[T("结束颜色变量")]
		public var endColorVariance:ColorArgb = ColorArgb.fromArgb(0);

		[T("blendFactorSource")]
		public var blendFactorSource:String = Context3DBlendFactor.SOURCE_ALPHA;

		[T("blendFactorDestination")]
		public var blendFactorDestination:String = Context3DBlendFactor.ONE;

		/**
		 * constructor
		 *
		 */
		public function Particle3DConfig(raw:Object = null)
		{
			if (raw)
			{
				fromJSON(raw);
			}
		}

		/**
		 * 从 JSON 恢复数据
		 * @param s
		 * @return 当前 ParticleInfo 以便链式调用
		 */
		public function fromJSON(s:*):Particle3DConfig
		{
			for (var key:String in s)
			{
				const value:* = s[key];

				if (!hasOwnProperty(key))
				{
					continue;
				}

				// 颜色的特别设置
				if (this[key] is ColorArgb)
				{
					(this[key] as ColorArgb).fromArgb(value);
				}
				else
				{
					this[key] = value;
				}
			}
			return this;
		}

		/**
		 * 获得当前对象的副本
		 * @return
		 *
		 */
		public function clone():Particle3DConfig
		{
			return new Particle3DConfig(JSON.parse(JSON.stringify(this)));
		}
	}
}
