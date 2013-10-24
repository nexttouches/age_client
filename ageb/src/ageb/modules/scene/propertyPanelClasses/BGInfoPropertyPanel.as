package ageb.modules.scene.propertyPanelClasses
{
	import ageb.modules.ae.BGInfoEditable;
	import ageb.modules.ae.ISelectableInfo;
	import ageb.modules.scene.op.ChangeIsFlipX;
	import ageb.modules.scene.op.ChangeIsFlipY;
	import ageb.modules.scene.op.MoveObject;
	import ageb.utils.FlashTip;

	public class BGInfoPropertyPanel extends BGInfoPropertyPanelTemplate
	{
		public function BGInfoPropertyPanel()
		{
			super();
		}

		override protected function resetAllFields():void
		{
			xField.value = 0;
			yField.value = 0;
			textureField.text = "";
			parentField.text = "";
			isFlipXField.selected = false;
			isFlipYField.selected = false;
		}

		override public function set infos(value:Vector.<ISelectableInfo>):void
		{
			if (bgInfo)
			{
				bgInfo.onPositionChange.remove(onXYChange);
				bgInfo.onTextureChange.remove(onTextureChange);
				bgInfo.onIsFlipXChange.remove(onIsFlipXChange);
				bgInfo.onIsFlipYChange.remove(onIsFlipYChange);
				bgInfo.onParentChange.remove(onParentChange);
			}
			super.infos = value;

			if (bgInfo)
			{
				bgInfo.onPositionChange.add(onXYChange);
				bgInfo.onTextureChange.add(onTextureChange);
				bgInfo.onIsFlipXChange.add(onIsFlipXChange);
				bgInfo.onIsFlipYChange.add(onIsFlipYChange);
				bgInfo.onParentChange.add(onParentChange);
				onXYChange();
				onTextureChange();
				onIsFlipXChange();
				onIsFlipYChange();
				onParentChange();
			}
		}

		override protected function saveIsFlipX():void
		{
			new ChangeIsFlipX(doc, infos, isFlipXField.selected).execute();
		}

		override protected function saveIsFlipY():void
		{
			new ChangeIsFlipY(doc, infos, isFlipYField.selected).execute();
		}

		override protected function saveParent():void
		{
			FlashTip.show("还没实现");
		}

		override protected function savePosition():void
		{
			// 不允许修改 BG 的 z 轴
			// 这里固定为 0
			const z:Number = 0;
			new MoveObject(doc, infos, xField.value - bgInfo.x, z, yField.value - bgInfo.y).execute();
		}

		override protected function saveTexture():void
		{
			FlashTip.show("还没实现");
		}

		private function onParentChange():void
		{
			parentField.text = bgInfo.layerIndex.toString();
		}

		private function onIsFlipYChange():void
		{
			isFlipXField.selected = bgInfo.isFlipX;
		}

		private function onIsFlipXChange():void
		{
			isFlipYField.selected = bgInfo.isFlipY;
		}

		private function onXYChange():void
		{
			xField.value = bgInfo.x;
			yField.value = bgInfo.y;
		}

		private function onTextureChange():void
		{
			textureField.text = bgInfo.texture;
		}

		final protected function get bgInfo():BGInfoEditable
		{
			return info as BGInfoEditable;
		}
	}
}
