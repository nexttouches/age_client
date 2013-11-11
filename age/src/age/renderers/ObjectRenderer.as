package age.renderers
{
	import flash.geom.Vector3D;
	import age.AGE;
	import age.data.ActionInfo;
	import age.data.AvatarInfo;
	import age.data.FrameLayerInfo;
	import age.data.FrameLayerType;
	import age.data.ObjectInfo;
	import nt.lib.util.IDisposable;
	import nt.lib.util.assert;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import starling.animation.IAnimatable;
	import starling.display.DisplayObject;
	import starling.filters.BlurFilter;
	import starling.filters.FragmentFilter;

	/**
	 * ObjectRenderer 是 ObjectInfo 的渲染器<br>
	 * 内部使用了多种类型的渲染器
	 * @author zhanghaocong
	 *
	 */
	public class ObjectRenderer implements IDirectionRenderer, IDisposable, IAnimatable, ITouchable
	{
		/**
		 * 当前渲染中的 avatarID
		 */
		protected var avatarID:String;

		/**
		 * 当前渲染中的 actionName
		 */
		protected var actionName:String;

		/**
		 * 设置或获取更改动作后，是否自动播放<br>
		 * 默认 true
		 */
		public var isAutoPlay:Boolean = true;

		/**
		 * zsort 时使用的唯一索引，用于避免闪烁
		 */
		public var uniqueIndex:int;

		/**
		 * 标记当前内置渲染器的数目
		 */
		protected var numNativeRenderers:int;

		/**
		 * constructor
		 *
		 */
		public function ObjectRenderer()
		{
			super();
			setupNativeRenderers();
			uniqueIndex = ZIndexHelper.getUniqueZIndex();
		}

		/**
		 * 初始化几个固定图层<br>
		 * 子类可以继承，以便创建更多固定图层
		 *
		 */
		protected function setupNativeRenderers():void
		{
			// 阴影
			shadowRenderer = new ShadowRenderer();
			addRenderer(shadowRenderer);
			// 名字
			nameRenderer = new nameRendererClass();
			addRenderer(nameRenderer);
			// 鼠标
			mouseResponder = new MouseResponder(this);
			addRenderer(mouseResponder);
			// 固定图层数为 3
			numNativeRenderers = 3;
		}

		/**
		 * 获得当前 ObjectRenderer 代表的 displayObject，用于计算鼠标之类的逻辑<br>
		 * 如有需求，子类可以覆盖该方法，以实现自己的位置判断
		 * 默认返回 mouseRespoder
		 * @see #mouseResponder
		 */
		[Inline]
		public function get displayObject():DisplayObject
		{
			return mouseResponder;
		}

		/**
		 * 用于创建 NameRenderer 具体的类
		 * @return
		 *
		 */
		protected function get nameRendererClass():Class
		{
			return NameRenderer;
		}

		/**
		 * 鼠标响应区域，具有下列固定属性<br>
		 * <ul>
		 * <li>固有图层</li>
		 * <li>置于 nameRenderer 下方</li>
		 * <li>alpha = 0（默认）</li>
		 * <li>通过设置 <code>touchable</code> 禁用/启用鼠标</li>
		 * </ul>
		 */
		protected var mouseResponder:MouseResponder;

		/**
		 * 名字渲染器
		 * <ul>
		 * <li>固有图层</li>
		 * <li>置顶</li>
		 * </ul>
		 */
		protected var nameRenderer:NameRenderer;

		/**
		 * 影子渲染器
		 * <ul>
		 * <li>固有图层</li>
		 * <li>置底</li>
		 * </ul>
		 */
		protected var shadowRenderer:ShadowRenderer;

		/**
		 * 所有子渲染器
		 */
		public var renderers:Vector.<IDisplayObject3D> = new Vector.<IDisplayObject3D>();

		/**
		 * 所有线框渲染器
		 */
		public var wireframes:Vector.<WireframeLayerRenderer> = new Vector.<WireframeLayerRenderer>;

		/**
		 * 所有动画渲染器
		 */
		public var animations:Vector.<AnimationLayerRenderer> = new Vector.<AnimationLayerRenderer>;

		/**
		 * 所有音乐播放器
		 */
		public var sounds:Vector.<SoundLayerRenderer> = new Vector.<SoundLayerRenderer>;

		/**
		 * 所有粒子渲染器
		 */
		public var particles:Vector.<ParticlesLayerRenderer> = new Vector.<ParticlesLayerRenderer>;

		/**
		 * 添加一个子渲染器
		 * @param r
		 *
		 */
		public function addRenderer(r:IDisplayObject3D):void
		{
			// 添加到数组
			renderers.push(r);
			// 立即同步一些属性
			r.setPosition(_x, _y, _z);
			r.scale = _scale;

			// TODO 需要同步更多属性
			//
			//
			// 立即添加到父级
			if (_parent)
			{
				if (r is DisplayObject)
				{
					_parent.addChild(r as DisplayObject)
				}
				// TODO 把 WireframeLayerRenderer 抽出来
				else if (r is WireframeLayerRenderer)
				{
					WireframeLayerRenderer(r).parent = parent;
				}
			}
		}

		protected var _info:ObjectInfo;

		/**
		 * 设置或获取当前渲染的 info
		 * @return
		 *
		 */
		public function get info():ObjectInfo
		{
			return _info;
		}

		public function set info(value:ObjectInfo):void
		{
			if (_info)
			{
				_info.onDirectionChange.remove(onDirectionChange);
				_info.onScaleChange.remove(onScaleChange);
				_info.onAlphaChange.remove(onAlphaChange);
				_info.onColorChange.remove(onColorChange);
				_info.onIsStickyChange.remove(onIsStickyChange);
				_info.onAvatarIDChange.remove(onAvatarIDChange);
				_info.onActionNameChange.remove(validateNow);
				_info.onCurrentFrameChange.remove(onCurrentFrameChange);
			}
			_info = value;

			if (_info)
			{
				_info.onDirectionChange.add(onDirectionChange);
				_info.onScaleChange.add(onScaleChange);
				_info.onAlphaChange.add(onAlphaChange);
				_info.onColorChange.add(onColorChange);
				_info.onIsStickyChange.add(onIsStickyChange);
				_info.onAvatarIDChange.add(onAvatarIDChange);
				_info.onActionNameChange.add(validateNow);
				_info.onCurrentFrameChange.add(onCurrentFrameChange);
			}
			onAvatarIDChange();

			// 立即更新
			if (_info)
			{
				advanceTime(0);
			}
		}

		/**
		 * 当前帧变化时广播
		 * @param target
		 *
		 */
		private function onCurrentFrameChange(target:ObjectInfo):void
		{
			playSound(_info.currentFrame);
		}

		/**
		 * 标记当前 info 是否刚刚静止
		 */
		private var isJustSticky:Boolean;

		/**
		 * 标记当前渲染器是否已静止
		 */
		private var isSticky:Boolean;

		/**
		 * @private
		 *
		 */
		protected function onIsStickyChange():void
		{
			isJustSticky = info.isSticky;
			isSticky = false;
		}

		/**
		 * @private
		 *
		 */
		protected function onAvatarIDChange():void
		{
			isAvatarIDChange = true;
			validateNow();
		}

		/**
		 * 根据 avatarID 和 actionName 刷新动画
		 *
		 */
		public function validateNow():void
		{
			// 清理工作
			if (actionInfo)
			{
				// 删除所有旧图层
				removeAllLayerRenderers();
				avatarID = null;
				actionName = null;
			}

			// 检查是否需要刷新静态渲染器
			if (isAvatarIDChange)
			{
				updateStaticRenderers(null);
			}

			// info 为 null 则放弃本次刷新
			if (!_info)
			{
				return;
			}
			// 更新 avatarID
			avatarID = info.avatarID;

			// 如 isAvatarIDChange 则…
			if (isAvatarIDChange)
			{
				updateStaticRenderers(avatarInfo);
				isAvatarIDChange = false;
			}

			if (avatarID)
			{
				// 更新 action
				actionName = info.actionName;
				addAllLayerRenderers(actionInfo);
			}

			if (isAutoPlay)
			{
				play();
			}
			else
			{
				pause();
			}
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
		 * 刷新静态渲染器
		 * @param avatarInfo 要刷新的 avatarInfo，可以输入 null 以便清空静态渲染器
		 *
		 */
		[Inline]
		private function updateStaticRenderers(avatarInfo:AvatarInfo):void
		{
			// 鼠标（主要是大小）
			mouseResponder.info = avatarInfo;
			// 名字
			nameRenderer.info = avatarInfo;
			// 影子暂时算静态渲染器
			shadowRenderer.info = avatarInfo;
		}

		/**
		 * 添加所有渲染图层
		 * @param actionInfo
		 *
		 */
		[Inline]
		final protected function addAllLayerRenderers(actionInfo:ActionInfo):void
		{
			// 没有任何动作就撤退
			if (!actionInfo)
			{
				return;
			}
			const layers:Vector.<FrameLayerInfo> = actionInfo.layers;

			for (var i:int = 0, n:int = layers.length; i < n; i++)
			{
				const info:FrameLayerInfo = layers[i];

				if (info.type == FrameLayerType.ANIMATION)
				{
					// TODO 从对象池取出
					var alr:AnimationLayerRenderer = new animationLayerRendererClass();
					alr.info = info;
					animations.push(alr);
					addRenderer(alr);
				}
				else if (info.type == FrameLayerType.SOUND)
				{
					// TODO 从对象池取出
					var slr:SoundLayerRenderer = new soundLayerRendererClass();
					slr.info = info;
					sounds.push(slr);
				}
				else if (info.type == FrameLayerType.PARTICLE)
				{
					throw new Error("尚未实现");
						// var r:ParticlesLayerRenderer = new ParticlesLayerRenderer();
						// XXX 实现粒子图层
						// XXX 从对象池取出
				}
				else if (info.type == FrameLayerType.VIRTUAL)
				{
					var wlr:WireframeLayerRenderer = new wireframeLayerRendererClass();
					wlr.info = info;
					addWireframe(wlr);
				}
			}
			validateDirection();
			validateColor();
			validateAlpha();
			validateScale();
		}

		/**
		 * 添加一个 wireframe
		 * @param wlr
		 *
		 */
		protected function addWireframe(wlr:WireframeLayerRenderer):void
		{
			wireframes.push(wlr);
			addRenderer(wlr);
			wlr.parent = _parent;
		}

		/**
		 * 删除所有子渲染器
		 *
		 */
		private function removeAllLayerRenderers():void
		{
			var i:int, n:int;

			for (i = 0, n = animations.length; i < n; i++)
			{
				animations[i].removeFromParent(true);
					// TOOD 放回对象池
			}
			animations.length = 0;

			for (i = 0, n = particles.length; i < n; i++)
			{
				particles[i].removeFromParent(true);
					// TOOD 放回对象池
			}
			particles.length = 0;

			for (i = 0, n = sounds.length; i < n; i++)
			{
				sounds[i].dispose();
					// TOOD 放回对象池
			}
			sounds.length = 0;

			for (i = 0, n = wireframes.length; i < n; i++)
			{
				wireframes[i].dispose();
					// TOOD 放回对象池
			}
			wireframes.length = 0;
			// 只保留固定渲染器
			renderers.length = numNativeRenderers;
		}

		private var _parent:LayerRenderer;

		/**
		 * 设置或获取绘制用容器
		 */
		public function get parent():LayerRenderer
		{
			return _parent;
		}

		/**
		 * @private
		 */
		public function set parent(value:LayerRenderer):void
		{
			if (_parent != value)
			{
				var i:int;

				if (_parent)
				{
					for (i = 0; i < renderers.length; i++)
					{
						if (renderers[i] is DisplayObject)
						{
							_parent.removeChild(renderers[i] as DisplayObject);
						}
						else if (renderers[i] is WireframeLayerRenderer)
						{
							WireframeLayerRenderer(renderers[i]).parent = null;
						}
					}
					// 从 renderJuggler 删除
					AGE.renderJuggler.remove(this);
				}
				_parent = value;

				if (_parent)
				{
					// 添加到 renderJuggler
					AGE.renderJuggler.add(this);

					for (i = 0; i < renderers.length; i++)
					{
						if (renderers[i] is DisplayObject)
						{
							_parent.addChild(renderers[i] as DisplayObject);
						}
						else if (renderers[i] is WireframeLayerRenderer)
						{
							WireframeLayerRenderer(renderers[i]).parent = _parent;
						}
					}
				}
			}
		}

		private var _onDispose:Signal;

		public function get onDispose():ISignal
		{
			return _onDispose ||= new Signal(ObjectRenderer);
		}

		/**
		 * 删除一个子渲染器
		 * @param r
		 *
		 */
		public function removeRenderer(r:TextureRenderer):void
		{
			renderers.splice(renderers.indexOf(r), 1);
			r.removeFromParent(true);
		}

		/**
		 * @private
		 */
		protected function onDirectionChange():void
		{
			direction = _info.direction;
		}

		/**
		 * @private
		 */
		protected function onScaleChange():void
		{
			validateScale();
		}

		/**
		 * @private
		 */
		protected function onAlphaChange():void
		{
			validateAlpha();
		}

		/**
		 * @private
		 */
		protected function onColorChange():void
		{
			color = _info.color;
		}

		private var _x:Number = 0;

		/**
		 * 设置或获取 x
		 * @return
		 *
		 */
		public final function get x():Number
		{
			return _x;
		}

		public function set x(value:Number):void
		{
			if (_x != value)
			{
				_x = value;

				for (var i:int = 0, n:int = renderers.length; i < n; i++)
				{
					renderers[i].setX(_x);
				}
			}
		}

		private var _y:Number = 0;

		public final function get y():Number
		{
			return _y;
		}

		/**
		 * 设置或获取 y
		 * @param value
		 *
		 */
		public function set y(value:Number):void
		{
			if (_y != value)
			{
				_y = value;

				for (var i:int = 0, n:int = renderers.length; i < n; i++)
				{
					renderers[i].setY(_y);
				}
			}
		}

		private var _z:Number = 0;

		/**
		 * 设置或获取 z
		 * @return
		 *
		 */
		public function get z():Number
		{
			return _z;
		}

		public function set z(value:Number):void
		{
			if (_z != value)
			{
				_z = value;

				for (var i:int = 0, n:int = renderers.length; i < n; i++)
				{
					renderers[i].setZ(_z);
				}
			}
		}

		private var _scale:Number = 1;

		/**
		 * 设置或获取 scale，默认值 1
		 * @return
		 *
		 */
		public function get scale():Number
		{
			return _scale;
		}

		public function set scale(value:Number):void
		{
			if (value != _scale)
			{
				_scale = value;
				validateScale();
			}
		}

		/**
		 * 结合 info.scale 计算新 scale
		 *
		 */
		protected function validateScale():void
		{
			const resultScale:Number = _scale * (_info ? _info.scale : 1);

			for (var i:int = 0, n:int = renderers.length; i < n; i++)
			{
				renderers[i].scale = resultScale;
			}
		}

		/**
		 * 获取实际用于创建 ActionRenderer 的类
		 * @return
		 *
		 */
		protected function get animationLayerRendererClass():Class
		{
			return AnimationLayerRenderer;
		}

		/**
		 * 获得实际用于创建 WireframeLayerRenderer 的类
		 * @return
		 *
		 */
		protected function get wireframeLayerRendererClass():Class
		{
			return WireframeLayerRenderer;
		}

		/**
		 * 获得实际用于创建 SoundLayerRenderer 的类
		 * @return
		 *
		 */
		protected function get soundLayerRendererClass():Class
		{
			return SoundLayerRenderer;
		}

		/**
		 * onMouseDown
		 * @return
		 *
		 */
		[Inline]
		final public function get onMouseDown():Signal
		{
			return mouseResponder.onMouseDown;
		}

		/**
		 * onMouseUp
		 * @return
		 *
		 */
		[Inline]
		final public function get onMouseUp():Signal
		{
			return mouseResponder.onMouseUp;
		}

		/**
		 * onRollOut
		 * @return
		 *
		 */
		[Inline]
		final public function get onRollOut():Signal
		{
			return mouseResponder.onRollOut;
		}

		/**
		 * onRollOver
		 * @return
		 *
		 */
		[Inline]
		final public function get onRollOver():Signal
		{
			return mouseResponder.onRollOver;
		}

		/**
		 * @inheritDoc
		 *
		 */
		final public function get state():String
		{
			return mouseResponder.state;
		}

		/**
		 * @inheritDoc
		 *
		 */
		final public function get touchable():Boolean
		{
			return mouseResponder.touchable;
		}

		/**
		 * @inheritDoc
		 *
		 */
		final public function set touchable(value:Boolean):void
		{
			mouseResponder.touchable = value;
		}

		/**
		 * 根据图层名字获得指定的图形渲染器
		 * @param name
		 * @return
		 *
		 */
		final public function getRendererByName(name:String):DisplayObject
		{
			return null;
		}

		/**
		 * 继续渲染
		 *
		 */
		public function play():void
		{
			_isPlaying = true;
		}

		/**
		 * 暂停渲染
		 *
		 */
		public function pause():void
		{
			_isPlaying = false;
		}

		protected var _isPlaying:Boolean;

		/**
		 * @inheritDoc
		 *
		 */
		public function advanceTime(passedTime:Number):void
		{
			if (!_isPlaying)
			{
				return;
			}

			// FIXME 避免无用的 playRenderers 调用
			// 使用 actionName 判断是否有动作播放中
			// 而不是 actionInfo，这可以减少一次方法调用
			if (actionName)
			{
				playRenderers(_info.currentFrame);
			}

			// 对象不在静止状态，我们更新坐标
			if (!isSticky)
			{
				moveTo(_info.position);
			}

			// 如果 info 已是静止状态，我们延迟一帧再标记渲染器为静止
			// 这可以避免更新不到静止当下这帧的位置
			if (isJustSticky)
			{
				isSticky = true;
			}
		}

		/**
		 * 更新所有声音
		 * @param _currentFrame
		 *
		 */
		[Inline]
		private function playSound(currentFrame:int):void
		{
			var i:int, n:int;

			// 播放声音
			for (i = 0, n = sounds.length; i < n; i++)
			{
				sounds[i].currentFrame = currentFrame;
			}
		}

		/**
		 * 更新所有显示层
		 * @param currentFrame 播放的帧
		 *
		 */
		[Inline]
		private function playRenderers(currentFrame:int):void
		{
			var i:int, n:int;

			// 粒子
			for (i = 0, n = particles.length; i < n; i++)
			{
				particles[i].currentFrame = currentFrame;
			}

			// 贴图
			for (i = 0, n = animations.length; i < n; i++)
			{
				animations[i].currentFrame = currentFrame;
			}

			// 线框
			for (i = 0, n = wireframes.length; i < n; i++)
			{
				wireframes[i].currentFrame = currentFrame;
			}
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		public function dispose():Boolean
		{
			assert(!_isDisposed, "不能重复释放资源");
			// 解除关联的 ObjectInfo
			info = null;
			// 设置 container 为 null 之后会自动从 juggler 删除
			parent = null;

			// 释放所有子渲染器：
			for each (var renderer:IDisplayObject3D in renderers)
			{
				renderer.dispose();
			}
			// 几个列表也清掉
			renderers = null;
			animations = null;
			sounds = null;
			particles = null;
			wireframes = null;

			// 最后广播下 dispose
			if (_onDispose)
			{
				_onDispose.dispatch(this);
				_onDispose.removeAll();
			}
			return _isDisposed = true;
		}

		private var _isDisposed:Boolean;

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		public function get isDisposed():Boolean
		{
			return _isDisposed;
		}

		private var _filter:FragmentFilter;

		/**
		 * 设置或获取要套用的滤镜
		 * @return
		 *
		 */
		public function get filter():FragmentFilter
		{
			return _filter;
		}

		public function set filter(value:FragmentFilter):void
		{
			_filter = value;
			// 对所有动画层应用滤镜
			var i:int, n:int;

			for (i = 0, n = animations.length; i < n; i++)
			{
				animations[i].filter = _filter;
			}
		}

		private var _outlineColor:uint;

		private var isAvatarIDChange:Boolean;

		/**
		 * 设置或获取轮廓的颜色<br>
		 * 轮廓是用滤镜实现的<br>
		 * 设置为 0 将取消滤镜
		 * @return
		 *
		 */
		public function get outlineColor():uint
		{
			return _outlineColor;
		}

		public function set outlineColor(value:uint):void
		{
			_outlineColor = value;

			if (_outlineColor != 0)
			{
				filter = BlurFilter.createGlow(value, 1, 3);
			}
			else
			{
				filter = null;
			}
		}

		private var _alpha:Number = 1;

		/**
		 * 设置或获取 alpha，默认值 1
		 */
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
				validateAlpha();
			}
		}

		/**
		 * 结合 info.alpha 计算新 alpha
		 *
		 */
		protected function validateAlpha():void
		{
			const newAlpha:Number = _alpha * (_info ? _info.alpha : 1);
			// 应用到所有动画
			var i:int, n:int;

			for (i = 0, n = animations.length; i < n; i++)
			{
				animations[i].alpha = newAlpha;
			}
		}

		private var _color:uint;

		/**
		 * 设置或获取 color
		 */
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
				validateColor();
			}
		}

		/**
		 * @private
		 *
		 */
		protected function validateColor():void
		{
			// color 属性只应用到所有动画
			var i:int, n:int;

			for (i = 0, n = animations.length; i < n; i++)
			{
				animations[i].color = _color;
			}
		}

		private var _direction:int;

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		public function get direction():int
		{
			return _direction;
		}

		public function set direction(value:int):void
		{
			_direction = value;
			validateDirection();
		}

		/**
		 * @private
		 *
		 */
		protected function validateDirection():void
		{
			for (var i:int = 0, n:int = renderers.length; i < n; i++)
			{
				if (renderers[i] is IDirectionRenderer)
				{
					IDirectionRenderer(renderers[i]).direction = _direction;
				}
			}
		}

		/**
		 * 移动到指定位置
		 * @param position
		 *
		 */
		private function moveTo(position:Vector3D):void
		{
			_x = position.x;
			_y = position.y;
			_z = position.z;

			for (var i:int = 0, n:int = renderers.length; i < n; i++)
			{
				renderers[i].position = position;
			}
		}
	}
}
