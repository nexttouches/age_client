package age.renderers
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import age.AGE;
	import age.data.Box;
	import age.data.FrameInfo;
	import age.data.FrameLayerInfo;
	import nt.assets.IAsset;
	import nt.assets.IAssetUser;
	import starling.events.Event;

	/**
	 * 粒子图层
	 * @author zhanghaocong
	 *
	 */
	public class ParticleLayerRenderer extends ParticleSystem3D implements IDetailRenderer, IAssetUser
	{
		/**
		 * 缓存当前图层索引，排序时会用到
		 */
		private var layerIndex:int;

		/**
		 * 用于避免闪烁的唯一索引
		 */
		protected var uniqueIndex:int;

		/**
		 * constructor
		 *
		 */
		public function ParticleLayerRenderer()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAdd);
			uniqueIndex = ZIndexHelper.getUniqueZIndex();
		}

		/**
		 * @private
		 *
		 */
		private function onAdd():void
		{
			projectY = SceneRenender(parent.parent).projectY;
		}

		private var _info:FrameLayerInfo;

		/**
		 * 设置或获取渲染的 FrameLayerInfo
		 */
		public function get info():FrameLayerInfo
		{
			return _info;
		}

		/**
		 * @private
		 */
		public function set info(value:FrameLayerInfo):void
		{
			if (_info != value)
			{
				_info = value;
					// TODO 此处要设置使用外部贴图
			}

			if (_info)
			{
				layerIndex = _info.index;
				AGE.renderJuggler.add(this);
			}
			else
			{
				layerIndex = 0;
				AGE.renderJuggler.remove(this);
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function dispose():void
		{
			info = null;
			super.dispose();
		}

		private var _currentFrame:int = -1;

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
			if (_currentFrame != value)
			{
				_currentFrame = value;
				validateCurrentFrame();
			}
		}

		/**
		 * 更新当前帧
		 *
		 */
		protected function validateCurrentFrame():void
		{
			if (_currentFrame == -1)
			{
				return;
			}
			var isEmpty:Boolean = !_info || _info.frames.length <= _currentFrame;

			if (!isEmpty)
			{
				const keyframe:FrameInfo = _info.frames[_currentFrame].keyframe;

				if (keyframe.particleConfig)
				{
					config = keyframe.particleConfig;
				}
				else
				{
					isEmpty = true;
				}
				box = keyframe.box;

				if (config)
				{
					// 使用外部贴图
					if (!config.isUseNativeTexture)
					{
						if (_info.textures && _info.textures[_currentFrame])
						{
							texture = _info.textures[_currentFrame];
						}
						else
						{
							isEmpty = true;
						}
					}
					else
					{
						texture = defaultTexture;
					}
				}
				else
				{
					isEmpty = true;
				}
			}

			if (isEmpty)
			{
				texture = null;
				config = null;
			}
		}

		/**
		 * @inhertDoc
		 *
		 */
		public function updateDetail(visibleRect:Rectangle):void
		{
			// 左边界
			if (emitterX < visibleRect.x)
			{
				visible = false;
				return;
			}

			// 上边界
			if (emitterY < visibleRect.y)
			{
				visible = false;
				return;
			}

			// 右边界
			if (emitterX > visibleRect.right)
			{
				visible = false;
				return;
			}

			// 下边界
			if (emitterY > visibleRect.bottom)
			{
				visible = false;
				return;
			}
			visible = true;
		}

		private var _box:Box;

		/**
		 * 设置或获取当前图层使用的 Box<br>
		 * Box 实际用于调整偏移量
		 * @return
		 *
		 */
		public function get box():Box
		{
			return _box;
		}

		public function set box(value:Box):void
		{
			if (_box != value)
			{
				_box = value;
				validateBox();
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function set direction(value:int):void
		{
			super.direction = value;
			validateBox();
		}

		/**
		 * 验证更新 Box
		 *
		 */
		private function validateBox():void
		{
			validatePosition();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function validatePosition():void
		{
			if (_projectY == null)
			{
				return;
			}

			if (_box)
			{
				emitterX = position.x + (_direction == Direction.RIGHT ? _box.x : -_box.x);
				emitterY = _projectY(position.y + _box.y, position.z + _box.z);
			}
			else
			{
				super.validatePosition();
			}
		}

		private static var helperVector:Vector3D = new Vector3D;

		private static var helperPoint:Point = new Point;

		public function onAssetDispose(asset:IAsset):void
		{
			// TODO Auto Generated method stub
		}

		public function onAssetLoadComplete(asset:IAsset):void
		{
			// TODO Auto Generated method stub
		}

		public function onAssetLoadError(asset:IAsset):void
		{
			// TODO Auto Generated method stub
		}

		public function onAssetLoadProgress(asset:IAsset, bytesLoaded:uint, bytesTotal:uint):void
		{
			// TODO Auto Generated method stub
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function get zIndex():int
		{
			return position.z * ZIndexHelper.Z_RANGE + layerIndex + uniqueIndex;
		}
	}
}
