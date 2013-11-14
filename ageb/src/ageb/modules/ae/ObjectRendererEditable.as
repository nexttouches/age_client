package ageb.modules.ae
{
	import age.data.ObjectInfo;
	import age.renderers.ObjectRenderer;

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

		/**
		 * @private
		 *
		 */
		private function onPositionChange():void
		{
			x = _info.position.x;
			y = _info.position.y;
			z = _info.position.z;
		}

		/**
		 * @private
		 *
		 */
		private function onPropertiesChange(trigger:Object = null):void
		{
			onAvatarIDChange();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function validateNow():void
		{
			// 临时变量
			var i:int, n:int, actionInfo:ActionInfoEditable, layer:FrameLayerInfoEditable;
			// 删除该动作的图层列表变更事件
			actionInfo = this.actionInfo as ActionInfoEditable;

			if (actionInfo)
			{
				actionInfo.onLayersChange.remove(onLayersChange);

				for (i = 0, n = actionInfo.numLayers; i < n; i++)
				{
					layer = actionInfo.getLayerAt(i);
					layer.onTypeChange.remove(onTypeChange);
				}
			}
			super.validateNow();

			if (!_info)
			{
				return;
			}
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
			// 添加该动作的图层列表变更事件
			actionInfo = this.actionInfo as ActionInfoEditable;

			if (actionInfo)
			{
				actionInfo.onLayersChange.add(onLayersChange);

				for (i = 0, n = actionInfo.numLayers; i < n; i++)
				{
					layer = actionInfo.getLayerAt(i);
					layer.onTypeChange.add(onTypeChange);
				}
			}
		}

		private function onLayersChange():void
		{
			validateNow();
		}

		private function onTypeChange(... ignored):void
		{
			validateNow();
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override protected function get nameRendererClass():Class
		{
			return NameRendererEditable;
		}

		/**
		 * @private
		 *
		 */
		private function onIsDraggingChange():void
		{
			alpha = selectableInfo.isDragging ? 0.5 : 1;
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
		override protected function get soundLayerRendererClass():Class
		{
			return SoundLayerRendererEditable;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function get particlesLayerRendererClass():Class
		{
			return ParticleLayerRendererEditable;
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
