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
		 * 将根据图层名字设置框颜色，默认是白色
		 */
		private var COLORS:Object = { hitBox: 0x00ff00, attackBox: 0xff0000, DEFAULT: 0xffffff };

		/**
		 * 前面的框
		 */
		private var frontQB:QuadBatch3D = new QuadBatch3D();

		/**
		 * 后面的框
		 */
		private var backQB:QuadBatch3D = new QuadBatch3D();

		/**
		 * 所有线（其中 0~3 会放在 frontQB，4~7 则在 backQB）
		 */
		private var rects:Vector.<Rect> = new Vector.<Rect>(8);

		/**
		 * 当前线框的颜色（默认是 <tt>COLORS.DEFAULT</tt>）
		 */
		private var color:uint = COLORS.DEFAULT;

		/**
		 * constructor
		 *
		 */
		public function WireframeLayerRenderer()
		{
		}

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
		 * @param index
		 * @param width
		 * @param height
		 * @param alpha
		 *
		 */
		public function drawLine(index:int, x:Number, y:Number, width:Number, height:Number, alpha:Number = 1):void
		{
			if (!rects[index])
			{
				rects[index] = new Rect(width, height);
			}
			else
			{
				rects[index].setTo(width, height);
			}
			const r:Rect = rects[index] as Rect;
			r.x = x;
			r.y = y;
			r.alpha = alpha;
			r.color = color;
			r.visible = true;

			if (index < 4)
			{
				frontQB.addQuad(r);
			}
			else
			{
				backQB.addQuad(r);
			}
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
					_parent.removeChild(frontQB);
					_parent.removeChild(backQB);
				}
				_parent = value;

				if (_parent)
				{
					_parent.addChild(frontQB);
					_parent.addChild(backQB);
					projectY = _parent.info.parent.projectY;
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

		private var DEFAULT_ALPHA:Number = 0.8;

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

		private var box:Box = new Box();

		/**
		 * 重绘框
		 *
		 */
		public function validate():void
		{
			if (_frameInfo && _frameInfo.keyframe.box)
			{
				// 取关键帧的 box
				const originBox:Box = _frameInfo.keyframe.box.clone1();
				box.direction = Direction.RIGHT;
				box.setTo(originBox.x, originBox.y, originBox.z, originBox.width, originBox.height, originBox.depth, originBox.pivot.x, originBox.pivot.y, originBox.z);
				box.direction = _direction;
				// 取出所有顶点用于绘制
				const vertices:Vector.<Vector3D> = box.vertices.concat();
				var i:int, n:int;
				var points:Vector.<Point> = new Vector.<Point>(vertices.length, true);

				for (i = 0; i < vertices.length; i++)
				{
					// 投影到 2D 坐标系后，再交给 Quad 画线
					points[i] = new Point(vertices[i].x, _projectY(vertices[i].y, vertices[i].z));
				}
				// reset 批处理
				frontQB.reset();
				backQB.reset();
				// front
				drawLine(0, 0, 0, box.width, 1); // 下
				drawLine(1, box.width, 0, 1, -box.height); // 右
				drawLine(2, box.width, -box.height, -box.width, 1); // 上
				drawLine(3, 0, -box.height, 1, box.height); // 左
					// back
					//drawLine(4, 0, 0, box.width, 1);
					//drawLine(5, box.width, 0, 1, box.height);
					//drawLine(6, box.width, box.height, -box.width, 1);
					//drawLine(7, 0, box.height, 1, -box.height);
			}
			else
			{
				frontQB.visible = false;
				backQB.visible = false;
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
			validate();
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
			frontQB.position = value;
			backQB.position = value;
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
			frontQB.position.setTo(x, y, z);
			backQB.position.setTo(x, y, z);
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function setX(value:Number):void
		{
			position.x = value;
			frontQB.position.x = value;
			backQB.position.x = value;
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function setY(value:Number):void
		{
			position.y = value;
			frontQB.position.y = value;
			backQB.position.y = value;
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function setZ(value:Number):void
		{
			position.z = value;
			frontQB.position.z = value;
			backQB.position.z = value;
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
			frontQB.projectY = value;
			backQB.projectY = value;
		}
	}
}
