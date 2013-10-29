package age.renderers
{
	import age.AGE;
	import age.assets.BGInfo;
	import age.assets.SceneInfo;
	import age.assets.TextureAsset;
	import age.filters.WaveFilter;
	import nt.assets.IAsset;
	import starling.events.Event;

	/**
	 * BGRenderer 是基于 BaseRenderer 的基本渲染器<br/>
	 * 用于渲染场景背景图片
	 * @author zhanghaocong
	 *
	 */
	public class BGRenderer extends TextureRenderer
	{
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
				asset = TextureAsset.get(SceneInfo.folder + "/" + _info.texturePath);
				asset.useThumb = false;
				asset.load();
			}
		}

		public var onRender:Function;

		override public function onAssetLoadComplete(asset:IAsset):void
		{
			setTexture(_asset.textureAtlas.getTexture(info.textureName));
			// filter = new WaveFilter(width, height, AGE.renderJuggler);
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
