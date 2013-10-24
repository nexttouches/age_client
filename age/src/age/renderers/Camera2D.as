package age.renderers
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Quad;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import age.AGE;
	import org.osflash.signals.Signal;
	import starling.animation.IAnimatable;
	import starling.filters.Spotlight2Filter;

	/**
	 * 2D 相机
	 * @author zhanghaocong
	 *
	 */
	public class Camera2D implements IAnimatable
	{
		private var _onShakeStart:Signal;

		/**
		 * 开始震屏时广播
		 * @return
		 *
		 */
		public function get onShakeStart():Signal
		{
			return _onShakeStart ||= new Signal(Camera2D);
		}

		/**
		 * 标记当前是否正在 tween
		 */
		private var isTweening:Boolean;

		/**
		 * 当前跟踪的点<br>
		 * 该点可以是任意具有 x, y 属性的对象
		 */
		private var trackPoint:Object;

		/**
		 * 抖动的辅助类
		 */
		private var _shake:CameraShake;

		/**
		 * 是否限制边界
		 */
		public var isLimitBounds:Boolean = true;

		/**
		 * 创建一个新的 Camera2D
		 *
		 */
		public function Camera2D()
		{
		}

		/**
		 * @inheritDoc
		 * @param time
		 *
		 */
		public function advanceTime(time:Number):void
		{
			if (!_scene)
			{
				return;
			}

			if (!_scene.info)
			{
				return;
			}

			if (!trackPoint)
			{
				return;
			}

			// 动态更新中心点
			if (threshold > 0)
			{
				var globalTrackPoint:Point = _scene.charLayer.localToGlobal(new Point(trackPoint.x, trackPoint.y));
				centerPoint.x = globalTrackPoint.x;

				if (globalTrackPoint.x < AGE.stageWidth * threshold)
				{
					centerPoint.x = AGE.stageWidth * threshold;
				}

				if (globalTrackPoint.x > AGE.stageWidth * (1 - threshold))
				{
					centerPoint.x = AGE.stageWidth * (1 - threshold);
				}
			}
			_scene.globalToLocal(centerPoint, centerPointLocal);
			var baseX:int = centerPointLocal.x - trackPoint.x;
			var baseY:int = centerPointLocal.y - trackPoint.y;

			if (isLimitBounds)
			{
				// 左边界
				if (baseX > 0)
				{
					baseX = 0;
				}

				// 上边界
				if (baseY > 0)
				{
					baseY = 0;
				}

				// 右边界
				if (baseX < AGE.stageWidth / _zoomScale - scene.info.width)
				{
					baseX = AGE.stageWidth / _zoomScale - scene.info.width;
				}

				// 下边界
				if (baseY < AGE.stageHeight / _zoomScale - scene.info.height)
				{
					baseY = AGE.stageHeight / _zoomScale - scene.info.height;
				}
			}

			for (var i:int = 0, n:int = _scene.numChildren; i < n; i++)
			{
				var l:LayerRenderer = _scene.getChildAt(i) as LayerRenderer;
				var newX:int = baseX * l.info.scrollRatio * _zoomScale;
				var newY:int = baseY * l.info.scrollRatio * _zoomScale;

				if (isTweening) // 平滑 Tween
				{
					// TODO TweenLite 复用
					TweenLite.to(l, 0.3, { x: newX, y: newY,
									 ease: Expo.easeOut });
				}
				else
				{
					// 最朴素的移动方法
					l.x = newX;
					l.y = newY;
				}
			}

			if (spotlight)
			{
				var sp:Point = scene.charLayer.localToGlobal(new Point(trackPoint.x, trackPoint.y));
				spotlight.x = sp.x;
				spotlight.y = sp.y;
			}

			// 抖动效果
			if (_shake)
			{
				if (!_shake.nextFrame(this))
				{
					_shake = null;
				}
			}
		}

		/**
		 * 跟踪一个 Point2D<br>
		 * @param p 要跟踪的点，必须含有 x 和 y 属性
		 * @param zoomScale 缩放比例
		 * @param useTween 是否使用平滑卷动
		 * @param threshold 当 useTween 为 false 时，距屏幕多少百分比才进行卷动
		 */
		public function track(p:Object, zoomScale:Number = 1, useTween:Boolean = false, threshold:Number = 0.3):void
		{
			if (p == null)
			{
				this.trackPoint = p;
				return;
			}

			if (!(p.hasOwnProperty("x") && p.hasOwnProperty("y")))
			{
				if (Capabilities.isDebugger)
				{
					throw new ArgumentError("p 必须含有 x 和 y 属性");
				}
				else
				{
					return;
				}
			}
			this.trackPoint = p;
			isTweening = useTween;
			this.threshold = threshold;
			zoom(zoomScale);
		}

		private var _zoomScale:Number;

		/**
		 * 获取缩放比例
		 * @return
		 *
		 */
		final public function get zoomScale():Number
		{
			return _zoomScale;
		}

		/**
		 * 缩放到指定比例
		 * @param scale
		 *
		 */
		public function zoom(scale:Number):void
		{
			if (_zoomScale != scale)
			{
				_zoomScale = scale;
				TweenLite.to(_scene, 0.3, { ease: Quad.easeOut, scaleX: _zoomScale,
								 scaleY: _zoomScale,
								 onComplete: function():void
								 {

								 }});
			}
		}

		/**
		 * @private
		 */
		private var _center:Point;

		/**
		 * 临时变量
		 */
		private var centerPoint:Point = new Point;

		/**
		 * 临时变量
		 */
		private var centerPointLocal:Point = new Point;

		/**
		 * 设置或获取中心点
		 * @return
		 *
		 */
		final public function get center():Point
		{
			return _center;
		}

		public function set center(value:Point):void
		{
			_center = value;
			centerPoint.x = _center.x;
			centerPoint.y = _center.y;
		}

		private var _scene:SceneRenender;

		/**
		 * 设置或获取 SceneRenender
		 * @return
		 *
		 */
		public function get scene():SceneRenender
		{
			return _scene;
		}

		public function set scene(value:SceneRenender):void
		{
			_scene = value;

			if (_scene)
			{
				_zoomScale = _scene.scaleX; // 当前缩放值
			}
		/*if (_scene)
		{
		spotlight = new Spotlight2Filter(0, 0, .33, 2);
		_scene.filter = spotlight;
		}*/
		}

		/**
		 * 抖动<br>
		 * TODO: 将帧数改成持续时间
		 * @param intensity 剧烈程度
		 * @param numFrames 持续帧数
		 *
		 */
		public function shake(intensity:Number, numFrames:int):void
		{
			_shake = new CameraShake(intensity, numFrames);

			if (_onShakeStart)
			{
				_onShakeStart.dispatch(this);
			}
		}

		private var _bounds:Rectangle;

		/**
		 * 点光滤镜，可以用来做失明 debuff
		 */
		private var spotlight:Spotlight2Filter;

		/**
		 * 设置跟踪的目标移动了多少像素后，相机才跟着走
		 */
		private var threshold:Number;

		/**
		 * 设置或获取摄像机的边界<br>
		 * 默认值为设置的 scene 的宽度
		 * @return
		 *
		 */
		public function get bounds():Rectangle
		{
			return _bounds;
		}

		public function set bounds(value:Rectangle):void
		{
			_bounds = value;
		}
	}
}
