package ageb.modules.avatar.frameInfoClasses
{
	import flash.events.Event;
	import mx.collections.ArrayList;
	import mx.controls.ColorPicker;
	import spark.components.ButtonBar;
	import spark.components.CheckBox;
	import spark.components.HSlider;
	import age.data.EmitterType;
	import age.data.Particle3DConfig;
	import age.renderers.ParticleSystem3D;
	import ageb.modules.ae.FrameInfoEditable;
	import ageb.modules.avatar.op.ChangeFrameParticleConfig;
	import nt.lib.reflect.Property;
	import nt.lib.reflect.Type;
	import starling.extensions.ColorArgb;

	/**
	 * 粒子帧属性面板
	 * @author kk
	 *
	 */
	public class ParticleContent extends AnimationContent
	{

		[SkinPart(required="true")]
		public var emitterType:ButtonBar;

		[SkinPart(required="true")]
		public var isUseNativeTexture:CheckBox;

		[SkinPart(required="true")]
		public var startColor:ColorPicker;

		[SkinPart(required="true")]
		public var startColorAlpha:HSlider;

		[SkinPart(required="true")]
		public var startColorVariance:ColorPicker;

		[SkinPart(required="true")]
		public var startColorVarianceAlpha:HSlider;

		[SkinPart(required="true")]
		public var endColor:ColorPicker;

		[SkinPart(required="true")]
		public var endColorAlpha:HSlider;

		[SkinPart(required="true")]
		public var endColorVariance:ColorPicker;

		[SkinPart(required="true")]
		public var endColorVarianceAlpha:HSlider;

		[SkinPart(required="true")]
		public var maxNumParticles:HSliderRow;

		[SkinPart(required="true")]
		public var lifespan:HSliderRow;

		[SkinPart(required="true")]
		public var lifespanVariance:HSliderRow;

		[SkinPart(required="true")]
		public var startSize:HSliderRow;

		[SkinPart(required="true")]
		public var startSizeVariance:HSliderRow;

		[SkinPart(required="true")]
		public var endSize:HSliderRow;

		[SkinPart(required="true")]
		public var endSizeVariance:HSliderRow;

		[SkinPart(required="true")]
		public var emitAngle:HSliderRow;

		[SkinPart(required="true")]
		public var emitAngleVariance:HSliderRow;

		[SkinPart(required="true")]
		public var startRotation:HSliderRow;

		[SkinPart(required="true")]
		public var startRotationVariance:HSliderRow;

		[SkinPart(required="true")]
		public var endRotation:HSliderRow;

		[SkinPart(required="true")]
		public var endRotationVariance:HSliderRow;

		[SkinPart(required="true")]
		public var emitterXVariance:HSliderRow;

		[SkinPart(required="true")]
		public var emitterYVariance:HSliderRow;

		[SkinPart(required="true")]
		public var speed:HSliderRow;

		[SkinPart(required="true")]
		public var speedVariance:HSliderRow;

		[SkinPart(required="true")]
		public var gravityX:HSliderRow;

		[SkinPart(required="true")]
		public var gravityY:HSliderRow;

		[SkinPart(required="true")]
		public var radialAcceleration:HSliderRow;

		[SkinPart(required="true")]
		public var radialAccelerationVariance:HSliderRow;

		[SkinPart(required="true")]
		public var tangentialAcceleration:HSliderRow;

		[SkinPart(required="true")]
		public var tangentialAccelerationVariance:HSliderRow;

		[SkinPart(required="true")]
		public var maxRadius:HSliderRow;

		[SkinPart(required="true")]
		public var maxRadiusVariance:HSliderRow;

		[SkinPart(required="true")]
		public var minRadius:HSliderRow;

		[SkinPart(required="true")]
		public var rotatePerSecond:HSliderRow;

		[SkinPart(required="true")]
		public var rotatePerSecondVariance:HSliderRow;

		/**
		 * constructor
		 *
		 */
		public function ParticleContent()
		{
			super();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function get skinClass():Class
		{
			return ParticleContentSkin;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			emitterType.dataProvider = new ArrayList(constantsToArray(EmitterType));

			for (var skinField:String in skinParts)
			{
				if (this[skinField])
				{
					this[skinField].addEventListener(Event.CHANGE, onChange);
				}
			}
		}

		/**
		 * @private
		 *
		 */
		protected function onChange(event:Event):void
		{
			var pc:Particle3DConfig = new Particle3DConfig();

			for each (var p:Property in Type.of(Particle3DConfig).properties)
			{
				// 不支持的属性
				if (p.name == "isUseNativeTexture" || p.name == "blendFactorDestination" || p.name == "blendFactorSource")
				{
					continue;
				}

				// ColorArgb 的特殊处理
				if (p.type == ColorArgb)
				{
					ColorArgb(pc[p.name]).fromRgb(ColorPicker(this[p.name]).selectedColor);
					ColorArgb(pc[p.name]).alpha = HSlider(this[p.name + "Alpha"]).value
				}
				else if (p.name == "emitterType")
				{
					pc[p.name] = ButtonBar(this[p.name]).selectedIndex;
				}
				else
				{
					pc[p.name] = HSliderRow(this[p.name]).value;
				}
			}
			new ChangeFrameParticleConfig(doc, keyframes, pc).execute();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function set keyframes(value:Vector.<FrameInfoEditable>):void
		{
			if (keyframe)
			{
				keyframe.onParticleConfigChange.remove(onParticleConfigChange);
			}
			super.keyframes = value;

			if (keyframe)
			{
				keyframe.onParticleConfigChange.add(onParticleConfigChange);
			}
			onParticleConfigChange();
		}

		/**
		 * @private
		 *
		 */
		private function onParticleConfigChange():void
		{
			particleConfig = keyframe ? keyframe.particleConfig : null;
		}

		private var _particleConfig:Particle3DConfig;

		/**
		 * 设置或获取当前显示的 Particle3DConfig
		 * @return
		 *
		 */
		public function get particleConfig():Particle3DConfig
		{
			return _particleConfig;
		}

		public function set particleConfig(value:Particle3DConfig):void
		{
			_particleConfig = value || new Particle3DConfig;
			_particleConfig.isUseNativeTexture = isUseNativeTexture.selected;

			for each (var p:Property in Type.of(Particle3DConfig).properties)
			{
				// 不支持的属性
				if (p.name == "isUseNativeTexture" || p.name == "blendFactorDestination" || p.name == "blendFactorSource")
				{
					continue;
				}
				const x:* = _particleConfig[p.name];

				// ColorArgb 的特殊处理
				if (p.type == ColorArgb)
				{
					ColorPicker(this[p.name]).selectedColor = ColorArgb(x).toRgb();
					HSlider(this[p.name + "Alpha"]).value = ColorArgb(x).alpha;
				}
				else if (p.name == "emitterType")
				{
					ButtonBar(this[p.name]).selectedIndex = x;
				}
				else
				{
					HSliderRow(this[p.name]).value = x;
				}
			}
			// 更新贴图
			onTextureChange();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function onTextureChange():void
		{
			// 由于执行先后顺序问题，particleConfig 此时可能还没准备好，我们跳过
			if (!_particleConfig)
			{
				return;
			}

			// 如果使用内置贴图就不去加载了
			if (_particleConfig.isUseNativeTexture)
			{
				texturePreview.source = ParticleSystem3D.defaultTextureBitmapData;
			}
			else
			{
				super.onTextureChange();
			}
		}
	}
}
