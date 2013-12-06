package age.renderers
{
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
			if (_box)
			{
				frontQB.visible = false;
				backQB.visible = false;
			}
			_box = value; // reset 批处理

			if (_box)
			{
				frontQB.reset();
				backQB.reset();
				// 设置 pivot
				const pivotX:Number = box.pivot.x * box.width;
				const pivotY:Number = box.pivot.y * box.height;
				const pivotZ:Number = box.pivot.z * box.depth;
				frontQB.pivotX = pivotX;
				frontQB.pivotY = pivotY;
				backQB.pivotX = pivotX;
				backQB.pivotY = pivotY;
				frontQB.zOffset = pivotZ + box.z - box.depth;
				backQB.zOffset = pivotZ + box.z;
				// front
				drawLine(0, box.x, box.y, box.width, 1); // 下
				drawLine(1, box.width + box.x, box.y, 1, -box.height); // 右
				drawLine(2, box.width + box.x, -box.height + box.y, -box.width, 1); // 上
				drawLine(3, box.x, -box.height + box.y, 1, box.height); // 左
				// back
				drawLine(4, box.x, box.y, box.width, 1, 0.3); // 下
				drawLine(5, box.width + box.x, box.y, 1, -box.height, 0.3); // 右
				drawLine(6, box.width + box.x, -box.height + box.y, -box.width, 1, 0.3); // 上
				drawLine(7, box.x, -box.height + box.y, 1, box.height, 0.3); // 左
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
			frontQB.scaleX = _direction & Direction.RIGHT ? 1 : -1
			backQB.scaleX = _direction & Direction.RIGHT ? 1 : -1
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
