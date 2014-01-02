package age.data
{
	import flash.errors.IllegalOperationError;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import age.data.objectStates.AbstractObjectState;
	import age.data.objectStates.IdleState;
	import age.pad.Pad;
	import age.renderers.Direction;
	import nt.lib.reflect.Property;
	import nt.lib.reflect.Type;
	import nt.lib.util.Converter;
	import nt.lib.util.Vector3DUtil;
	import nt.lib.util.assert;
	import org.osflash.signals.Signal;
	import starling.animation.IAnimatable;

	/**
	 * ObjectInfo 是指地图上的装饰物，NPC，怪物<br>
	 * 只允许出现在 LayerInfo.type == LayerType.OBJECT 的图层上
	 * @author zhanghaocong
	 *
	 */
	public class ObjectInfo
	{
		/**
		 * 指示当前 ObjectInfo 的被击区域，可以用来处理碰撞
		 */
		public var hitBox:Box = new Box;

		/**
		 * 指示当前 ObjectInfo 的攻击区域，可以用来处理碰撞
		 */
		public var attackBox:Box = new Box;

		/**
		 * 创建一个新的 ObjectInfo
		 *
		 */
		public function ObjectInfo(raw:Object = null, parent:LayerInfo = null)
		{
			this.parent = parent;
			fromJSON(raw);
			state = createState(IdleState);
		}

		/**
		 * 标记是否计算 elasticity
		 */
		public var isElasticityEnabled:Boolean = false;

		/**
		 * 下一次切换动作时，是否显示鬼影。true 显示 false 不显示<br>
		 * 这里的鬼影是指切换动作时将保留上一动作的当前帧并淡出
		 */
		public var isShowGhost:Boolean;

		/**
		 * 该值总是储存 _state as IAnimatable 的值
		 */
		private var stateAnimatable:IAnimatable;

		private var _state:AbstractObjectState;

		/**
		 * 设置或获取当前对象的状态
		 */
		[Transient]
		[Inline]
		final public function get state():AbstractObjectState
		{
			return _state;
		}

		/**
		 * @private
		 */
		[Inline]
		final public function set state(value:AbstractObjectState):void
		{
			if ((!_state || _state.canSwitch(value)) || !value)
			{
				if (_state)
				{
					_state.cancel();
				}
				_state = value;
				stateAnimatable = _state as IAnimatable;

				if (_state)
				{
					_state.apply();
				}
			}
		}

		/**
		 * 当前 ObjectInfo 状态缓存
		 * @see createState
		 */
		private var stateCache:Dictionary = new Dictionary();

		/**
		 * 创建一个当前 ObjectInfo 专属的状态
		 * @param stateClass
		 * @return
		 *
		 */
		[Inline]
		final public function createState(stateClass:Class):AbstractObjectState
		{
			return stateCache[stateClass] ||= new stateClass(this);
		}

		protected var _onIsStickyChange:Signal;

		/**
		 * isSticky 变化时广播
		 * @return
		 *
		 */
		public function get onIsStickyChange():Signal
		{
			return _onIsStickyChange ||= new Signal();
		}

		protected var _isSticky:Boolean = false;

		/**
		 * 设置或获取当前对象是否已静止
		 */
		[Inline]
		[Native]
		[Export(exclude=false)]
		final public function get isSticky():Boolean
		{
			return _isSticky;
		}

		/**
		 * @private
		 */
		[Inline]
		final public function set isSticky(value:Boolean):void
		{
			if (_isSticky != value)
			{
				_isSticky = value;

				if (_onIsStickyChange)
				{
					_onIsStickyChange.dispatch();
				}
			}
		}

		protected var _onPositionChange:Signal;

		/**
		 * position 变化时广播<br>
		 * 渲染器应每帧更新坐标，并不需要侦听该事件
		 * @return
		 *
		 */
		public function get onPositionChange():Signal
		{
			return _onPositionChange ||= new Signal();
		}

		/**
		 * 设置或获取位置<br>
		 * 当位置发生变化时，将广播 onPositionChange<br>
		 * 请注意：直接修改该值将不会广播上述事件
		 */
		[Native]
		[Export]
		public var position:Vector3D = new Vector3D();

		/**
		 * 速率
		 */
		[Native]
		[Export]
		public var velocity:Vector3D = new Vector3D();

		/**
		 * acceleration
		 */
		[Native]
		[Export]
		public var acceleration:Vector3D = new Vector3D();

		/**
		 * 质量，数值越大，掉落速度越快<br>
		 * 为 0 时，将不受重力控制<br>
		 * 为了简化运算，这里的 mass 实际是重力加速度的倍率
		 */
		[Native]
		[Export(exclude=1)]
		public var mass:Number = 1;

		/**
		 * 弹性，一般用在落地后的反弹力上
		 */
		[Native]
		[Export(exclude=0.2)]
		public var elasticity:Number = 0.2;

		/**
		 * 设置或获取 x
		 */
		public function get x():Number
		{
			return position.x;
		}

		/**
		 * @private
		 */
		public function set x(value:Number):void
		{
			position.x = value;
			hitBox.x = value;
		}

		/**
		 * 设置或获取 y
		 */
		public function get y():Number
		{
			return position.y;
		}

		/**
		 * @private
		 */
		public function set y(value:Number):void
		{
			position.y = value;
			hitBox.y = value;
		}

		/**
		 * 设置或获取 z
		 */
		public function get z():Number
		{
			return position.z;
		}

		/**
		 * @private
		 */
		public function set z(value:Number):void
		{
			position.z = value;
			hitBox.z = value;
		}

		private var _onAvatarIDChange:Signal;

		/**
		 * avatarID 变化时广播
		 * @return
		 *
		 */
		public function get onAvatarIDChange():Signal
		{
			return _onAvatarIDChange ||= new Signal();
		}

		protected var _avatarID:String;

		/**
		 * 设置或获取 Avatar ID
		 */
		[Native]
		[Export]
		public function get avatarID():String
		{
			return _avatarID;
		}

		/**
		 * @private
		 */
		public function set avatarID(value:String):void
		{
			if (value != avatarID)
			{
				_avatarID = value;
				validateNow();

				if (_onAvatarIDChange)
				{
					_onAvatarIDChange.dispatch();
				}
				isShowGhost = false;
			}
		}

		private var _onActionNameChange:Signal;

		/**
		 * actionName 变化时广播
		 * @return
		 *
		 */
		public function get onActionNameChange():Signal
		{
			return _onActionNameChange ||= new Signal();
		}

		protected var _actionName:String;

		/**
		 * 设置或获取 actionName
		 * @return
		 *
		 */
		[Native]
		[Export]
		public function get actionName():String
		{
			return _actionName;
		}

		public function set actionName(value:String):void
		{
			if (_actionName != value)
			{
				_actionName = value;
				validateNow();

				if (_onActionNameChange)
				{
					_onActionNameChange.dispatch();
				}
				isShowGhost = false;
			}
		}

		/**
		* 位于所在图层的唯一 name
		*/
		[Native]
		[Export]
		public var name:String;

		/**
		 * 位于所在场景的 <strong>唯一 ID</strong><br>
		 */
		[Native]
		[Export(exclude=null)]
		public var id:String;

		/**
		 * 所在区域
		 * @see RegionInfo#id
		 */
		[Extended]
		[Export]
		public var regionID:int;

		/**
		 * 自定义数据
		 */
		[Extended]
		[Export]
		public var userData:String;

		/**
		 * 类型
		 * @see ObjectType
		 */
		[Extended]
		[Export(exclude="-1")]
		public var type:int = ObjectType.NONE;

		/**
		 * 所属图层
		 */
		public var parent:LayerInfo;

		/**
		 * 所属图层索引<br>
		 * 如不在任何图层中，返回 -1
		 * @return
		 *
		 */
		public function get layerIndex():int
		{
			if (!parent)
			{
				return -1;
			}
			return parent.index;
		}

		/**
		* 如果 avatarID 为空返回 null，否则返回当前渲染中的 AvatarInfo
		* @return
		*
		*/
		public function get avatarInfo():AvatarInfo
		{
			return avatarID ? AvatarInfo.get(avatarID) : null;
		}

		/**
		 * 如果 avatarInfo 或 actionName 为空返回 null，否则返回当前渲染中的 ActionInfo
		 * @return
		 *
		 */
		public function get actionInfo():ActionInfo
		{
			return !actionName || !avatarInfo ? null : avatarInfo.getAction(actionName);
		}

		/**
		 * 计算下一帧
		 */
		[Inline]
		final public function advanceTime(time:Number):void
		{
			// 检查状态是否也需要 advanceTime
			if (stateAnimatable)
			{
				stateAnimatable.advanceTime(time);
			}
			// 计算速度和位置
			velocity.x += acceleration.x * time;
			velocity.y += acceleration.y * time;
			velocity.z += acceleration.z * time;
			position.x += velocity.x * time;
			position.y += velocity.y * time;
			position.z += velocity.z * time;
			// 执行更新 currentFrame 逻辑
			updateCurrentFrame(time);
			// 执行更新 hitBox 和 attackBox
			updateBoxes();
		}

		/**
		 * @private
		 *
		 */
		private function updateBoxes():void
		{
			const ai:ActionInfo = actionInfo;

			if (!ai)
			{
				return;
			}
			var frameInfo:FrameInfo;
			var frameLayerInfo:FrameLayerInfo;
			var box:Box;
			// 更新 hitBox
			frameLayerInfo = ai.hitBoxLayer;

			if (frameLayerInfo && frameLayerInfo.numFrames > _currentFrame)
			{
				box = frameLayerInfo.frames[_currentFrame].keyframe.box;

				if (box)
				{
					hitBox.fromBox(box);
				}
				else
				{
					hitBox.width = 0;
					hitBox.height = 0;
					hitBox.depth = 0;
				}
			}
			else
			{
				hitBox.width = 0;
				hitBox.height = 0;
				hitBox.depth = 0;
			}
			hitBox.setPosition(position);
			frameLayerInfo = ai.attackBoxLayer;

			if (frameLayerInfo && frameLayerInfo.numFrames > _currentFrame)
			{
				box = frameLayerInfo.frames[_currentFrame].keyframe.box;

				if (box)
				{
					attackBox.fromBox(box);
				}
				else
				{
					attackBox.width = 0;
					attackBox.height = 0;
					attackBox.depth = 0;
				}
			}
			else
			{
				attackBox.width = 0;
				attackBox.height = 0;
				attackBox.depth = 0;
			}
			attackBox.direction = _direction;
			attackBox.setPosition(position);
		}

		/**
		 * 从 JSON 导入数据
		 * @param raw
		 *
		 */
		public function fromJSON(s:*):void
		{
			if (s)
			{
				const properties:Object = Type.of(this).writableProperties;

				for each (var p:Property in properties)
				{
					// 固有属性
					if (p.hasMetadata(EXPORT))
					{
						if (p.type == Vector3D)
						{
							if (s[p.name])
							{
								this[p.name] = Vector3DUtil.fromArray(s[p.name]);
							}
						}
						else
						{
							restore(s, this, p.name);
						}
					}
				}

				// 向前兼容：
				// 如果没有 position，转化到笛卡尔坐标系
				// 0.5 是个魔数，用于快速计算
				// 实际我们期望的角度是 60°
				if (!s.position)
				{
					position.setTo(s.x, 0, parent.parent.height - s.y * .5);
				}
				velocity.x = 160;
				velocity.y = 400;
				velocity.z = 160;
				mass = 4;
			}
		}

		public function toJSON(k:*):*
		{
			var result:Object = {};
			const properties:Object = Type.of(this).writableProperties;

			for each (var p:Property in properties)
			{
				// 固有属性
				if (p.hasMetadata(EXPORT))
				{
					if (p.type == Vector3D)
					{
						result[p.name] = Vector3DUtil.toArray(this[p.name]);
					}
					else
					{
						export(this, result, p.name, Converter.intelligenceConvert(p.getMetadata(EXPORT).getArg(EXCLUDE)));
					}
				}
			}
			return result;
		}

		/**
		 * 用于标记扩展属性的 metadata 名字
		 */
		public static const EXTENDED:String = "Extended";

		/**
		 * 用于标记固有属性的 metadata 名字
		 */
		public static const NATIVE:String = "Native";

		/**
		 * 用于标记需要导出属性的 metadata 名字
		 */
		public static const EXPORT:String = "Export";

		/**
		 * 要排除的字段的名字
		 */
		public static const EXCLUDE:String = "exclude";

		/**
		 * 速度小于等于该值时，视为静止
		 */
		public static const STICKY_THRESHOLD:Number = 1;

		// -----------------------------
		// 下为播放逻辑
		// 代码复制自 AvatarRenderer
		// -----------------------------
		/**
		 * 设置或获取更改动作后，是否自动播放<br>
		 * 默认 true
		 */
		public var isAutoPlay:Boolean = true;

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

		/**
		 * 播放的当前时间
		 */
		protected var currentTime:Number;

		/**
		* 根据 avatarID 和 actionName 刷新动画
		*
		*/
		public function validateNow():void
		{
			updateDurations();

			if (isAutoPlay)
			{
				play();
			}
			else
			{
				stop();
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function updateCurrentFrame(passedTime:Number):void
		{
			if (!_isPlaying || passedTime <= 0.0)
			{
				return;
			}
			var finalFrame:int;
			var previousFrame:int = _currentFrame;
			var restTime:Number = 0.0;
			var breakAfterFrame:Boolean = false;
			var hasLastFrameListener:Boolean = _onLastFrame && _onLastFrame.numListeners > 0;
			var dispatchLastFrameEvent:Boolean = false;

			if (_isLoop && currentTime == _totalTime)
			{
				currentTime = 0.0;
				_currentFrame = 0;
			}

			if (currentTime < _totalTime)
			{
				currentTime += passedTime;
				finalFrame = durations.length - 1;

				while (currentTime >= startTimes[_currentFrame] + durations[_currentFrame])
				{
					if (_currentFrame == finalFrame)
					{
						if (_isLoop && !hasLastFrameListener)
						{
							currentTime -= totalTime;
							_currentFrame = 0;
						}
						else
						{
							breakAfterFrame = true;
							restTime = currentTime - totalTime;
							dispatchLastFrameEvent = hasLastFrameListener;
							currentFrame = finalFrame;
							currentTime = totalTime;
						}
					}
					else
					{
						_currentFrame++;
					}

					if (_onCurrentFrameChange)
					{
						_onCurrentFrameChange.dispatch(this);
					}

					if (breakAfterFrame)
					{
						break;
					}
				}

				// 特别情况：正好等于最后一帧。可以广播 onLastFrame
				if (currentFrame == finalFrame && currentTime == totalTime)
				{
					dispatchLastFrameEvent = hasLastFrameListener;
				}
			}

			if (dispatchLastFrameEvent)
			{
				_onLastFrame.dispatch(this);
			}

			if (_isLoop && restTime > 0.0)
			{
				updateCurrentFrame(restTime);
			}
		}

		/**
		* 更新帧信息
		* @param actionInfo
		*
		*/
		[Inline]
		final protected function updateDurations():void
		{
			const ai:ActionInfo = actionInfo;
			const numFrames:int = ai ? ai.numFrames : null;
			defaultFrameDuration = ai ? ai.defautFrameDuration : 0;
			_isLoop = true;
			currentTime = 0.0;
			_currentFrame = 0;
			_totalTime = defaultFrameDuration * numFrames;
			durations = new Vector.<Number>(numFrames);
			startTimes = new Vector.<Number>(numFrames);
			var i:int;

			for (i = 0; i < numFrames; ++i)
			{
				durations[i] = defaultFrameDuration;
				startTimes[i] = i * defaultFrameDuration;
			}

			if (_onCurrentFrameChange)
			{
				_onCurrentFrameChange.dispatch(this);
			}
		}

		/**
		* 播放
		*
		*/
		public function play():void
		{
			_isPlaying = true;
		}

		/**
		 * 暂停
		 *
		 */
		public function pause():void
		{
			_isPlaying = false;
		}

		/**
		 * 停止播放，并把 currentFrame 为 0
		 *
		 */
		public function stop():void
		{
			_isPlaying = false;
			currentFrame = 0;
		}

		protected var _isPlaying:Boolean;

		/**
		 * 是否播放中
		 * @return
		 *
		 */
		public function get isPlaying():Boolean
		{
			if (_isPlaying)
			{
				return _isLoop || currentTime < _totalTime;
			}
			else
			{
				return false;
			}
		}

		private var _onLastFrame:Signal;

		/**
		 * 播放到最后一帧时广播
		 * @return
		 *
		 */
		public function get onLastFrame():Signal
		{
			return _onLastFrame ||= new Signal(ObjectInfo);
		}

		private var _onCurrentFrameChange:Signal;

		/**
		 * currentFrame 变化时广播
		 * @return
		 *
		 */
		public function get onCurrentFrameChange():Signal
		{
			return _onCurrentFrameChange ||= new Signal(ObjectInfo);
		}

		/**
		* 指示非循环动画是否已播放完毕。如果 <tt>isLoop</tt> 为 true，总是返回 false
		* @return
		*
		*/
		final public function get isComplete():Boolean
		{
			return !_isLoop && currentTime >= _totalTime;
		}

		protected var _totalTime:Number;

		/**
		 * 总长度（秒）
		 * @return
		 *
		 */
		[Inline]
		final public function get totalTime():Number
		{
			return _totalTime;
		}

		/**
		 * 总帧数
		 * @return
		 *
		 */
		[Inline]
		final public function get numFrames():int
		{
			return durations.length;
		}

		private var _onIsLoopChange:Signal;

		/**
		 * isLoop 变化时广播
		 * @return
		 *
		 */
		public function get onIsLoopChange():Signal
		{
			return _onIsLoopChange ||= new Signal();
		}

		protected var _isLoop:Boolean;

		/**
		 * 设置或获取是否循环播放
		 * @return
		 *
		 */
		public function get isLoop():Boolean
		{
			return _isLoop;
		}

		public function set isLoop(value:Boolean):void
		{
			if (value != isLoop)
			{
				_isLoop = value;

				if (_onIsLoopChange)
				{
					_onIsLoopChange.dispatch();
				}
			}
		}

		protected var _currentFrame:int;

		/**
		 * 设置或获取当前帧<br>
		 * 贴图和声音将即时改变<br>
		 * 与原生 MovieClip 不同，这里的帧从 0 开始索引<br>
		 * 设置的新帧和旧帧一样则不会有任何效果<br>
		 * currentFrame 变化后，将广播 <code>onCurrentFrameChange</code>
		 * @return
		 *
		 */
		public function get currentFrame():int
		{
			return _currentFrame;
		}

		public function set currentFrame(value:int):void
		{
			if (value != _currentFrame)
			{
				_currentFrame = value;
				currentTime = 0.0;

				for (var i:int = 0; i < value; ++i)
				{
					currentTime += getFrameDuration(i);
				}

				if (_onCurrentFrameChange)
				{
					_onCurrentFrameChange.dispatch(this);
				}
			}
		}

		/**
		 * 暂停并播放下一帧<br>
		 * 如果已经到最后一帧，将不会有有效果
		 *
		 */
		final public function nextFrame():void
		{
			if (currentFrame < numFrames - 1)
			{
				pause();
				currentFrame++;
			}
		}

		/**
		 * 暂停并播放上一帧<br>
		 * 如果已经在第一帧，将不会有有效果
		 *
		 */
		final public function prevFrame():void
		{
			if (currentFrame >= 1)
			{
				pause();
				currentFrame--;
			}
		}

		/**
		 * 设置或获取 fps。修改该值将同时修改 defaultFrameDuration, durations, startTimes
		 * @return
		 *
		 */
		public function get fps():Number
		{
			return 1.0 / defaultFrameDuration;
		}

		public function set fps(value:Number):void
		{
			assert(value > 0, "fps 必须大于 0");
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

		/**
		 * 添加一帧
		 * @param duration
		 *
		 */
		public function addFrame(duration:Number = -1):void
		{
			addFrameAt(numFrames, duration);
		}

		/**
		 * 添加帧到指定位置
		 * @param frameID
		 * @param duration
		 *
		 */
		public function addFrameAt(frameID:int, duration:Number = -1):void
		{
			if (frameID < 0 || frameID > numFrames)
			{
				throw new ArgumentError("frame id 不正确");
			}

			if (duration < 0)
			{
				duration = defaultFrameDuration;
			}
			// TODO 删除帧时，可能有其他需要处理的对象
			durations.splice(frameID, 0, duration);
			_totalTime += duration;

			if (frameID > 0 && frameID == numFrames)
			{
				startTimes[frameID] = startTimes[frameID - 1] + durations[frameID - 1];
			}
			else
			{
				updateStartTimes();
			}
		}

		/**
		 * 删除指定帧
		 * @param frameID
		 *
		 */
		public function removeFrameAt(frameID:int):void
		{
			if (frameID < 0 || frameID >= numFrames)
			{
				throw new ArgumentError("frame id 不正确");
			}

			if (numFrames == 1)
			{
				throw new IllegalOperationError("动画至少要有一帧");
			}
			_totalTime -= getFrameDuration(frameID);
			// TODO 删除帧时，可能有其他需要处理的对象
			durations.splice(frameID, 1);
			updateStartTimes();
		}

		/**
		 * 获得指定帧长度
		 * @param frameID
		 * @return
		 *
		 */
		public function getFrameDuration(frameID:int):Number
		{
			if (frameID < 0 || frameID >= numFrames)
				throw new ArgumentError("Invalid frame id");
			return durations[frameID];
		}

		/**
		 * 设置帧长度
		 * @param frameID 索引
		 * @param duration 长度（秒）
		 *
		 */
		public function setFrameDuration(frameID:int, duration:Number):void
		{
			if (frameID < 0 || frameID >= numFrames)
				throw new ArgumentError("Invalid frame id");
			_totalTime -= getFrameDuration(frameID);
			_totalTime += duration;
			durations[frameID] = duration;
			updateStartTimes();
		}

		/**
		 * gotoAndStop
		 * @param frame
		 *
		 */
		public function gotoAndStop(frame:int):void
		{
			pause();
			currentFrame = frame;
		}

		/**
		 * gotoAndPlay
		 * @param frame
		 *
		 */
		public function gotoAndPlay(frame:int):void
		{
			currentFrame = frame;
			play();
		}

		/**
		 * 更新 startTimes
		 *
		 */
		private function updateStartTimes():void
		{
			var numFrames:int = this.numFrames;
			startTimes.length = 0;
			startTimes[0] = 0;

			for (var i:int = 1; i < numFrames; ++i)
			{
				startTimes[i] = startTimes[i - 1] + durations[i - 1];
			}
		}

		private var _onDirectionChange:Signal;

		/**
		 * direction 变化时广播
		 * @return
		 *
		 */
		public function get onDirectionChange():Signal
		{
			return _onDirectionChange ||= new Signal();
		}

		protected var _direction:int = Direction.RIGHT;

		/**
		 * 设置或获取方向
		 * @see Direction#LEFT
		 * @see Direction#RIGHT
		 * @return
		 *
		 */
		[Native]
		[Export(exclude=0)]
		public function get direction():int
		{
			return _direction;
		}

		public function set direction(value:int):void
		{
			if (_direction != value)
			{
				_direction = value;

				if (_onDirectionChange)
				{
					_onDirectionChange.dispatch();
				}
			}
		}

		private var _onScaleChange:Signal;

		/**
		 * scale 变化时广播
		 * @return
		 *
		 */
		public function get onScaleChange():Signal
		{
			return _onScaleChange ||= new Signal();;
		}

		private var _scale:Number = 1;

		/**
		 * 设置或获取 scale，默认值 1
		 * @return
		 *
		 */
		[Native]
		[Export(exclude=1)]
		public function get scale():Number
		{
			return _scale;
		}

		public function set scale(value:Number):void
		{
			if (value != _scale)
			{
				_scale = value;

				if (_onScaleChange)
				{
					_onScaleChange.dispatch();
				}
			}
		}

		private var _onAlphaChange:Signal;

		/**
		 * alpha 变化时广播
		 * @return
		 *
		 */
		public function get onAlphaChange():Signal
		{
			return _onAlphaChange ||= new Signal();
		}

		private var _alpha:Number = 1;

		/**
		 * 设置或获取 alpha，默认值 1
		 */
		[Native]
		[Export(exclude=1)]
		public function get alpha():Number
		{
			return _alpha;
		}

		/**
		 * @private
		 */
		public function set alpha(value:Number):void
		{
			if (value != _alpha)
			{
				_alpha = value;

				if (_onAlphaChange)
				{
					_onAlphaChange.dispatch();
				}
			}
		}

		private var _onColorChange:Signal;

		/**
		 * color 变化时广播
		 * @return
		 *
		 */
		public function get onColorChange():Signal
		{
			return _onColorChange ||= new Signal();
		}

		public static const RESET_COLOR:uint = 0;

		private var _color:uint = RESET_COLOR;

		/**
		 * 设置或获取 color
		 */
		[Native]
		[Export(exclude=0)]
		public function get color():uint
		{
			return _color;
		}

		/**
		 * @private
		 */
		public function set color(value:uint):void
		{
			if (value != _color)
			{
				_color = value;

				if (_onColorChange)
				{
					_onColorChange.dispatch();
				}
			}
		}

		private var _pad:Pad;

		/**
		 * 设置或获取当前对象使用的 Pad
		 */
		public function get pad():Pad
		{
			return _pad;
		}

		/**
		 * @private
		 */
		public function set pad(value:Pad):void
		{
			if (_pad)
			{
				_pad.removeObject(this);
			}
			_pad = value;

			if (_pad)
			{
				_pad.addObject(this);
			}
		}
	}
}
