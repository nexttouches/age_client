package age.renderers
{
	import age.data.Box;
	import age.data.FrameLayerInfo;
	import nt.assets.IAsset;
	import nt.assets.IAssetUser;

	/**
	 * 动画图层渲染器
	 * @author zhanghaocong
	 *
	 */
	public class AnimationLayerRenderer extends Image3D implements IAssetUser
	{
		/**
		 * 缓存当前图层索引，排序时会用到
		 */
		protected var layerIndex:int;

		/**
		 * 缓存当前 info 是否已加载好
		 */
		protected var info_isComplete:Boolean

		/**
		 * 创建一个新的 FrameLayerRenderer
		 *
		 */
		public function AnimationLayerRenderer()
		{
			super();
			uniqueIndex += ZIndexHelper.ANIMATION_OFFSET;
		}

		private var _currentFrame:int;

		/**
		 * 设置或获取当前渲染的帧
		 * @return
		 *
		 */
		[Inline]
		final public function get currentFrame():int
		{
			return _currentFrame;
		}

		public function set currentFrame(value:int):void
		{
			if (!info_isComplete)
			{
				return;
			}
			_currentFrame = value;

			// XXX 这里的 .textures 可以做个数组暂存
			if (_currentFrame < _info.textures.length && _info.textures[_currentFrame])
			{
				visible = true;
				isVisibleLocked = false;
				texture = _info.textures[_currentFrame];
			}
			else
			{
				visible = false;
				isVisibleLocked = true;
			}
		}

		private var isVisibleLocked:Boolean;

		override public function set visible(value:Boolean):void
		{
			if (isVisibleLocked)
			{
				return;
			}
			super.visible = value;
		}

		private var _info:FrameLayerInfo;

		/**
		 * 设置或获取要渲染的 FrameLayerInfo<br>
		 * 之后可以通过改变 <code>currentFrame</code> 调整播放头
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
				layerIndex = 0;
				info_isComplete = false;
				_info.removeUser(this);
			}
			_info = value;

			if (_info)
			{
				layerIndex = _info.index;
				_info.addUser(this);

				if (_info.isComplete)
				{
					onAssetLoadComplete(_info);
				}
				else
				{
					_info.load();
				}
			}
		}

		/**
		 * @inheritDoc
		 * @param asset
		 *
		 */
		public function onAssetDispose(asset:IAsset):void
		{
			_info = null;
			info_isComplete = false;
		}

		/**
		 * @inheritDoc
		 * @param asset
		 *
		 */
		public function onAssetLoadComplete(asset:IAsset):void
		{
			adjustSize();
			info_isComplete = true;
			currentFrame = _currentFrame;
		}

		/**
		 * @inheritDoc
		 * @param asset
		 *
		 */
		public function onAssetLoadError(asset:IAsset):void
		{
		}

		/**
		 * @inheritDoc
		 * @param asset
		 *
		 */
		public function onAssetLoadProgress(asset:IAsset, bytesLoaded:uint, bytesTotal:uint):void
		{
		}

		/**
		 * 该方法根据 *第一帧* 调整下列属性
		 * <ol>
		 * <li>渲染的顶点位置</li>
		 * <li>pivotX 和 pivotY</li>
		 * </ol>
		 *
		 */
		[Inline]
		final protected function adjustSize():void
		{
			// 调整原点
			const box:Box = _info.frames[0].box;
			const width:int = box.width;
			const height:int = box.height;
			pivotX = width * (box.pivot.x);
			pivotY = height * (1 - box.pivot.y); // 坐标系不同，需要颠倒的 pivot.y
			mVertexData.setPosition(0, 0.0, 0.0);
			mVertexData.setPosition(1, width, 0.0);
			mVertexData.setPosition(2, 0.0, height);
			mVertexData.setPosition(3, width, height);
			onVertexDataChanged();
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function dispose():void
		{
			info = null;
			super.dispose();
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
