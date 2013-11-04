package age.renderers
{
	import age.assets.BGInfo;
	import age.assets.SceneInfo;
	import age.assets.TextureAsset;
	import nt.assets.IAsset;
	import starling.events.Event;

	/**
	 * BGRenderer 用于渲染场景静态图片
	 * @author zhanghaocong
	 *
	 */
	public class BGRenderer extends TextureRenderer
	{
		/**
		 * constructor
		 *
		 */
		public function BGRenderer()
		{
			super();
		}

		protected var _info:BGInfo;

		/**
		 * 设置或获取 BlockInfo
		 * @return
		 *
		 */
		final public function get info():BGInfo
		{
			return _info;
		}

		public function set info(value:BGInfo):void
		{
			if (_info)
			{
				asset = null;

				if (filter)
				{
					filter.dispose();
				}
				filter = null;
			}
			_info = value;

			if (_info)
			{
				x = _info.x;
				y = _info.y;
				z = _info.z;
				asset = getAsset();
				asset.useThumb = false;
				asset.load();
			}
		}

		/**
		 * 获得本次需要使用的资源
		 * @return
		 *
		 */
		protected function getAsset():TextureAsset
		{
			return TextureAsset.get(SceneInfo.folder + "/" + _info.texturePath);
		}

		/**
		 * BGRenderer 每当渲染时广播该事件
		 */
		public var onRender:Function;

		/**
		 * @inheritDoc
		 *
		 */
		override public function onAssetLoadComplete(asset:IAsset):void
		{
			setTexture(_asset.textureAtlas.getTexture(info.textureName));
			isFlipX = info.isFlipX;
			isFlipY = info.isFlipY;

			// 延迟一帧提示 LayerRenderer 需要 flatten
			if (onRender != null)
			{
				addEventListener(Event.ENTER_FRAME, function():void
				{
					onRender();
					removeEventListener(Event.ENTER_FRAME, arguments.callee);
				});
			}

			if (_onAttach)
			{
				_onAttach.dispatch(this);
			}
		}

		private var _isFlipX:Boolean;

		public function get isFlipX():Boolean
		{
			return _isFlipX;
		}

		public function set isFlipX(value:Boolean):void
		{
			_isFlipX = value;

			if (_isFlipX)
			{
				scaleX = -1;
				pivotX = texture.width;
			}
			else
			{
				scaleX = 1;
				pivotX = 0;
			}
		}

		private var _isFlipY:Boolean;

		public function get isFlipY():Boolean
		{
			return _isFlipY;
		}

		public function set isFlipY(value:Boolean):void
		{
			_isFlipY = value;

			if (_isFlipY)
			{
				scaleY = -1;
				pivotY = texture.height;
			}
			else
			{
				scaleY = 1;
				pivotY = 0;
			}
		}

		override public function dispose():void
		{
			info = null;
			onRender = null;
			super.dispose();
		}

		/**
		 * @private
		 */
		override public function set asset(value:TextureAsset):void
		{
			super.asset = value;

			if (!_asset) // 使用空 Texture
			{
				texture = emptyTexture;
			}
		}
	}
}
