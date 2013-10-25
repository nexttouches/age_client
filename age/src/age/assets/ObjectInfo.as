package age.assets
{
	import flash.errors.IllegalOperationError;
	import flash.geom.Vector3D;
	import age.renderers.Direction;
	import nt.lib.reflect.Property;
	import nt.lib.reflect.Type;
	import nt.lib.util.Converter;
	import nt.lib.util.Vector3DUtil;
	import nt.lib.util.assert;
	import org.osflash.signals.Signal;

	/**
	 * ObjectInfo 是指地图上的装饰物，NPC，怪物<br>
	 * 只允许出现在 LayerInfo.type == LayerType.OBJECT 的图层上
	 * @author zhanghaocong
	 *
	 */
	public class ObjectInfo
	{
		/**
		 * 创建一个新的 ObjectInfo
		 *
		 */
		public function ObjectInfo(raw:Object = null, parent:LayerInfo = null)
		{
			this.parent = parent;
			fromJSON(raw);
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
		 * 位置<br>
		 * 位置发生变化时，将广播 onPositionChange<br>
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
		 * 质量，数值越大，掉落速度越快<br>
		 * 为 0 时，将不受重力控制
		 */
		[Native]
		[Export(exclude=80)]
		public var mass:Number = 80;

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

		private var _avatarID:String;

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
			}
		}

		/**
		 * 获得当前渲染的 AvatarInfo<br>
		 * 如果 avatarID 为 null，将返回 null
		 * @return
		 *
		 */
		public function get avatarInfo():AvatarInfo
		{
			if (_avatarID)
			{
				return AvatarInfo.get(_avatarID);
			}
			return null;
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

		private var _actionName:String = DEFAULT_ACTION_NAME;

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

				if (_onActionNameChange)
				{
					_onActionNameChange.dispatch();
				}
				validateNow();
			}
		}

		/**
		 * 获得 <strong>当前</strong> 渲染的 ActionInfo
		 * @return
		 *
		 */
		public function get actionInfo():ActionInfo
		{
			if (_avatarID || _actionName)
			{
				return avatarInfo.getAction(_actionName);
			}
			return null;
		}

		/**
		* 位于所在图层的唯一 name
		*/
		[Native]
		[Export]
		public var name:String;

		/**
		 * 位于所在场景的唯一 ID <br>
		 * 历史原因，现在只使用下面的 uniqueID
		 * @see #uniqueID
		 */
		[Native]
		[Export(exclude=null)]
		public var id:String;

		// 以下摘自 CopyItemConfig
		// 是自定义的附加字段
		// 根据不同的游戏，字段和字段的意思都可以不一样
		/**
		 * 所在区域
		 * @see RegionInfo#id
		 */
		[Extended]
		[Export]
		public var regionID:int;

		/**
		 * 唯一ID
		 */
		[Extended]
		[Export]
		public var uniqueID:int;

		/**
		 * 对象 ID
		 */
		[Extended]
		[Export]
		public var objectID:int;

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
		 * 子类型
		 */
		[Extended]
		[Export(exclude=0)]
		public var subtype:int = 0;

		/**
		 * 能级
		 */
		[Extended]
		[Export(exclude=0)]
		public var energyLevel:int = 0;

		/**
		 * 能力级别
		 */
		[Extended]
		[Export(exclude="-1")]
		public var level:int = -1;

		/**
		 * 成长属性ID
		 */
		[Extended]
		[Export(exclude="-1")]
		public var growID:int = -1;

		/**
		 * AI 节点 id
		 */
		[Extended]
		[Export(exclude="-1")]
		public var aiID:int = -1;

		/**
		 * 掉落包ID
		 */
		[Extended]
		[Export(exclude=0)]
		public var dropID:int = 0;

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
		 * 计算下一帧
		 */
		[Inline]
		final public function advanceTime(time:Number, g:Vector3D, friction:Number, airResistance:Number, lower:Vector3D, upper:Vector3D = null):void
		{
			// 基本重力加速度
			velocity.y -= g.y * time;

			// 由 mass 提供的下落力不能超过底边界
			if (position.y > 0)
			{
				if (position.y - mass * time >= 0)
				{
					velocity.y -= mass * time;
				}
				else
				{
					velocity.y -= position.y;
				}
			}
			// 应用加速度
			position.x += velocity.x * time;
			position.y += velocity.y * time;
			position.z += velocity.z * time;

			// 左边界
			if (position.x <= lower.x)
			{
				position.x = 0;
				velocity.x *= -elasticity;
			}

			// 下边界
			if (position.y <= lower.y)
			{
				position.y = 0;
				// 完全贴地后，计算地面摩擦力
				velocity.x *= friction;
				velocity.z *= friction;
				velocity.y *= -elasticity;
			}

			// 前边界
			if (position.z <= lower.z)
			{
				position.z = 0;
				velocity.z *= -elasticity;
			}
			// 空气阻力
			velocity.scaleBy(airResistance);

			// 静止判断
			if (Math.abs(velocity.y) <= STICKY_THRESHOLD)
			{
				velocity.y = 0;
			}

			if (Math.abs(velocity.x) <= STICKY_THRESHOLD)
			{
				velocity.x = 0;
			}

			if (Math.abs(velocity.z) <= STICKY_THRESHOLD)
			{
				velocity.z = 0;
			}
			// trace(velocity);
			isSticky = velocity.x == 0 && velocity.y == 0 && velocity.z == 0;

			// 如活动中则广播 onPositionChange
			// 请注意：ObjectRenderer 将每帧更新位置
			// 也就是说，该事件仅供渲染器以外使用
			if (!_isSticky)
			{
				if (_onPositionChange)
				{
					_onPositionChange.dispatch();
				}
			}
			// 执行更新 currentFrame 逻辑
			updateCurrentFrame(time);
		}

		/**
		 * 从 JSON 反序列化
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
		 * 默认的动作名称
		 */
		public static const DEFAULT_ACTION_NAME:String = "idle";

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
			// 任意为 null
			if (_avatarID == null || _actionName == null)
			{
				return;
			}

			// 错误的 avatarID
			if (!AvatarInfo.has(_avatarID))
			{
				traceex("[{0}] avatarID 不正确：{1}", Type.of(this).shortname, _avatarID);
				return;
			}
			const avatarInfo:AvatarInfo = AvatarInfo.get(_avatarID);

			// 错误的 actionName
			if (!avatarInfo.hasAction(_actionName))
			{
				traceex("[{0}] 在 {1} 中找不到动作：{2}", Type.of(this).shortname, _avatarID, _actionName);
				return;
			}
			// 取出动作信息
			const actionInfo:ActionInfo = avatarInfo.getAction(_actionName);
			updateDurations(actionInfo);

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

					// 声音是一定会播的
					// TODO 该操作应由渲染器完成
					// playSound(_currentFrame);
					if (breakAfterFrame)
					{
						break;
					}
				}

				// 特别情况：
				// 正好等于最后一帧
				if (currentFrame == finalFrame && currentTime == totalTime)
				{
					dispatchLastFrameEvent = hasLastFrameListener;
				}
			}

			if (dispatchLastFrameEvent)
			{
				_onLastFrame.dispatch();
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
		final protected function updateDurations(actionInfo:ActionInfo):void
		{
			// 初始化帧信息
			const numFrames:int = actionInfo.numFrames;
			defaultFrameDuration = actionInfo.defautFrameDuration;
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
		 * 释放资源
		 *
		 */
		public function dispose():void
		{
			if (_onCurrentFrameChange)
			{
				_onCurrentFrameChange.removeAll();
			}

			if (_onLastFrame)
			{
				_onLastFrame.removeAll();
			}
		}

		/**
		* 指示非循环动画是否已放完
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

				// TODO 通知渲染器需要立即更新贴图等
				// playRenderers(_currentFrame);
				// playSound(_currentFrame);
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
		 * 设置或获取 fps<br>
		 * 这将改变 defaultFrameDuration, durations, startTimes
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

		/** Removes the frame at a certain ID. The successors will move down. */
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

		private var _direction:int = Direction.RIGHT;

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
	}
}
