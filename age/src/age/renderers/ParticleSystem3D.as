package age.renderers
{
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display3D.Context3D;
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
		public function ParticleSystem3D(initialCapacity:int = 128, maxCapacity:int = 8192)
		{
			this.config = config;
			_maxCapacity = Math.min(8192, maxCapacity);
			this.initialCapacity = Math.min(initialCapacity, maxCapacity);
			Starling.current.stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate, false, 0, true);
		}

		/**
		 * 使用默认设置
		 *
		 */
		public function useDefaultConfig():void
		{
			config = new Particle3DConfig();
			texture = defaultTexture;
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

		private var _texture:Texture;

		/**
		 * 设置或获取当前贴图
		 * @return
		 *
		 */
		public function get texture():Texture
		{
			return _texture;
		}

		public function set texture(value:Texture):void
		{
			if (_texture != value)
			{
				_texture = value;
				createProgram();
				raiseCapacity(initialCapacity);
				validate();
			}
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

				if (_config)
				{
					parseConfig(value);
				}
				validate();
			}
		}

		/**
		 * 调用该方法验证更新配置
		 *
		 */
		public function validate():void
		{
			if (_config && _texture)
			{
				start();
			}
			else
			{
				stop();
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
			_maxNumParticles = config.maxNumParticles;
			_lifespan = Math.max(0.01, config.lifespan);
			emissionRate = _maxNumParticles / _lifespan;
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
			blendFactorSource = config.blendFactorSource;
			blendFactorDestination = config.blendFactorDestination;
		}

		// emitter configuration                            // .pex element name
		private var mEmitterType:int; // emitterType

		private var mEmitterXVariance:Number; // sourcePositionVariance x

		private var mEmitterYVariance:Number; // sourcePositionVariance y

		// particle configuration
		private var _maxNumParticles:int; // maxParticles

		private var _lifespan:Number; // particleLifeSpan

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
			var lifespan:Number = _lifespan + mLifespanVariance * (Math.random() * 2.0 - 1.0);
			particle.currentTime = 0.0;
			particle.totalTime = lifespan > 0.0 ? lifespan : 0.0;

			if (lifespan <= 0.0)
			{
				return;
			}
			particle.x = emitterX + mEmitterXVariance * (Math.random() * 2.0 - 1.0);
			particle.y = emitterY + mEmitterYVariance * (Math.random() * 2.0 - 1.0);
			particle.startX = emitterX;
			particle.startY = emitterY;
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
				particle.x = emitterX - Math.cos(particle.emitRotation) * particle.emitRadius;
				particle.y = emitterY - Math.sin(particle.emitRotation) * particle.emitRadius;

				if (particle.emitRadius < mMinRadius)
				{
					particle.currentTime = particle.totalTime;
				}
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
			emissionRate = _maxNumParticles / _lifespan;
		}

		public function get maxNumParticles():int
		{
			return _maxNumParticles;
		}

		public function set maxNumParticles(value:int):void
		{
			maxCapacity = value;
			_maxNumParticles = maxCapacity;
			updateEmissionRate();
		}

		public function get lifespan():Number
		{
			return _lifespan;
		}

		public function set lifespan(value:Number):void
		{
			_lifespan = Math.max(0.01, value);
			updateEmissionRate();
		}

		private var particles:Vector.<Particle3D> = new Vector.<Particle3D>(0, false);;

		private var frameTime:Number = 0;

		private var program:Program3D;

		private var vertexData:VertexData = new VertexData(0);

		private var vertexBuffer:VertexBuffer3D;

		private var indices:Vector.<uint> = new Vector.<uint>;

		private var indexBuffer:IndexBuffer3D;

		private var _numParticles:int;

		/**
		 * 每秒粒子发射数
		 */
		private var emissionRate:Number = 0;

		private var emissionTime:Number = 0;

		protected var emitterX:Number = 0;

		protected var emitterY:Number = 0;

		protected var blendFactorSource:String;

		protected var blendFactorDestination:String;

		/**
		 * @inheritDoc
		 *
		 */
		public override function dispose():void
		{
			Starling.current.stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);

			if (vertexBuffer)
			{
				vertexBuffer.dispose();
			}

			if (indexBuffer)
			{
				indexBuffer.dispose();
			}
			_config = null;
			stop(true);
			super.dispose();
		}

		/**
		 * @private
		 *
		 */
		private function onContext3DCreate(event:*):void
		{
			createProgram();
			raiseCapacity(0);
		}

		/**
		 * 增加容量
		 * @param byAmount
		 *
		 */
		private function raiseCapacity(byAmount:int):void
		{
			var oldCapacity:int = capacity;
			var newCapacity:int = Math.min(_maxCapacity, capacity + byAmount);
			var context:Context3D = Starling.context;

			if (context == null)
				throw new MissingContextError();
			var baseVertexData:VertexData = new VertexData(4);
			baseVertexData.setTexCoords(0, 0.0, 0.0);
			baseVertexData.setTexCoords(1, 1.0, 0.0);
			baseVertexData.setTexCoords(2, 0.0, 1.0);
			baseVertexData.setTexCoords(3, 1.0, 1.0);
			_texture.adjustVertexData(baseVertexData, 0, 4);
			particles.fixed = false;
			indices.fixed = false;

			for (var i:int = oldCapacity; i < newCapacity; ++i)
			{
				var numVertices:int = i * 4;
				var numIndices:int = i * 6;
				particles[i] = new Particle3D();
				vertexData.append(baseVertexData);
				indices[numIndices] = numVertices;
				indices[int(numIndices + 1)] = numVertices + 1;
				indices[int(numIndices + 2)] = numVertices + 2;
				indices[int(numIndices + 3)] = numVertices + 1;
				indices[int(numIndices + 4)] = numVertices + 3;
				indices[int(numIndices + 5)] = numVertices + 2;
			}
			particles.fixed = true;
			indices.fixed = true;

			// 上传顶点和索引缓冲
			if (vertexBuffer)
			{
				vertexBuffer.dispose();
			}

			if (indexBuffer)
			{
				indexBuffer.dispose();
			}
			vertexBuffer = context.createVertexBuffer(newCapacity * 4, VertexData.ELEMENTS_PER_VERTEX);
			vertexBuffer.uploadFromVector(vertexData.rawData, 0, newCapacity * 4);
			indexBuffer = context.createIndexBuffer(newCapacity * 6);
			indexBuffer.uploadFromVector(indices, 0, newCapacity * 6);
		}

		/**
		 * 开始发射粒子
		 * @param duration 持续时间，默认值是 Number.MAX_VALUE，差不多是永远
		 *
		 */
		public function start(duration:Number = Number.MAX_VALUE):void
		{
			if (emissionRate != 0)
			{
				emissionTime = duration;
			}
		}

		/**
		 * 停止发射新粒子
		 * @param clearParticles 设置为 true 可以立即清除所有显示的粒子，默认 false
		 *
		 */
		public function stop(clearParticles:Boolean = false):void
		{
			emissionTime = 0.0;

			if (clearParticles)
			{
				clear();
			}
		}

		/**
		 * 立即清除当前所有显示的粒子
		 *
		 */
		public function clear():void
		{
			_numParticles = 0;
		}

		/** Returns an empty rectangle at the particle system's position. Calculating the
		 *  actual bounds would be too expensive. */
		public override function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null):Rectangle
		{
			if (resultRect == null)
				resultRect = new Rectangle();
			getTransformationMatrix(targetSpace, helperMatrix);
			MatrixUtil.transformCoords(helperMatrix, 0, 0, helperPoint);
			resultRect.x = helperPoint.x;
			resultRect.y = helperPoint.y;
			resultRect.width = resultRect.height = 0;
			return resultRect;
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function advanceTime(passedTime:Number):void
		{
			if (!_config || !_texture)
			{
				return;
			}
			var particleIndex:int = 0;
			var particle:Particle3D;

			// advance existing particles
			while (particleIndex < _numParticles)
			{
				particle = particles[particleIndex] as Particle3D;

				if (particle.currentTime < particle.totalTime)
				{
					advanceParticle(particle, passedTime);
					++particleIndex;
				}
				else
				{
					if (particleIndex != _numParticles - 1)
					{
						var nextParticle:Particle3D = particles[int(_numParticles - 1)] as Particle3D;
						particles[int(_numParticles - 1)] = particle;
						particles[particleIndex] = nextParticle;
					}
					--_numParticles;

					if (_numParticles == 0 && emissionTime == 0)
						dispatchEvent(new Event(Event.COMPLETE));
				}
			}

			// create and advance new particles
			if (emissionTime > 0)
			{
				var timeBetweenParticles:Number = 1.0 / emissionRate;
				frameTime += passedTime;

				while (frameTime > 0)
				{
					if (_numParticles < _maxCapacity)
					{
						if (_numParticles == capacity)
							raiseCapacity(capacity);
						particle = particles[_numParticles] as Particle3D;
						initParticle(particle);

						// particle might be dead at birth
						if (particle.totalTime > 0.0)
						{
							advanceParticle(particle, frameTime);
							++_numParticles
						}
					}
					frameTime -= timeBetweenParticles;
				}

				if (emissionTime != Number.MAX_VALUE)
					emissionTime = Math.max(0.0, emissionTime - passedTime);
			}
			// update vertex data
			var vertexID:int = 0;
			var color:uint;
			var alpha:Number;
			var rotation:Number;
			var x:Number, y:Number;
			var xOffset:Number, yOffset:Number;
			var textureWidth:Number = _texture.width;
			var textureHeight:Number = _texture.height;

			for (var i:int = 0; i < _numParticles; ++i)
			{
				vertexID = i << 2;
				particle = particles[i] as Particle3D;
				color = particle.color;
				alpha = particle.alpha;
				rotation = particle.rotation;
				x = particle.x;
				y = particle.y;
				xOffset = textureWidth * particle.scale >> 1;
				yOffset = textureHeight * particle.scale >> 1;

				for (var j:int = 0; j < 4; ++j)
				{
					vertexData.setColor(vertexID + j, color);
					vertexData.setAlpha(vertexID + j, alpha);
				}

				if (rotation)
				{
					var cos:Number = Math.cos(rotation);
					var sin:Number = Math.sin(rotation);
					var cosX:Number = cos * xOffset;
					var cosY:Number = cos * yOffset;
					var sinX:Number = sin * xOffset;
					var sinY:Number = sin * yOffset;
					vertexData.setPosition(vertexID + 3, x - cosX + sinY, y - sinX - cosY);
					vertexData.setPosition(vertexID + 2, x + cosX + sinY, y + sinX - cosY);
					vertexData.setPosition(vertexID + 1, x - cosX - sinY, y - sinX + cosY);
					vertexData.setPosition(vertexID + 0, x + cosX - sinY, y + sinX + cosY);
				}
				else
				{
					// optimization for rotation == 0
					vertexData.setPosition(vertexID + 3, x - xOffset, y - yOffset);
					vertexData.setPosition(vertexID + 2, x + xOffset, y - yOffset);
					vertexData.setPosition(vertexID + 1, x - xOffset, y + yOffset);
					vertexData.setPosition(vertexID + 0, x + xOffset, y + yOffset);
				}
			}
		}

		public override function render(support:RenderSupport, alpha:Number):void
		{
			if (_numParticles == 0)
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
			renderAlpha[0] = renderAlpha[1] = renderAlpha[2] = pma ? alpha : 1.0;
			renderAlpha[3] = alpha;

			if (context == null)
			{
				throw new MissingContextError()
			}
			vertexBuffer.uploadFromVector(vertexData.rawData, 0, _numParticles * 4);
			indexBuffer.uploadFromVector(indices, 0, _numParticles * 6);
			context.setBlendFactors(blendFactorSource, blendFactorDestination);
			context.setTextureAt(0, _texture.base);
			context.setProgram(program);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, support.mvpMatrix3D, true);
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, renderAlpha, 1);
			context.setVertexBufferAt(0, vertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			context.setVertexBufferAt(1, vertexBuffer, VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4);
			context.setVertexBufferAt(2, vertexBuffer, VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			context.drawTriangles(indexBuffer, 0, _numParticles * 2);
			context.setTextureAt(0, null);
			context.setVertexBufferAt(0, null);
			context.setVertexBufferAt(1, null);
			context.setVertexBufferAt(2, null);
		}

		/** Initialize the <tt>ParticleSystem</tt> with particles distributed randomly throughout
		 *  their lifespans. */
		public function populate(count:int):void
		{
			count = Math.min(count, _maxCapacity - _numParticles);

			if (_numParticles + count > capacity)
				raiseCapacity(_numParticles + count - capacity);
			var p:Particle3D;

			for (var i:int = 0; i < count; i++)
			{
				p = particles[_numParticles + i];
				initParticle(p);
				advanceParticle(p, Math.random() * p.totalTime);
			}
			_numParticles += count;
		}

		// program management
		private function createProgram():void
		{
			var mipmap:Boolean = _texture.mipMapping;
			var textureFormat:String = _texture.format;
			var programName:String = "age.ParticleSystem3D." + textureFormat + (mipmap ? "+mm" : "");
			program = Starling.current.getProgram(programName);

			if (program == null)
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
				program = Starling.current.getProgram(programName);
			}
		}

		/**
		 * 指示粒子系统是否工作中
		 * @return
		 *
		 */
		public function get isEmitting():Boolean
		{
			return emissionTime > 0 && emissionRate > 0;
		}

		/**
		 * 粒子容量
		 * @return
		 *
		 */
		public function get capacity():int
		{
			return vertexData.numVertices / 4;
		}

		/**
		 * 粒子数
		 * @return
		 *
		 */
		public function get numParticles():int
		{
			return _numParticles;
		}

		private var _maxCapacity:int;

		/**
		 * 设置或获取最大容量
		 * @return
		 *
		 */
		public function get maxCapacity():int
		{
			return _maxCapacity;
		}

		public function set maxCapacity(value:int):void
		{
			_maxCapacity = Math.min(8192, value);
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
		 * @inheritDoc
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
			emitterX = position.x;
			emitterY = _projectY(position.y, position.z);
		}

		/**
		 * 当 position.x 发生变化时调用该方法以投影新坐标
		 *
		 */
		[Inline]
		final protected function validatePositionX():void
		{
			emitterX = position.x;
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
			emitterY = _projectY(position.y, position.z);
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
				const textureSize:Number = 16;
				const blur:Number = 4;
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

		/** Helper objects. */
		private static var helperMatrix:Matrix = new Matrix();

		private static var helperPoint:Point = new Point();

		private static var renderAlpha:Vector.<Number> = new <Number>[ 1.0, 1.0,
																	   1.0, 1.0 ];

		private var initialCapacity:int;
	}
}
