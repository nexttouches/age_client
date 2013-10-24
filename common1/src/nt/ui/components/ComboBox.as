package nt.ui.components
{
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import nt.lib.util.DataProvider;
	import nt.ui.core.Component;
	import nt.ui.util.PopUpManager;

	public class ComboBox extends PushButton
	{
		public function ComboBox(skin:* = null)
		{
			super(skin);
			onRemove.add(this_onRemove);
			onClick.add(this_onClick);
			list = new SelectableList();
			list.isNullable = false;
			list.useVScrollBar = true;
			list.onChange.add(list_onChange);
		}

		private function this_onRemove(target:Component):void
		{
			onClickOutside(null);
		}

		protected var list:SelectableList;

		protected var _dataProvider:DataProvider;

		public function get dataProvider():DataProvider
		{
			return _dataProvider;
		}

		public function set dataProvider(value:DataProvider):void
		{
			list.dataProvider = value;
			list.invalidateNow();
		}

		private var _itemClass:Class

		public function get itemClass():Class
		{
			return _itemClass;
		}

		public function set itemClass(value:Class):void
		{
			_itemClass = value;
			list.itemClass = value;
		}

		public function get selectedIndex():int
		{
			return list.selectedIndex;
		}

		public function set selectedIndex(value:int):void
		{
			list.selectedIndex = value;
		}

		public function get selectedData():*
		{
			return list.selectedData;
		}

		public function set selectedData(value:*):void
		{
			list.selectedData = value;
		}

		public function select(key:String, value:*):Boolean
		{
			return list.select(key, value);
		}

		private function this_onClick(target:ComboBox):void
		{
			PopUpManager.add(list, false, 2, false);
			list.width = width;
			list.height = 100;
			var rect:Rectangle = getRect(stage);
			list.x = rect.x;
			list.y = rect.y + height;
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onClickOutside, true, int.MAX_VALUE);
		}

		protected function onClickOutside(event:MouseEvent):void
		{
			if (!event || !list.isInside(stage.mouseX, stage.mouseY))
			{
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, onClickOutside, true);
				removeList();
			}
		}

		private function list_onChange(selectedIndex:int):void
		{
			if (list.selectedData)
			{
				label = list.selectedData.label;
			}
			else
			{
				label = "";
			}
			removeList();
		}

		private function removeList():void
		{
			if (PopUpManager.has(list))
			{
				PopUpManager.remove(list);
			}
		}
	}
}
