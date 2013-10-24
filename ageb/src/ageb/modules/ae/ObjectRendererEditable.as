package ageb.modules.ae
{
	import mx.controls.Alert;
	import age.assets.ObjectInfo;
	import age.renderers.ObjectRenderer;
	import age.renderers.WireframeLayerRenderer;

	/**
	 * 可编辑的对象渲染器<br>
	 * 为编辑器提供额外 API
	 * @author zhanghaocong
	 *
	 */
	public class ObjectRendererEditable extends ObjectRenderer implements ISelectableRenderer
	{
		/**
		 * 创建一个新的 ObjectRendererEditable
		 *
		 */
		public function ObjectRendererEditable()
		{
			super();
		}

		/**
		 * @inheritDoc
		 * @param value
		 *
		 */
		override public function set info(value:ObjectInfo):void
		{
			if (selectableInfo)
			{
				infoEditable.onPropertiesChange.remove(onPropertiesChange);
				infoEditable.onIsDraggingChange.remove(onIsDraggingChange);
				infoEditable.onIsSelectableChange.remove(onIsSelectableChange);
				infoEditable.onIsSelectedChange.remove(onIsSelectedChange);
				infoEditable.onPositionChange.remove(onPositionChange);
			}
			super.info = value;

			if (selectableInfo)
			{
				infoEditable.onPropertiesChange.add(onPropertiesChange);
				infoEditable.onIsDraggingChange.add(onIsDraggingChange);
				infoEditable.onIsSelectableChange.add(onIsSelectableChange);
				infoEditable.onIsSelectedChange.add(onIsSelectedChange);
				infoEditable.onPositionChange.add(onPositionChange);
				onIsSelectedChange();
			}
		}

		private function onPositionChange():void
		{
			x = _info.position.x;
			y = _info.position.y;
			z = _info.position.z;
		}

		private function onPropertiesChange(trigger:Object = null):void
		{
			onAvatarIDChange();
		}

		override public function validateNow():void
		{
			super.validateNow();
			const avatarID:String = info.avatarID;
			const actionName:String = info.actionName;
			const regionID:int = info.regionID;

			// 显示一些小数据
			if (avatarID && actionName)
			{
				nameRenderer.text = "[" + avatarID + "/" + actionName + "] (" + regionID + ")";
			}
			else
			{
				nameRenderer.text = "[----/----] (--)";
			}
		}

		override protected function get nameRendererClass():Class
		{
			return NameRendererEditable;
		}

		private function onIsDraggingChange():void
		{
			alpha = selectableInfo.isDragging ? 0.5 : 1;
		}

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

		private function onIsSelectableChange():void
		{
			// Do nothing
		}

		/**
		 * 获得 ObjectInfoEditable
		 * @return
		 *
		 */
		public function get infoEditable():ObjectInfoEditable
		{
			return _info as ObjectInfoEditable;
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override protected function get animationLayerRendererClass():Class
		{
			return AnimationLayerRendererEditable;
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override protected function get wireframeLayerRendererClass():Class
		{
			return WireframeLayerRendererEditable;
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		final public function get selectableInfo():ISelectableInfo
		{
			return _info as ISelectableInfo;
		}
	}
}
