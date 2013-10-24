package ageb.modules.scene.propertyPanelClasses
{
	import ageb.modules.ae.ISelectableInfo;
	import ageb.modules.ae.RegionInfoEditable;
	import ageb.modules.scene.op.ChangeRegionHeight;
	import ageb.modules.scene.op.ChangeRegionWidth;
	import ageb.modules.scene.op.MoveObject;

	public class RegionInfoPropertyPanel extends RegionInfoPropertyPanelTemplate
	{
		public function RegionInfoPropertyPanel()
		{
			super();
		}

		override protected function resetAllFields():void
		{
			xField.value = NaN;
			yField.value = NaN;
			widthField.value = NaN;
			heightField.value = NaN;
		}

		override public function set infos(value:Vector.<ISelectableInfo>):void
		{
			if (regionInfo)
			{
				regionInfo.onPositionChange.remove(onXYChange);
				regionInfo.onWidthChange.remove(onWidthChange);
				regionInfo.onHeightChange.remove(onHeightChange);
			}
			super.infos = value;

			if (regionInfo)
			{
				regionInfo.onPositionChange.add(onXYChange);
				regionInfo.onWidthChange.add(onWidthChange);
				regionInfo.onHeightChange.add(onHeightChange);
				onXYChange();
				onWidthChange();
				onHeightChange();
			}
		}

		private function onHeightChange():void
		{
			heightField.value = regionInfo.height;
		}

		private function onWidthChange():void
		{
			widthField.value = regionInfo.width;
		}

		override protected function saveHeight():void
		{
			new ChangeRegionHeight(doc, infos, heightField.value).execute();
		}

		override protected function saveWidth():void
		{
			new ChangeRegionWidth(doc, infos, widthField.value).execute();
		}

		private function onXYChange():void
		{
			xField.value = regionInfo.x;
			yField.value = regionInfo.y;
		}

		override protected function savePosition():void
		{
			// 不允许修改 BG 的 y, z 轴
			// 这里固定为 0
			const y:Number = 0;
			const z:Number = 0;
			new MoveObject(doc, infos, xField.value - regionInfo.x, y, z).execute();
		}

		final protected function get regionInfo():RegionInfoEditable
		{
			return info as RegionInfoEditable;
		}
	}
}
