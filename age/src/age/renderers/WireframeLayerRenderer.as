package age.renderers
{
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import age.data.Box;
	import age.data.FrameInfo;
	import age.data.FrameLayerInfo;

	/**
	 * 线框渲染器。一共有 8 根线，分别放在 frontQB 和 backQB 中进行批处理。
	 * @author zhanghaocong
	 *
	 */
	public class WireframeLayerRenderer implements IDisplayObject3D, IDirectionRenderer
	{
		/**
		 * constructor
		 *
		 */
		public function WireframeLayerRenderer()
		{
		}

		/**
		 * 将根据图层名字设置框颜色，默认是白色
		 */
		private static var COLORS:Object = { hitBox: 0x00ff00, attackBox: 0xff0000,
				DEFAULT: 0xffffff };

		/**
		 * 所有线（其中 0~3 会放在 frontQB，4~7 则在 backQB）
		 */
		private var rects:Vector.<Rect> = new Vector.<Rect>(8);

		/**
		 * 当前线框的颜色（默认是 <tt>COLORS.DEFAULT</tt>）
		 */
		private var color:uint = COLORS.DEFAULT;

		private var _currentFrame:int;

		/**
		 * 设置或获取当前帧
		 * @return
		 *
		 */
		public function get currentFrame():int
		{
			return _currentFrame;
		}

		public function set currentFrame(value:int):void
		{
			_currentFrame = value;

			if (_projectY == null)
			{
				return;
			}

			if (_currentFrame < _info.frames.length)
			{
				frameInfo = _info.frames[_currentFrame];
			}
			else
			{
				frameInfo = null;
			}
		}

		/**
		 * 根据参数绘制线
		 * @param index 第几根
		 * @param position 初始位置
		 * @param width 宽
		 * @param height 高
		 * @param alpha 透明度
		 *
		 */
		public function drawLine(index:int, position:Vector3D, width:Number, height:Number, alpha:Number = 1):void
		{
//			trace("[DRAWLINE] index: " + index + " (" + position + ", " + width + ", " + height + ")");

			if (!rects[index])
			{
				rects[index] = new Rect(width, height);
				_parent.addChild(rects[index]);
			}
			else
			{
				rects[index].setTo(width, height);
			}
			const r:Rect = rects[index] as Rect;
			r.position = position;
			r.alpha = alpha;
			r.color = color;
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
			var i:int, n:int = rects.length;

			if (_parent != value)
			{
				if (_parent)
				{
					for (i = 0; i < n; i++)
					{
						if (rects[i])
						{
							rects[i].projectY = null;
							rects[i].removeFromParent();
						}
					}
				}
				_parent = value;

				if (_parent)
				{
					projectY = _parent.info.parent.projectY;

					for (i = 0; i < n; i++)
					{
						if (rects[i])
						{
							rects[i].projectY = _projectY;
							_parent.addChild(rects[i]);
						}
					}
				}
			}
		}

		private var _info:FrameLayerInfo;

		/**
		 * 设置或获取当前播放的 FrameLayerInfo
		 * @return
		 *
		 */
		public function get info():FrameLayerInfo
		{
			return _info;
		}

		public function set info(value:FrameLayerInfo):void
		{
			if (_info)
			{
				color = COLORS.DEFAULT;
			}
			_info = value;

			if (_info)
			{
				color = COLORS[_info.name] || COLORS.DEFAULT;
			}
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		public function dispose():void
		{
			frameInfo = null;
			parent = null;
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		public function get zIndex():int
		{
			return 0;
		}

		private var _scale:Number = 1;

		/**
		 * @inheritDoc
		 *
		 */
		public function get scale():Number
		{
			return _scale;
		}

		public function set scale(value:Number):void
		{
			_scale = value;
			validate();
		}

		private var _frameInfo:FrameInfo;

		/**
		 * 设置或获取当前渲染的 FrameInfo
		 * @return
		 *
		 */
		public function get frameInfo():FrameInfo
		{
			return _frameInfo;
		}

		public function set frameInfo(value:FrameInfo):void
		{
			if (_frameInfo != value)
			{
				_frameInfo = value;
				validate();
			}
		}

		private var _box:Box;

		/**
		 * 设置或获取本次要绘制的框
		 * @return
		 *
		 */
		public function get box():Box
		{
			return _box;
		}

		public function set box(value:Box):void
		{
			var i:int, n:int = rects.length;

			if (_box)
			{
				for (i = 0; i < n; i++)
				{
					if (rects[i])
					{
						rects[i].visible = false;
					}
				}
			}
			_box = value; // reset 批处理

			if (_box)
			{
				const pivotZ:Number = box.pivot.z * box.depth;
				const vertices:Vector.<Vector3D> = box.vertices;
				const points:Vector.<Point> = new Vector.<Point>(vertices.length);

				for (i = 0, n = vertices.length; i < n; i++)
				{
					points[i] = new Point(vertices[i].x, _projectY(vertices[i].y, vertices[i].z));
				}
				// 绘制 front
				drawLine(0, vertices[0], points[1].x - points[0].x, 1); // 下
				drawLine(1, vertices[1], 1, points[2].y - points[1].y); // 右
				drawLine(2, vertices[2], points[3].x - points[2].x, 1); // 上
				drawLine(3, vertices[3], 1, points[1].y - points[3].y); // 左
				// 绘制 back
				drawLine(4, vertices[4], points[5].x - points[4].x, 1, 0.3); // 下
				drawLine(5, vertices[5], 1, points[6].y - points[5].y, 0.3); // 右
				drawLine(6, vertices[6], points[7].x - points[6].x, 1, 0.3); // 上
				drawLine(7, vertices[7], 1, points[4].y - points[7].y, 0.3); // 左
			}
		}

		/**
		 * 重绘框
		 *
		 */
		public function validate():void
		{
			if (_frameInfo && _frameInfo.keyframe.box)
			{
				// 取关键帧的 box
				box = _frameInfo.keyframe.box;
			}
			else
			{
				box = null;
			}
		}

		private var _direction:int = Direction.RIGHT;

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
//			frontQB.scaleX = _direction & Direction.RIGHT ? 1 : -1
//			backQB.scaleX = _direction & Direction.RIGHT ? 1 : -1
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
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function setX(value:Number):void
		{
			position.x = value;
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function setY(value:Number):void
		{
			position.y = value;
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function setZ(value:Number):void
		{
			position.z = value;
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
		}
	}
}
