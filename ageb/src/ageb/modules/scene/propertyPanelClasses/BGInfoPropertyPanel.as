package ageb.modules.scene.propertyPanelClasses
{
	import ageb.modules.ae.BGInfoEditable;
	import ageb.modules.ae.ISelectableInfo;
	import ageb.modules.scene.op.ChangeIsFlipX;
	import ageb.modules.scene.op.ChangeIsFlipY;
	import ageb.modules.scene.op.MoveObject;
	import ageb.utils.FlashTip;

	/**
	 * BGInfo 属性面板
	 * @author zhanghaocong
	 *
	 */
	public class BGInfoPropertyPanel extends BGInfoPropertyPanelTemplate
	{
		/**
		 * constructor
		 *
		 */
		public function BGInfoPropertyPanel()
		{
			super();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function resetAllFields():void
		{
			xField.value = 0;
			yField.value = 0;
			atlasField.text = "";
			srcField.text = "";
			parentField.text = "";
			isFlipXField.selected = false;
			isFlipYField.selected = false;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function set infos(value:Vector.<ISelectableInfo>):void
		{
			if (bgInfo)
			{
				bgInfo.onPositionChange.remove(onXYChange);
				bgInfo.onIsFlipXChange.remove(onIsFlipXChange);
				bgInfo.onIsFlipYChange.remove(onIsFlipYChange);
				bgInfo.onParentChange.remove(onParentChange);
				bgInfo.onSrcChange.remove(onSrcChange);
				bgInfo.onAtlasChange.remove(onAtlasChange);
			}
			super.infos = value;

			if (bgInfo)
			{
				bgInfo.onPositionChange.add(onXYChange);
				bgInfo.onIsFlipXChange.add(onIsFlipXChange);
				bgInfo.onIsFlipYChange.add(onIsFlipYChange);
				bgInfo.onParentChange.add(onParentChange);
				bgInfo.onSrcChange.add(onSrcChange);
				bgInfo.onAtlasChange.add(onAtlasChange);
				onXYChange();
				onIsFlipXChange();
				onIsFlipYChange();
				onParentChange();
				onSrcChange();
				onAtlasChange();
			}
		}

		/**
		 * @private
		 *
		 */
		override protected function saveIsFlipX():void
		{
			new ChangeIsFlipX(doc, infos, isFlipXField.selected).execute();
		}

		/**
		 * @private
		 *
		 */
		override protected function saveIsFlipY():void
		{
			new ChangeIsFlipY(doc, infos, isFlipYField.selected).execute();
		}

		/**
		 * @private
		 *
		 */
		override protected function saveParent():void
		{
			FlashTip.show("还没实现");
		}

		/**
		 * @private
		 *
		 */
		override protected function savePosition():void
		{
			// 不允许修改 BG 的 z 轴
			// 这里固定为 0
			const z:Number = 0;
			new MoveObject(doc, infos, xField.value - bgInfo.x, z, yField.value - bgInfo.y).execute();
		}

		/**
		 * @private
		 *
		 */
		override protected function saveTexture():void
		{
			FlashTip.show("还没实现");
		}

		/**
		 * @private
		 *
		 */
		private function onParentChange():void
		{
			parentField.text = bgInfo.layerIndex.toString();
		}

		/**
		 * @private
		 *
		 */
		private function onIsFlipYChange():void
		{
			isFlipXField.selected = bgInfo.isFlipX;
		}

		/**
		 * @private
		 *
		 */
		private function onIsFlipXChange():void
		{
			isFlipYField.selected = bgInfo.isFlipY;
		}

		/**
		 * @private
		 *
		 */
		private function onXYChange():void
		{
			xField.value = bgInfo.x;
			yField.value = bgInfo.y;
		}

		/**
		 * @private
		 *
		 */
		private function onAtlasChange():void
		{
			atlasField.text = bgInfo.atlas;
		}

		/**
		 * @private
		 *
		 */
		private function onSrcChange():void
		{
			srcField.text = bgInfo.srcWithExt;
		}

		/**
		 * @private
		 *
		 */
		final protected function get bgInfo():BGInfoEditable
		{
			return info as BGInfoEditable;
		}
	}
}
