package ageb.modules.scene.propertyPanelClasses
{
	import spark.components.ComboBox;

	public class AutoCompleteDropdown extends ComboBox
	{
		public function AutoCompleteDropdown()
		{
			super();
			labelField = "label";
			labelToItemFunction = labelToItem;
		}

		private function labelToItem(label:String):Object
		{
			for (var i:int = dataProvider.length - 1; i >= 0; i--)
			{
				var item:Object = dataProvider.getItemAt(i);

				if (item.label == label)
				{
					return item;
				}
			}
			return selectedItem;
		}

		public function get selectedData():*
		{
			return selectedItem ? selectedItem.data : null;
		}

		public function set selectedData(data:*):void
		{
			if (data === null || data === undefined)
			{
				selectedIndex = -1;
				return;
			}

			for (var i:int = dataProvider.length - 1; i >= 0; i--)
			{
				var item:Object = dataProvider.getItemAt(i);

				if (item.data == data)
				{
					selectedItem = item;
					return;
				}
			}
			selectedItem = undefined;
		}
	}
}
