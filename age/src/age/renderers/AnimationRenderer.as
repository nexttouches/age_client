package age.renderers
{
	import flash.errors.IllegalOperationError;
	import flash.media.Sound;
	import flash.system.Capabilities;
	import age.AGE;
	import age.assets.TextureAsset;
	import nt.assets.IAsset;
	import nt.assets.extensions.ProgressiveImageAsset;
	import org.osflash.signals.Signal;
	import starling.animation.IAnimatable;
	import starling.events.Event;
	import starling.textures.Texture;

	/**
	 * 动画渲染器，就是渲染一坨序列帧<br>
	 * 通过设置 asset，是一个可以反复使用同一个渲染器
	 * @author zhanghaocong
	 *
	 */
	[Deprecated(message="该类已被 AnimationLayerRenderer 代替")]
	public class AnimationRenderer extends TextureRenderer implements IAnimatable
	{
		/**
		 * 序列帧
		 */
		protected var textures:Vector.<Texture>;

		/**
		 * 声音
		 */
		protected var sounds:Vector.<Sound>;

		/**
		 * 每帧的长度（秒）
		 */
		protected var durations:Vector.<Number>;

		/**
		 * 每帧的开始事件（秒）
		 */
		protected var startTimes:Vector.<Number>;

		/**
		 * 计算出的（默认的）每帧长度
		 */
		protected var defaultFrameDuration:Number;

		protected var _totalTime:Number;

		/**
		 * 播放的当前时间
		 */
		protected var currentTime:Number;

		protected var _currentFrame:int;

		protected var _loop:Boolean;

		protected var _isPlaying:Boolean;

		public function AnimationRenderer()
		{
			super();
			AGE.s.juggler.add(this);
		}

		/**
		* @private
		*/
		override public function set asset(value:TextureAsset):void
		{
			attach(value);

			if (!_asset) // 使用空 Textures
			{
				init(emptyTextures, 1);
			}
		}

		override protected function setTexture(t:Texture):void
		{
			// 不做事情
		}

		override public function dispose():void
		{
			AGE.s.juggler.remove(this);
			asset = null;
			super.dispose();
		}

		protected function init(textures:Vector.<Texture>, fps:Number):void
		{
			if (!textures)
			{
				if (Capabilities.isDebugger)
				{
					throw new ArgumentError("参数 textures 不能为 null");
				}
				return;
			}
			texture = textures[0];

			if (fps <= 0)
				throw new ArgumentError("Invalid fps: " + fps);
			var numFrames:int = textures.length;
			defaultFrameDuration = 1.0 / fps;
			_loop = true;
			_isPlaying = true;
			currentTime = 0.0;
			_currentFrame = 0;
			_totalTime = defaultFrameDuration * numFrames;
			this.textures = textures;
			sounds = new Vector.<Sound>(numFrames);
			durations = new Vector.<Number>(numFrames);
			startTimes = new Vector.<Number>(numFrames);
			var i:int;

			for (i = 0; i < numFrames; ++i)
			{
				durations[i] = defaultFrameDuration;
				startTimes[i] = i * defaultFrameDuration;
			}
		}

		// frame manipulation
		/** Adds an additional frame, optionally with a sound and a custom duration. If the
		 *  duration is omitted, the default framerate is used (as specified in the constructor). */
		public function addFrame(texture:Texture, sound:Sound = null, duration:Number = -1):void
		{
			addFrameAt(numFrames, texture, sound, duration);
		}

		/** Adds a frame at a certain index, optionally with a sound and a custom duration. */
		public function addFrameAt(frameID:int, texture:Texture, sound:Sound = null, duration:Number = -1):void
		{
			if (frameID < 0 || frameID > numFrames)
				throw new ArgumentError("Invalid frame id");

			if (duration < 0)
				duration = defaultFrameDuration;
			textures.splice(frameID, 0, texture);
			sounds.splice(frameID, 0, sound);
			durations.splice(frameID, 0, duration);
			_totalTime += duration;

			if (frameID > 0 && frameID == numFrames)
				startTimes[frameID] = startTimes[frameID - 1] + durations[frameID - 1];
			else
				updateStartTimes();
		}

		/** Removes the frame at a certain ID. The successors will move down. */
		public function removeFrameAt(frameID:int):void
		{
			if (frameID < 0 || frameID >= numFrames)
				throw new ArgumentError("Invalid frame id");

			if (numFrames == 1)
				throw new IllegalOperationError("Movie clip must not be empty");
			_totalTime -= getFrameDuration(frameID);
			textures.splice(frameID, 1);
			sounds.splice(frameID, 1);
			durations.splice(frameID, 1);
			updateStartTimes();
		}

		/** Returns the texture of a certain frame. */
		public function getFrameTexture(frameID:int):Texture
		{
			if (frameID < 0 || frameID >= numFrames)
				throw new ArgumentError("Invalid frame id");
			return textures[frameID];
		}

		/** Sets the texture of a certain frame. */
		public function setFrameTexture(frameID:int, texture:Texture):void
		{
			if (frameID < 0 || frameID >= numFrames)
				throw new ArgumentError("Invalid frame id");
			textures[frameID] = texture;
		}

		/** Returns the sound of a certain frame. */
		public function getFrameSound(frameID:int):Sound
		{
			if (frameID < 0 || frameID >= numFrames)
				throw new ArgumentError("Invalid frame id");
			return sounds[frameID];
		}

		/** Sets the sound of a certain frame. The sound will be played whenever the frame
		 *  is displayed. */
		public function setFrameSound(frameID:int, sound:Sound):void
		{
			if (frameID < 0 || frameID >= numFrames)
				throw new ArgumentError("Invalid frame id");
			sounds[frameID] = sound;
		}

		/** Returns the duration of a certain frame (in seconds). */
		public function getFrameDuration(frameID:int):Number
		{
			if (frameID < 0 || frameID >= numFrames)
				throw new ArgumentError("Invalid frame id");
			return durations[frameID];
		}

		/** Sets the duration of a certain frame (in seconds). */
		public function setFrameDuration(frameID:int, duration:Number):void
		{
			if (frameID < 0 || frameID >= numFrames)
				throw new ArgumentError("Invalid frame id");
			_totalTime -= getFrameDuration(frameID);
			_totalTime += duration;
			durations[frameID] = duration;
			updateStartTimes();
		}

		// playback methods
		/** Starts playback. Beware that the clip has to be added to a juggler, too! */
		public function play():void
		{
			_isPlaying = true;
		}

		/** Pauses playback. */
		public function pause():void
		{
			_isPlaying = false;
		}

		/** Stops playback, resetting "currentFrame" to zero. */
		public function stop():void
		{
			_isPlaying = false;
			currentFrame = 0;
		}

		// helpers
		private function updateStartTimes():void
		{
			var numFrames:int = this.numFrames;
			startTimes.length = 0;
			startTimes[0] = 0;

			for (var i:int = 1; i < numFrames; ++i)
				startTimes[i] = startTimes[i - 1] + durations[i - 1];
		}

		// IAnimatable
		/** @inheritDoc */
		public function advanceTime(passedTime:Number):void
		{
			if (!_asset)
			{
				return;
			}
			var finalFrame:int;
			var previousFrame:int = _currentFrame;
			var restTime:Number = 0.0;
			var breakAfterFrame:Boolean = false;

			if (_loop && currentTime == _totalTime)
			{
				currentTime = 0.0;
				_currentFrame = 0;
			}

			if (_isPlaying && passedTime > 0.0 && currentTime < _totalTime)
			{
				currentTime += passedTime;
				finalFrame = textures.length - 1;

				while (currentTime >= startTimes[_currentFrame] + durations[_currentFrame])
				{
					if (_currentFrame == finalFrame)
					{
						if (_onLastFrame)
						{
							_onLastFrame.dispatch(this);
						}

						if (hasEventListener(Event.COMPLETE))
						{
							if (_currentFrame != previousFrame)
								texture = textures[_currentFrame];
							restTime = currentTime - _totalTime;
							currentTime = _totalTime;
							dispatchEventWith(Event.COMPLETE);
							breakAfterFrame = true;
						}

						if (_loop)
						{
							currentTime -= _totalTime;

							if (currentTime < 0)
							{
								currentTime = 0;
							}
							_currentFrame = 0;
						}
						else
						{
							currentTime = _totalTime;
							breakAfterFrame = true;
						}
					}
					else
					{
						_currentFrame++;
					}
					// 检查是否有音效需要播放
					var sound:Sound = sounds[_currentFrame];

					if (sound)
						sound.play();

					if (_onChangeFrame)
					{
						_onChangeFrame.dispatch(this);
					}

					if (breakAfterFrame)
						break;
				}
			}

			// 如果资源已加载完毕，就使用正确的资源，否则用空白贴图代替
			if (_asset.isComplete)
			{
				if (_currentFrame != previousFrame)
					texture = textures[_currentFrame];
			}
			else
			{
				texture = emptyTexture;
			}

			if (restTime)
				advanceTime(restTime);
		}

		/** Indicates if a (non-looping) movie has come to its end. */
		public function get isComplete():Boolean
		{
			return !_loop && currentTime >= _totalTime;
		}

		// properties  
		/** The total duration of the clip in seconds. */
		public function get totalTime():Number
		{
			return _totalTime;
		}

		/** The total number of frames. */
		public function get numFrames():int
		{
			return textures.length;
		}

		/** Indicates if the clip should loop. */
		public function get loop():Boolean
		{
			return _loop;
		}

		public function set loop(value:Boolean):void
		{
			_loop = value;
		}

		/** The index of the frame that is currently displayed. */
		public function get currentFrame():int
		{
			return _currentFrame;
		}

		public function set currentFrame(value:int):void
		{
			_currentFrame = value;
			currentTime = 0.0;

			for (var i:int = 0; i < value; ++i)
				currentTime += getFrameDuration(i);

			if (textures)
			{
				texture = textures[_currentFrame];
			}

			if (sounds)
			{
				if (sounds[_currentFrame])
					sounds[_currentFrame].play();
			}

			if (_onChangeFrame)
			{
				_onChangeFrame.dispatch(this);
			}
		}

		/** The default number of frames per second. Individual frames can have different
		 *  durations. If you change the fps, the durations of all frames will be scaled
		 *  relatively to the previous value. */
		public function get fps():Number
		{
			return 1.0 / defaultFrameDuration;
		}

		public function set fps(value:Number):void
		{
			if (value <= 0)
				throw new ArgumentError("Invalid fps: " + value);
			var newFrameDuration:Number = 1.0 / value;
			var acceleration:Number = newFrameDuration / defaultFrameDuration;
			currentTime *= acceleration;
			defaultFrameDuration = newFrameDuration;

			for (var i:int = 0; i < numFrames; ++i)
			{
				var duration:Number = durations[i] * acceleration;
				_totalTime = _totalTime - durations[i] + duration;
				durations[i] = duration;
			}
			updateStartTimes();
		}

		/** Indicates if the clip is still playing. Returns <code>false</code> when the end
		 *  is reached. */
		public function get isPlaying():Boolean
		{
			if (_isPlaying)
				return _loop || currentTime < _totalTime;
			else
				return false;
		}

		override public function onBitmapDataChange(asset:ProgressiveImageAsset):void
		{
			// 贴图会自动上传到 GPU，这里不用做任何处理
		}

		override public function onAssetDispose(asset:IAsset):void
		{
		}

		override public function onAssetLoadComplete(asset:IAsset):void
		{
			readjustSize();

			if (_onAttach)
			{
				_onAttach.dispatch(this);
			}
		}

		override public function onAssetLoadError(asset:IAsset):void
		{
		}

		override public function onAssetLoadProgress(asset:IAsset, bytesLoaded:uint, bytesTotal:uint):void
		{
		}

		private var _onLastFrame:Signal;

		public function get onLastFrame():Signal
		{
			return _onLastFrame ||= new Signal(AnimationRenderer);
		}

		private var _onChangeFrame:Signal;

		public function get onChangeFrame():Signal
		{
			return _onChangeFrame ||= new Signal(AnimationRenderer);
		}

		protected static var _emptyTextures:Vector.<Texture>;

		protected static function get emptyTextures():Vector.<Texture>
		{
			if (!_emptyTextures)
			{
				_emptyTextures = new <Texture>[ emptyTexture ];
			}
			return _emptyTextures;
		}
	}
}
