package ageb.modules.ae
{
	import age.data.BGInfo;
	import age.data.SceneInfo;
	import age.data.TextureAsset;
	import age.renderers.BGRenderer;
	import nt.assets.IAsset;

	/**
	 * BGRenderer 编辑器版本
	 * @author zhanghaocong
	 *
	 */
	public class BGRendererEditable extends BGRenderer implements ISelectableRenderer
	{
		/**
		 * constructor
		 *
		 */
		public function BGRendererEditable()
		{
			super();
			touchable = true;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function set info(value:BGInfo):void
		{
			if (infoEditable)
			{
				infoEditable.onIsDraggingChange.remove(onIsDraggingChange);
				infoEditable.onPositionChange.remove(onXYChange);
				infoEditable.onIsSelectedChange.remove(onIsSelectedChange);
				infoEditable.onIsFlipXChange.remove(onIsFlipXChange);
				infoEditable.onIsFlipYChange.remove(onIsFlipYChange);
			}
			super.info = value;

			if (infoEditable)
			{
				infoEditable.onIsDraggingChange.add(onIsDraggingChange);
				infoEditable.onPositionChange.add(onXYChange);
				infoEditable.onIsSelectedChange.add(onIsSelectedChange);
				infoEditable.onIsFlipXChange.add(onIsFlipXChange);
				infoEditable.onIsFlipYChange.add(onIsFlipYChange);
				onIsSelectedChange();
				originAlpha = alpha;
			}
		}

		/**
		 * 记录原 alpha
		 */
		private var originAlpha:Number;

		/**
		 * @inheritDoc
		 *
		 */
		override public function set alpha(value:Number):void
		{
			super.alpha = value;
			originAlpha = value;
		}

		/**
		 * @private
		 *
		 */
		private function onIsDraggingChange():void
		{
			super.alpha = originAlpha * (selectableInfo.isDragging ? 0.5 : 1);
		}

		/**
		 * @private
		 *
		 */
		private function onXYChange():void
		{
			setPosition(_info.x, _info.y, _info.z);
		}

		/**
		 * @private
		 *
		 */
		private function onIsFlipXChange():void
		{
			isFlipX = info.isFlipX;
		}

		/**
		 * @private
		 *
		 */
		private function onIsFlipYChange():void
		{
			isFlipY = info.isFlipY;
		}

		/**
		 * @private
		 *
		 */
		private function onIsSelectedChange():void
		{
			if (infoEditable.isSelected)
			{
				color = 0x00ffcc;
			}
			else
			{
				color = 0xffffff;
			}
		}

		/**
		 * @private
		 *
		 */
		final protected function get infoEditable():BGInfoEditable
		{
			return _info as BGInfoEditable;
		}

		/**
		 * @private
		 *
		 */
		final public function get selectableInfo():ISelectableInfo
		{
			return _info as ISelectableInfo;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function getAsset():TextureAsset
		{
			return TextureAsset.get(SceneInfo.folder + "/" + _info.parent.parent.id + "/" + infoEditable.src);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function onAssetLoadComplete(asset:IAsset):void
		{
			setTexture(_asset.texture);
			isFlipX = info.isFlipX;
			isFlipY = info.isFlipY;

			if (_onAttach)
			{
				_onAttach.dispatch(this);
			}
		}
	}
}
