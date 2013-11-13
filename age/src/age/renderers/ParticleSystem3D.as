package age.renderers
{
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.errors.IllegalOperationError;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import age.data.EmitterType;
	import age.data.Particle3DConfig;
	import org.osflash.signals.Signal;
	import starling.animation.IAnimatable;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.errors.MissingContextError;
	import starling.events.Event;
	import starling.extensions.ColorArgb;
	import starling.extensions.Particle;
	import starling.textures.Texture;
	import starling.utils.MatrixUtil;
	import starling.utils.VertexData;
	import starling.utils.deg2rad;

	/**
	 * 支持 3D 坐标的粒子系统
	 * @author zhanghaocong
	 *
	 */
	public class ParticleSystem3D extends DisplayObject implements IDisplayObject3D, IDirectionRenderer, IAnimatable
	{
		/**
		 * constructor
		 *
		 */
		public function ParticleSystem3D(config:Particle3DConfig = null, initialCapacity:int = 128, maxCapacity:int = 8192, blendFactorSource:String = null, blendFactorDest:String = null)
		{
			this.config = config;
			mTexture = defaultTexture;
			mPremultipliedAlpha = texture.premultipliedAlpha;
			mParticles = new Vector.<Particle3D>(0, false);
			mVertexData = new VertexData(0);
			mIndices = new <uint>[];
			mEmissionRate = mMaxNumParticles / mLifespan;
			mEmissionTime = 0.0;
			mFrameTime = 0.0;
			mEmitterX = mEmitterY = 0;
			mMaxCapacity = Math.min(8192, maxCapacity);
			mBlendFactorDestination = blendFactorDest || Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			mBlendFactorSource = blendFactorSource || (mPremultipliedAlpha ? Context3DBlendFactor.ONE : Context3DBlendFactor.SOURCE_ALPHA);
			createProgram();
			raiseCapacity(initialCapacity);
			// handle a lost device context
			Starling.current.stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated, false, 0, true);
			mPremultipliedAlpha = false;
		}

		private var _onParticle3DConfigChange:Signal;

		/**
		 * config 变化时广播
		 * @return
		 *
		 */
		public function get onParticle3DConfigChange():Signal
		{
			return _onParticle3DConfigChange;
		}

		public var _config:Particle3DConfig;

		/**
		 * 设置或获取使用的粒子配置
		 * @return
		 *
		 */
		public function get config():Particle3DConfig
		{
			return _config;
		}

		public function set config(value:Particle3DConfig):void
		{
			if (_config != value)
			{
				_config = value;
				parseConfig(value);
			}
		}

		/**
		 * 分析配置
		 * @param value
		 *
		 */
		protected function parseConfig(config:Particle3DConfig):void
		{
			mEmitterXVariance = config.emitterXVariance;
			mEmitterYVariance = config.emitterYVariance;
			mGravityX = config.gravityX;
			mGravityY = config.gravityY;
			mEmitterType = config.emitterType;
			mMaxNumParticles = config.maxNumParticles;
			mLifespan = Math.max(0.01, config.lifespan);
			mLifespanVariance = config.lifespanVariance;
			mStartSize = config.startSize;
			mStartSizeVariance = config.startSizeVariance;
			mEndSize = config.endSize;
			mEndSizeVariance = config.endSizeVariance;
			mEmitAngle = deg2rad(config.emitAngle);
			mEmitAngleVariance = deg2rad(config.emitAngleVariance);
			mStartRotation = deg2rad(config.startRotation);
			mStartRotationVariance = deg2rad(config.startRotationVariance);
			mEndRotation = deg2rad(config.endRotation);
			mEndRotationVariance = deg2rad(config.endRotationVariance);
			mSpeed = config.speed;
			mSpeedVariance = config.speedVariance;
			mRadialAcceleration = config.radialAcceleration;
			mRadialAccelerationVariance = config.radialAccelerationVariance;
			mTangentialAcceleration = config.tangentialAcceleration;
			mTangentialAccelerationVariance = config.tangentialAccelerationVariance;
			mMaxRadius = config.maxRadius;
			mMaxRadiusVariance = config.maxRadiusVariance;
			mMinRadius = config.minRadius;
			mRotatePerSecond = deg2rad(config.rotatePerSecond);
			mRotatePerSecondVariance = deg2rad(config.rotatePerSecondVariance);
			mStartColor = config.startColor;
			mStartColorVariance = config.startColorVariance;
			mEndColor = config.endColor;
			mEndColorVariance = config.endColorVariance;
			mBlendFactorSource = config.blendFactorSource;
			mBlendFactorDestination = config.blendFactorDestination;
		}

		// emitter configuration                            // .pex element name
		private var mEmitterType:int; // emitterType

		private var mEmitterXVariance:Number; // sourcePositionVariance x

		private var mEmitterYVariance:Number; // sourcePositionVariance y

		// particle configuration
		private var mMaxNumParticles:int; // maxParticles

		private var mLifespan:Number; // particleLifeSpan

		private var mLifespanVariance:Number; // particleLifeSpanVariance

		private var mStartSize:Number; // startParticleSize

		private var mStartSizeVariance:Number; // startParticleSizeVariance

		private var mEndSize:Number; // finishParticleSize

		private var mEndSizeVariance:Number; // finishParticleSizeVariance

		private var mEmitAngle:Number; // angle

		private var mEmitAngleVariance:Number; // angleVariance

		private var mStartRotation:Number; // rotationStart

		private var mStartRotationVariance:Number; // rotationStartVariance

		private var mEndRotation:Number; // rotationEnd

		private var mEndRotationVariance:Number; // rotationEndVariance

		// gravity configuration
		private var mSpeed:Number; // speed

		private var mSpeedVariance:Number; // speedVariance

		private var mGravityX:Number; // gravity x

		private var mGravityY:Number; // gravity y

		private var mGravityZ:Number;

		private var mRadialAcceleration:Number; // radialAcceleration

		private var mRadialAccelerationVariance:Number; // radialAccelerationVariance

		private var mTangentialAcceleration:Number; // tangentialAcceleration

		private var mTangentialAccelerationVariance:Number; // tangentialAccelerationVariance

		// radial configuration 
		private var mMaxRadius:Number; // maxRadius

		private var mMaxRadiusVariance:Number; // maxRadiusVariance

		private var mMinRadius:Number; // minRadius

		private var mRotatePerSecond:Number; // rotatePerSecond

		private var mRotatePerSecondVariance:Number; // rotatePerSecondVariance

		// color configuration
		private var mStartColor:ColorArgb; // startColor

		private var mStartColorVariance:ColorArgb; // startColorVariance

		private var mEndColor:ColorArgb; // finishColor

		private var mEndColorVariance:ColorArgb; // finishColorVariance

		/**
		 * @inheritDoc
		 *
		 */
		protected function initParticle(particle:Particle3D):void
		{
			// for performance reasons, the random variances are calculated inline instead
			// of calling a function
			var lifespan:Number = mLifespan + mLifespanVariance * (Math.random() * 2.0 - 1.0);
			particle.currentTime = 0.0;
			particle.totalTime = lifespan > 0.0 ? lifespan : 0.0;

			if (lifespan <= 0.0)
			{
				return;
			}
			particle.x = mEmitterX + mEmitterXVariance * (Math.random() * 2.0 - 1.0);
			particle.y = mEmitterY + mEmitterYVariance * (Math.random() * 2.0 - 1.0);
			particle.startX = mEmitterX;
			particle.startY = mEmitterY;
			var angle:Number = mEmitAngle + mEmitAngleVariance * (Math.random() * 2.0 - 1.0);
			var speed:Number = mSpeed + mSpeedVariance * (Math.random() * 2.0 - 1.0);
			particle.velocityX = speed * Math.cos(angle);
			particle.velocityY = speed * Math.sin(angle);
			particle.emitRadius = mMaxRadius + mMaxRadiusVariance * (Math.random() * 2.0 - 1.0);
			particle.emitRadiusDelta = mMaxRadius / lifespan;
			particle.emitRotation = mEmitAngle + mEmitAngleVariance * (Math.random() * 2.0 - 1.0);
			particle.emitRotationDelta = mRotatePerSecond + mRotatePerSecondVariance * (Math.random() * 2.0 - 1.0);
			particle.radialAcceleration = mRadialAcceleration + mRadialAccelerationVariance * (Math.random() * 2.0 - 1.0);
			particle.tangentialAcceleration = mTangentialAcceleration + mTangentialAccelerationVariance * (Math.random() * 2.0 - 1.0);
			var startSize:Number = mStartSize + mStartSizeVariance * (Math.random() * 2.0 - 1.0);
			var endSize:Number = mEndSize + mEndSizeVariance * (Math.random() * 2.0 - 1.0);

			if (startSize < 0.1)
			{
				startSize = 0.1;
			}

			if (endSize < 0.1)
			{
				endSize = 0.1;
			}
			particle.scale = startSize / texture.width;
			particle.scaleDelta = ((endSize - startSize) / lifespan) / texture.width;
			// colors
			var startColor:ColorArgb = particle.colorArgb;
			var colorDelta:ColorArgb = particle.colorArgbDelta;
			startColor.red = mStartColor.red;
			startColor.green = mStartColor.green;
			startColor.blue = mStartColor.blue;
			startColor.alpha = mStartColor.alpha;

			if (mStartColorVariance.red != 0)
			{
				startColor.red += mStartColorVariance.red * (Math.random() * 2.0 - 1.0);
			}

			if (mStartColorVariance.green != 0)
			{
				startColor.green += mStartColorVariance.green * (Math.random() * 2.0 - 1.0);
			}

			if (mStartColorVariance.blue != 0)
			{
				startColor.blue += mStartColorVariance.blue * (Math.random() * 2.0 - 1.0);
			}

			if (mStartColorVariance.alpha != 0)
			{
				startColor.alpha += mStartColorVariance.alpha * (Math.random() * 2.0 - 1.0);
			}
			var endColorRed:Number = mEndColor.red;
			var endColorGreen:Number = mEndColor.green;
			var endColorBlue:Number = mEndColor.blue;
			var endColorAlpha:Number = mEndColor.alpha;

			if (mEndColorVariance.red != 0)
			{
				endColorRed += mEndColorVariance.red * (Math.random() * 2.0 - 1.0);
			}

			if (mEndColorVariance.green != 0)
			{
				endColorGreen += mEndColorVariance.green * (Math.random() * 2.0 - 1.0);
			}

			if (mEndColorVariance.blue != 0)
			{
				endColorBlue += mEndColorVariance.blue * (Math.random() * 2.0 - 1.0);
			}

			if (mEndColorVariance.alpha != 0)
			{
				endColorAlpha += mEndColorVariance.alpha * (Math.random() * 2.0 - 1.0);
			}
			colorDelta.red = (endColorRed - startColor.red) / lifespan;
			colorDelta.green = (endColorGreen - startColor.green) / lifespan;
			colorDelta.blue = (endColorBlue - startColor.blue) / lifespan;
			colorDelta.alpha = (endColorAlpha - startColor.alpha) / lifespan;
			// rotation
			var startRotation:Number = mStartRotation + mStartRotationVariance * (Math.random() * 2.0 - 1.0);
			var endRotation:Number = mEndRotation + mEndRotationVariance * (Math.random() * 2.0 - 1.0);
			particle.rotation = startRotation;
			particle.rotationDelta = (endRotation - startRotation) / lifespan;
		}

		/**
		 * @inheritDoc
		 *
		 */
		protected function advanceParticle(particle:Particle3D, passedTime:Number):void
		{
			var restTime:Number = particle.totalTime - particle.currentTime;
			passedTime = restTime > passedTime ? passedTime : restTime;
			particle.currentTime += passedTime;

			if (mEmitterType == EmitterType.RADIAL)
			{
				particle.emitRotation += particle.emitRotationDelta * passedTime;
				particle.emitRadius -= particle.emitRadiusDelta * passedTime;
				particle.x = mEmitterX - Math.cos(particle.emitRotation) * particle.emitRadius;
				particle.y = mEmitterY - Math.sin(particle.emitRotation) * particle.emitRadius;

				if (particle.emitRadius < mMinRadius)
					particle.currentTime = particle.totalTime;
			}
			else
			{
				var distanceX:Number = particle.x - particle.startX;
				var distanceY:Number = particle.y - particle.startY;
				var distanceScalar:Number = Math.sqrt(distanceX * distanceX + distanceY * distanceY);

				if (distanceScalar < 0.01)
					distanceScalar = 0.01;
				var radialX:Number = distanceX / distanceScalar;
				var radialY:Number = distanceY / distanceScalar;
				var tangentialX:Number = radialX;
				var tangentialY:Number = radialY;
				radialX *= particle.radialAcceleration;
				radialY *= particle.radialAcceleration;
				var newY:Number = tangentialX;
				tangentialX = -tangentialY * particle.tangentialAcceleration;
				tangentialY = newY * particle.tangentialAcceleration;
				particle.velocityX += passedTime * (mGravityX + radialX + tangentialX);
				particle.velocityY += passedTime * (mGravityY + radialY + tangentialY);
				particle.x += particle.velocityX * passedTime;
				particle.y += particle.velocityY * passedTime;
			}
			particle.scale += particle.scaleDelta * passedTime;
			particle.rotation += particle.rotationDelta * passedTime;
			particle.colorArgb.red += particle.colorArgbDelta.red * passedTime;
			particle.colorArgb.green += particle.colorArgbDelta.green * passedTime;
			particle.colorArgb.blue += particle.colorArgbDelta.blue * passedTime;
			particle.colorArgb.alpha += particle.colorArgbDelta.alpha * passedTime;
			particle.color = particle.colorArgb.toRgb();
			particle.alpha = particle.colorArgb.alpha;
		}

		private function updateEmissionRate():void
		{
			emissionRate = mMaxNumParticles / mLifespan;
		}

		public function get emitterType():int
		{
			return mEmitterType;
		}

		public function set emitterType(value:int):void
		{
			mEmitterType = value;
		}

		public function get emitterXVariance():Number
		{
			return mEmitterXVariance;
		}

		public function set emitterXVariance(value:Number):void
		{
			mEmitterXVariance = value;
		}

		public function get emitterYVariance():Number
		{
			return mEmitterYVariance;
		}

		public function set emitterYVariance(value:Number):void
		{
			mEmitterYVariance = value;
		}

		public function get maxNumParticles():int
		{
			return mMaxNumParticles;
		}

		public function set maxNumParticles(value:int):void
		{
			maxCapacity = value;
			mMaxNumParticles = maxCapacity;
			updateEmissionRate();
		}

		public function get lifespan():Number
		{
			return mLifespan;
		}

		public function set lifespan(value:Number):void
		{
			mLifespan = Math.max(0.01, value);
			updateEmissionRate();
		}

		public function get lifespanVariance():Number
		{
			return mLifespanVariance;
		}

		public function set lifespanVariance(value:Number):void
		{
			mLifespanVariance = value;
		}

		public function get startSize():Number
		{
			return mStartSize;
		}

		public function set startSize(value:Number):void
		{
			mStartSize = value;
		}

		public function get startSizeVariance():Number
		{
			return mStartSizeVariance;
		}

		public function set startSizeVariance(value:Number):void
		{
			mStartSizeVariance = value;
		}

		public function get endSize():Number
		{
			return mEndSize;
		}

		public function set endSize(value:Number):void
		{
			mEndSize = value;
		}

		public function get endSizeVariance():Number
		{
			return mEndSizeVariance;
		}

		public function set endSizeVariance(value:Number):void
		{
			mEndSizeVariance = value;
		}

		public function get emitAngle():Number
		{
			return mEmitAngle;
		}

		public function set emitAngle(value:Number):void
		{
			mEmitAngle = value;
		}

		public function get emitAngleVariance():Number
		{
			return mEmitAngleVariance;
		}

		public function set emitAngleVariance(value:Number):void
		{
			mEmitAngleVariance = value;
		}

		public function get startRotation():Number
		{
			return mStartRotation;
		}

		public function set startRotation(value:Number):void
		{
			mStartRotation = value;
		}

		public function get startRotationVariance():Number
		{
			return mStartRotationVariance;
		}

		public function set startRotationVariance(value:Number):void
		{
			mStartRotationVariance = value;
		}

		public function get endRotation():Number
		{
			return mEndRotation;
		}

		public function set endRotation(value:Number):void
		{
			mEndRotation = value;
		}

		public function get endRotationVariance():Number
		{
			return mEndRotationVariance;
		}

		public function set endRotationVariance(value:Number):void
		{
			mEndRotationVariance = value;
		}

		public function get speed():Number
		{
			return mSpeed;
		}

		public function set speed(value:Number):void
		{
			mSpeed = value;
		}

		public function get speedVariance():Number
		{
			return mSpeedVariance;
		}

		public function set speedVariance(value:Number):void
		{
			mSpeedVariance = value;
		}

		public function get gravityX():Number
		{
			return mGravityX;
		}

		public function set gravityX(value:Number):void
		{
			mGravityX = value;
		}

		public function get gravityY():Number
		{
			return mGravityY;
		}

		public function set gravityY(value:Number):void
		{
			mGravityY = value;
		}

		public function get radialAcceleration():Number
		{
			return mRadialAcceleration;
		}

		public function set radialAcceleration(value:Number):void
		{
			mRadialAcceleration = value;
		}

		public function get radialAccelerationVariance():Number
		{
			return mRadialAccelerationVariance;
		}

		public function set radialAccelerationVariance(value:Number):void
		{
			mRadialAccelerationVariance = value;
		}

		public function get tangentialAcceleration():Number
		{
			return mTangentialAcceleration;
		}

		public function set tangentialAcceleration(value:Number):void
		{
			mTangentialAcceleration = value;
		}

		public function get tangentialAccelerationVariance():Number
		{
			return mTangentialAccelerationVariance;
		}

		public function set tangentialAccelerationVariance(value:Number):void
		{
			mTangentialAccelerationVariance = value;
		}

		public function get maxRadius():Number
		{
			return mMaxRadius;
		}

		public function set maxRadius(value:Number):void
		{
			mMaxRadius = value;
		}

		public function get maxRadiusVariance():Number
		{
			return mMaxRadiusVariance;
		}

		public function set maxRadiusVariance(value:Number):void
		{
			mMaxRadiusVariance = value;
		}

		public function get minRadius():Number
		{
			return mMinRadius;
		}

		public function set minRadius(value:Number):void
		{
			mMinRadius = value;
		}

		public function get rotatePerSecond():Number
		{
			return mRotatePerSecond;
		}

		public function set rotatePerSecond(value:Number):void
		{
			mRotatePerSecond = value;
		}

		public function get rotatePerSecondVariance():Number
		{
			return mRotatePerSecondVariance;
		}

		public function set rotatePerSecondVariance(value:Number):void
		{
			mRotatePerSecondVariance = value;
		}

		public function get startColor():ColorArgb
		{
			return mStartColor;
		}

		public function set startColor(value:ColorArgb):void
		{
			mStartColor = value;
		}

		public function get startColorVariance():ColorArgb
		{
			return mStartColorVariance;
		}

		public function set startColorVariance(value:ColorArgb):void
		{
			mStartColorVariance = value;
		}

		public function get endColor():ColorArgb
		{
			return mEndColor;
		}

		public function set endColor(value:ColorArgb):void
		{
			mEndColor = value;
		}

		public function get endColorVariance():ColorArgb
		{
			return mEndColorVariance;
		}

		public function set endColorVariance(value:ColorArgb):void
		{
			mEndColorVariance = value;
		}

		private var mTexture:Texture;

		private var mParticles:Vector.<Particle3D>;

		private var mFrameTime:Number;

		private var mProgram:Program3D;

		private var mVertexData:VertexData;

		private var mVertexBuffer:VertexBuffer3D;

		private var mIndices:Vector.<uint>;

		private var mIndexBuffer:IndexBuffer3D;

		private var mNumParticles:int;

		private var mMaxCapacity:int;

		private var mEmissionRate:Number; // emitted particles per second

		private var mEmissionTime:Number;

		/** Helper objects. */
		private static var sHelperMatrix:Matrix = new Matrix();

		private static var sHelperPoint:Point = new Point();

		private static var sRenderAlpha:Vector.<Number> = new <Number>[ 1.0, 1.0,
																		1.0, 1.0 ];

		protected var mEmitterX:Number;

		protected var mEmitterY:Number;

		protected var mPremultipliedAlpha:Boolean;

		protected var mBlendFactorSource:String;

		protected var mBlendFactorDestination:String;

		public override function dispose():void
		{
			Starling.current.stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated);

			if (mVertexBuffer)
				mVertexBuffer.dispose();

			if (mIndexBuffer)
				mIndexBuffer.dispose();
			super.dispose();
		}

		private function onContextCreated(... nouse):void
		{
			createProgram();
			raiseCapacity(0);
		}

		private function raiseCapacity(byAmount:int):void
		{
			var oldCapacity:int = capacity;
			var newCapacity:int = Math.min(mMaxCapacity, capacity + byAmount);
			var context:Context3D = Starling.context;

			if (context == null)
				throw new MissingContextError();
			var baseVertexData:VertexData = new VertexData(4);
			baseVertexData.setTexCoords(0, 0.0, 0.0);
			baseVertexData.setTexCoords(1, 1.0, 0.0);
			baseVertexData.setTexCoords(2, 0.0, 1.0);
			baseVertexData.setTexCoords(3, 1.0, 1.0);
			mTexture.adjustVertexData(baseVertexData, 0, 4);
			mParticles.fixed = false;
			mIndices.fixed = false;

			for (var i:int = oldCapacity; i < newCapacity; ++i)
			{
				var numVertices:int = i * 4;
				var numIndices:int = i * 6;
				mParticles[i] = new Particle3D();
				mVertexData.append(baseVertexData);
				mIndices[numIndices] = numVertices;
				mIndices[int(numIndices + 1)] = numVertices + 1;
				mIndices[int(numIndices + 2)] = numVertices + 2;
				mIndices[int(numIndices + 3)] = numVertices + 1;
				mIndices[int(numIndices + 4)] = numVertices + 3;
				mIndices[int(numIndices + 5)] = numVertices + 2;
			}
			mParticles.fixed = true;
			mIndices.fixed = true;

			// upload data to vertex and index buffers
			if (mVertexBuffer)
				mVertexBuffer.dispose();

			if (mIndexBuffer)
				mIndexBuffer.dispose();
			mVertexBuffer = context.createVertexBuffer(newCapacity * 4, VertexData.ELEMENTS_PER_VERTEX);
			mVertexBuffer.uploadFromVector(mVertexData.rawData, 0, newCapacity * 4);
			mIndexBuffer = context.createIndexBuffer(newCapacity * 6);
			mIndexBuffer.uploadFromVector(mIndices, 0, newCapacity * 6);
		}

		/** Starts the emitter for a certain time. @default infinite time */
		public function start(duration:Number = Number.MAX_VALUE):void
		{
			if (mEmissionRate != 0)
				mEmissionTime = duration;
		}

		/** Stops emitting new particles. Depending on 'clearParticles', the existing particles
		 *  will either keep animating until they die or will be removed right away. */
		public function stop(clearParticles:Boolean = false):void
		{
			mEmissionTime = 0.0;

			if (clearParticles)
				clear();
		}

		/** Removes all currently active particles. */
		public function clear():void
		{
			mNumParticles = 0;
		}

		/** Returns an empty rectangle at the particle system's position. Calculating the
		 *  actual bounds would be too expensive. */
		public override function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null):Rectangle
		{
			if (resultRect == null)
				resultRect = new Rectangle();
			getTransformationMatrix(targetSpace, sHelperMatrix);
			MatrixUtil.transformCoords(sHelperMatrix, 0, 0, sHelperPoint);
			resultRect.x = sHelperPoint.x;
			resultRect.y = sHelperPoint.y;
			resultRect.width = resultRect.height = 0;
			return resultRect;
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function advanceTime(passedTime:Number):void
		{
			var particleIndex:int = 0;
			var particle:Particle3D;

			// advance existing particles
			while (particleIndex < mNumParticles)
			{
				particle = mParticles[particleIndex] as Particle3D;

				if (particle.currentTime < particle.totalTime)
				{
					advanceParticle(particle, passedTime);
					++particleIndex;
				}
				else
				{
					if (particleIndex != mNumParticles - 1)
					{
						var nextParticle:Particle3D = mParticles[int(mNumParticles - 1)] as Particle3D;
						mParticles[int(mNumParticles - 1)] = particle;
						mParticles[particleIndex] = nextParticle;
					}
					--mNumParticles;

					if (mNumParticles == 0 && mEmissionTime == 0)
						dispatchEvent(new Event(Event.COMPLETE));
				}
			}

			// create and advance new particles
			if (mEmissionTime > 0)
			{
				var timeBetweenParticles:Number = 1.0 / mEmissionRate;
				mFrameTime += passedTime;

				while (mFrameTime > 0)
				{
					if (mNumParticles < mMaxCapacity)
					{
						if (mNumParticles == capacity)
							raiseCapacity(capacity);
						particle = mParticles[mNumParticles] as Particle3D;
						initParticle(particle);

						// particle might be dead at birth
						if (particle.totalTime > 0.0)
						{
							advanceParticle(particle, mFrameTime);
							++mNumParticles
						}
					}
					mFrameTime -= timeBetweenParticles;
				}

				if (mEmissionTime != Number.MAX_VALUE)
					mEmissionTime = Math.max(0.0, mEmissionTime - passedTime);
			}
			// update vertex data
			var vertexID:int = 0;
			var color:uint;
			var alpha:Number;
			var rotation:Number;
			var x:Number, y:Number;
			var xOffset:Number, yOffset:Number;
			var textureWidth:Number = mTexture.width;
			var textureHeight:Number = mTexture.height;

			for (var i:int = 0; i < mNumParticles; ++i)
			{
				vertexID = i << 2;
				particle = mParticles[i] as Particle3D;
				color = particle.color;
				alpha = particle.alpha;
				rotation = particle.rotation;
				x = particle.x;
				y = particle.y;
				xOffset = textureWidth * particle.scale >> 1;
				yOffset = textureHeight * particle.scale >> 1;

				for (var j:int = 0; j < 4; ++j)
				{
					mVertexData.setColor(vertexID + j, color);
					mVertexData.setAlpha(vertexID + j, alpha);
				}

				if (rotation)
				{
					var cos:Number = Math.cos(rotation);
					var sin:Number = Math.sin(rotation);
					var cosX:Number = cos * xOffset;
					var cosY:Number = cos * yOffset;
					var sinX:Number = sin * xOffset;
					var sinY:Number = sin * yOffset;
					mVertexData.setPosition(vertexID + 3, x - cosX + sinY, y - sinX - cosY);
					mVertexData.setPosition(vertexID + 2, x + cosX + sinY, y + sinX - cosY);
					mVertexData.setPosition(vertexID + 1, x - cosX - sinY, y - sinX + cosY);
					mVertexData.setPosition(vertexID + 0, x + cosX - sinY, y + sinX + cosY);
				}
				else
				{
					// optimization for rotation == 0
					mVertexData.setPosition(vertexID + 3, x - xOffset, y - yOffset);
					mVertexData.setPosition(vertexID + 2, x + xOffset, y - yOffset);
					mVertexData.setPosition(vertexID + 1, x - xOffset, y + yOffset);
					mVertexData.setPosition(vertexID + 0, x + xOffset, y + yOffset);
				}
			}
		}

		public override function render(support:RenderSupport, alpha:Number):void
		{
			if (mNumParticles == 0)
				return;
			// always call this method when you write custom rendering code!
			// it causes all previously batched quads/images to render.
			support.finishQuadBatch();

			// make this call to keep the statistics display in sync.
			// to play it safe, it's done in a backwards-compatible way here.
			if (support.hasOwnProperty("raiseDrawCount"))
				support.raiseDrawCount();
			alpha *= this.alpha;
			var context:Context3D = Starling.context;
			var pma:Boolean = texture.premultipliedAlpha;
			sRenderAlpha[0] = sRenderAlpha[1] = sRenderAlpha[2] = pma ? alpha : 1.0;
			sRenderAlpha[3] = alpha;

			if (context == null)
				throw new MissingContextError();
			mVertexBuffer.uploadFromVector(mVertexData.rawData, 0, mNumParticles * 4);
			mIndexBuffer.uploadFromVector(mIndices, 0, mNumParticles * 6);
			context.setBlendFactors(mBlendFactorSource, mBlendFactorDestination);
			context.setTextureAt(0, mTexture.base);
			context.setProgram(mProgram);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, support.mvpMatrix3D, true);
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, sRenderAlpha, 1);
			context.setVertexBufferAt(0, mVertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			context.setVertexBufferAt(1, mVertexBuffer, VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4);
			context.setVertexBufferAt(2, mVertexBuffer, VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			context.drawTriangles(mIndexBuffer, 0, mNumParticles * 2);
			context.setTextureAt(0, null);
			context.setVertexBufferAt(0, null);
			context.setVertexBufferAt(1, null);
			context.setVertexBufferAt(2, null);
		}

		/** Initialize the <tt>ParticleSystem</tt> with particles distributed randomly throughout
		 *  their lifespans. */
		public function populate(count:int):void
		{
			count = Math.min(count, mMaxCapacity - mNumParticles);

			if (mNumParticles + count > capacity)
				raiseCapacity(mNumParticles + count - capacity);
			var p:Particle3D;

			for (var i:int = 0; i < count; i++)
			{
				p = mParticles[mNumParticles + i];
				initParticle(p);
				advanceParticle(p, Math.random() * p.totalTime);
			}
			mNumParticles += count;
		}

		// program management
		private function createProgram():void
		{
			var mipmap:Boolean = mTexture.mipMapping;
			var textureFormat:String = mTexture.format;
			var programName:String = "age.ParticleSystem." + textureFormat + (mipmap ? "+mm" : "");
			mProgram = Starling.current.getProgram(programName);

			if (mProgram == null)
			{
				var textureOptions:String = "2d, clamp, linear, " + (mipmap ? "mipnearest" : "mipnone");

				if (textureFormat == Context3DTextureFormat.COMPRESSED)
					textureOptions += ", dxt1";
				else if (textureFormat == "compressedAlpha")
					textureOptions += ", dxt5";
				var vertexProgramCode:String = "m44 op, va0, vc0 \n" + // 4x4 matrix transform to output clipspace
					"mul v0, va1, vc4 \n" + // multiply color with alpha and pass to fragment program
					"mov v1, va2      \n"; // pass texture coordinates to fragment program
				var fragmentProgramCode:String = "tex ft1, v1, fs0 <" + textureOptions + "> \n" + // sample texture 0
					"mul oc, ft1, v0"; // multiply color with texel color
				var vertexProgramAssembler:AGALMiniAssembler = new AGALMiniAssembler();
				vertexProgramAssembler.assemble(Context3DProgramType.VERTEX, vertexProgramCode);
				var fragmentProgramAssembler:AGALMiniAssembler = new AGALMiniAssembler();
				fragmentProgramAssembler.assemble(Context3DProgramType.FRAGMENT, fragmentProgramCode);
				Starling.current.registerProgram(programName, vertexProgramAssembler.agalcode, fragmentProgramAssembler.agalcode);
				mProgram = Starling.current.getProgram(programName);
			}
		}

		public function get isEmitting():Boolean
		{
			return mEmissionTime > 0 && mEmissionRate > 0;
		}

		public function get capacity():int
		{
			return mVertexData.numVertices / 4;
		}

		public function get numParticles():int
		{
			return mNumParticles;
		}

		public function get maxCapacity():int
		{
			return mMaxCapacity;
		}

		public function set maxCapacity(value:int):void
		{
			mMaxCapacity = Math.min(8192, value);
		}

		public function get emissionRate():Number
		{
			return mEmissionRate;
		}

		public function set emissionRate(value:Number):void
		{
			mEmissionRate = value;
		}

		public function get emitterX():Number
		{
			return mEmitterX;
		}

		public function set emitterX(value:Number):void
		{
			mEmitterX = value;
		}

		public function get emitterY():Number
		{
			return mEmitterY;
		}

		public function set emitterY(value:Number):void
		{
			mEmitterY = value;
		}

		public function get blendFactorSource():String
		{
			return mBlendFactorSource;
		}

		public function set blendFactorSource(value:String):void
		{
			mBlendFactorSource = value;
		}

		public function get blendFactorDestination():String
		{
			return mBlendFactorDestination;
		}

		public function set blendFactorDestination(value:String):void
		{
			mBlendFactorDestination = value;
		}

		public function get texture():Texture
		{
			return mTexture;
		}

		public function set texture(value:Texture):void
		{
			mTexture = value;
			createProgram();
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function get zIndex():int
		{
			return _position.z;
		}

		private var _direction:int;

		/**
		 * @inheritDoc
		 *
		 */
		public function get direction():int
		{
			return _direction;
		}

		public function set direction(value:int):void
		{
			_direction = value;
			scaleX = Math.abs(scaleX) * (value == Direction.RIGHT ? 1 : -1);
		}

		private var _position:Vector3D = new Vector3D;

		/**
		 * @inheritDoc
		 *
		 */
		public function get position():Vector3D
		{
			return _position;
		}

		public function set position(value:Vector3D):void
		{
			_position = value;
			validatePosition();
		}

		/**
		 * 相当于调用 position.setTo(x, y, z); validatePosition();
		 * @param x
		 * @param y
		 * @param z
		 *
		 */
		public function setPosition(x:Number, y:Number, z:Number):void
		{
			position.setTo(x, y, z);
			validatePosition();
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function setX(value:Number):void
		{
			position.x = value;
			validatePositionX();
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function setY(value:Number):void
		{
			position.y = value;
			validatePositionYZ();
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function setZ(value:Number):void
		{
			position.z = value;
			validatePositionYZ();
		}

		/**
		 * 当 position 发生变化时调用该方法以投影新坐标
		 *
		 */
		[Inline]
		final protected function validatePosition():void
		{
			if (_projectY == null)
			{
				return;
			}
			mEmitterX = position.x;
			mEmitterY = _projectY(position.y, position.z);
		}

		/**
		 * 当 position.x 发生变化时调用该方法以投影新坐标
		 *
		 */
		[Inline]
		final protected function validatePositionX():void
		{
			super.x = position.x;
		}

		/**
		 * 当 position.y 或 position.z 发生变化时调用该方法以投影新坐标
		 *
		 */
		[Inline]
		final protected function validatePositionYZ():void
		{
			if (_projectY == null)
			{
				return;
			}
			super.y = _projectY(position.y, position.z);
		}

		private var _projectY:Function;

		/**
		 * @inheritDoc
		 *
		 */
		public function get projectY():Function
		{
			return _projectY;
		}

		public function set projectY(value:Function):void
		{
			_projectY = value;

			if (value != null)
			{
				validatePosition();
			}
		}

		/**
		 * @private
		 */
		[Deprecated("不允许从外部设置该属性。如要设置坐标，请使用 position 属性或 setPosition", "position")]
		public override function set y(value:Number):void
		{
			throw new IllegalOperationError("不允许从外部设置该属性，要设置坐标，请使用 position 属性");
		}

		/**
		 * @private
		 */
		[Deprecated("不允许从外部设置该属性。如要设置坐标，请使用 position 属性或 setPosition", "position")]
		public override function set x(value:Number):void
		{
			throw new IllegalOperationError("不允许从外部设置该属性，要设置坐标，请使用 position 属性");
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

		protected static var _defaultTextureBitmapData:BitmapData;

		/**
		 * 默认粒子动画使用的贴图 BitmapData
		 * @return
		 *
		 */
		public static function get defaultTextureBitmapData():BitmapData
		{
			if (!_defaultTextureBitmapData)
			{
				const textureSize:Number = 32;
				const blur:Number = 10;
				const bmd:BitmapData = new BitmapData(textureSize, textureSize, true, 0);
				var shape:Shape = new Shape();
				shape.graphics.beginFill(0xffffff, 1);
				shape.graphics.drawCircle(textureSize / 2, textureSize / 2, (textureSize - blur * 2) / 2);
				shape.graphics.endFill();
				bmd.draw(shape);
				bmd.applyFilter(bmd, bmd.rect, bmd.rect.topLeft, new BlurFilter(blur, blur, BitmapFilterQuality.HIGH));
				_defaultTextureBitmapData = bmd;
			}
			return _defaultTextureBitmapData;
		}

		protected static var _defaultTexture:Texture;

		/**
		 * 默认贴图
		 * @return
		 *
		 */
		public static function get defaultTexture():Texture
		{
			if (!_defaultTexture)
			{
				_defaultTexture = Texture.fromBitmapData(defaultTextureBitmapData, true);
			}
			return _defaultTexture;
		}
	}
}
