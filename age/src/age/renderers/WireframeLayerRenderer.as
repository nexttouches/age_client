package age.renderers
{
	import com.greensock.easing.Quad;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import age.assets.Box;
	import age.assets.FrameInfo;
	import age.assets.FrameLayerInfo;

	/**
	 * 线框渲染器
	 * @author zhanghaocong
	 *
	 */
	public class WireframeLayerRenderer implements IDisplayObject3D, IDirectionRenderer
	{
		private var COLORS:Object = { hitBox: 0x00ff00, attackBox: 0xff0000 };

		private var color:uint;

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

		public function drawLine(index:int, v:Vector3D, width:Number, height:Number, alpha:Number = 1):void
		{
			if (quads[index] == null)
			{
				quads[index] = new Wireframe(0, 0, color);
				quads[index].alpha = alpha * DEFAULT_ALPHA;
			}
			const q:Quad3D = quads[index];

			if (parent && !q.parent)
			{
				parent.addChild(q);
			}
			q.draw(width, height);
			q.x = v.x;
			q.y = v.y;
			q.z = v.z;
			q.visible = true;
		}

		/**
		* 所有子渲染器
		*/
		public var quads:Vector.<Quad3D> = new Vector.<Quad3D>(8);

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
					for (i = 0; i < quads.length; i++)
					{
						if (!quads[i])
						{
							continue;
						}
						_parent.removeChild(quads[i]);
					}
				}
				_parent = value;

				if (_parent)
				{
					for (i = 0; i < quads.length; i++)
					{
						if (!quads[i])
						{
							continue;
						}
						_parent.addChild(quads[i]);
					}
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
				color = 0;
			}
			_info = value;

			if (_info)
			{
				color = COLORS[_info.name]
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

		private var _projectY:Function;

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		public function get projectY():Function
		{
			return _projectY;
		}

		public function set projectY(value:Function):void
		{
			_projectY = value;
			validate();
		}

		private var _scale:Number = 1;

		public function get scale():Number
		{
			return _scale;
		}

		public function set scale(value:Number):void
		{
			_scale = value;
			validate();
		}

		/**
		 * 位置信息
		 */
		private var position:Vector3D = new Vector3D();

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		public function get x():Number
		{
			return position.x;
		}

		public function set x(value:Number):void
		{
			position.x = value;
			validate();
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		public function get y():Number
		{
			return position.y;
		}

		public function set y(value:Number):void
		{
			position.y = value;
			validate();
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		public function get z():Number
		{
			return position.z;
		}

		public function set z(value:Number):void
		{
			position.z = value;
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

		public function validate():void
		{
			if (_frameInfo && _frameInfo.keyframe.box)
			{
				// 取关键帧的 box
				const box:Box = _frameInfo.keyframe.box;
				box.direction = _direction;
				// 取出所有顶点用于绘制
				const vertices:Vector.<Vector3D> = box.vertices.concat();
				var i:int, n:int;
				var points:Vector.<Point> = new Vector.<Point>(vertices.length, true);

				for (i = 0; i < vertices.length; i++)
				{
					vertices[i] = vertices[i].add(position);
					// 投影到 2D 坐标系后，再交给 Quad 画线
					points[i] = new Point(vertices[i].x, _projectY(vertices[i].y, vertices[i].z));
				}
				// front
				drawLine(0, vertices[0], points[1].x - points[0].x, 1);
				drawLine(1, vertices[1], 1, points[2].y - points[1].y);
				drawLine(2, vertices[2], points[3].x - points[2].x, 1);
				drawLine(3, vertices[3], 1, points[0].y - points[3].y);
				// back
				drawLine(4, vertices[4], points[5].x - points[4].x, 1, 0.3);
				drawLine(5, vertices[5], 1, points[6].y - points[5].y, 0.3);
				drawLine(6, vertices[6], points[7].x - points[6].x, 1, 0.3);
				drawLine(7, vertices[7], 1, points[0].y - points[7].y, 0.3);
			}
			else
			{
				for (i = 0; i < quads.length; i++)
				{
					const q:Quad3D = quads[i];

					if (q)
					{
						q.removeFromParent();
					}
				}
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
			currentFrame = _currentFrame
		}
	}
}
