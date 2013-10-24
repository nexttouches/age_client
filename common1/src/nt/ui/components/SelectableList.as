package nt.ui.components
{
	import flash.display.DisplayObject;
	import flash.system.Capabilities;
	import nt.lib.reflect.Type;
	import nt.lib.util.DataProvider;
	import nt.ui.util.ISelectable;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	public class SelectableList extends List
	{
		public var isNullable:Boolean = true;

		public function SelectableList()
		{
			super();
		}

		override public function set itemClass(value:Class):void
		{
			if (Capabilities.isDebugger)
			{
				if (!Type.of(value).isImplementsInterface(ISelectableListItem))
				{
					throw new ArgumentError("itemClass 必须实现 ISelectableListItem");
				}
			}
			super.itemClass = value;
		}

		private var _onChange:ISignal;

		public function get onChange():ISignal
		{
			return _onChange ||= new Signal(int);
		}

		private var _selectedIndex:int = -1;

		override public function set dataProvider(value:DataProvider):void
		{
			_selectedIndex = -1;
			super.dataProvider = value;
		}

		/**
		 * 设或获取当前选中的选项，-1 表示没有选中任何项
		 * @return
		 *
		 */
		public function get selectedIndex():int
		{
			return _selectedIndex;
		}

		public function set selectedIndex(value:int):void
		{
			if (value != _selectedIndex)
			{
				var numItems:int = count(items);

				if (numItems == 0)
				{
					value = -1;
				}
				else if (value >= numItems)
				{
					value = -1
				}

				if (_selectedIndex != -1)
				{
					selectedItem.selected = false;
				}
				_selectedIndex = value;

				if (_selectedIndex != -1)
				{
					selectedItem.selected = true;
				}

				if (_onChange)
				{
					_onChange.dispatch(_selectedIndex);
				}
			}
		}

		protected function updateSelectedIndex(target:ISelectable):void
		{
			if (selectedIndex == target.index)
			{
				if (isNullable)
				{
					selectedIndex = -1;
				}
				else
				{
					// 相当于重复选中
					if (_onChange)
					{
						_onChange.dispatch(_selectedIndex);
					}
				}
			}
			else
			{
				selectedIndex = target.index;
			}
		}

		override internal function createItem(index:int):DisplayObject
		{
			var result:DisplayObject = super.createItem(index);
			ISelectable(result).onClick.add(updateSelectedIndex);
			ISelectable(result).index = index;
			return result;
		}

		override internal function removeItem(index:int):void
		{
			if (items[index] != null)
			{
				ISelectable(items[index]).onClick.remove(updateSelectedIndex);
			}
			super.removeItem(index);
		}

		public function get selectedItem():ISelectableListItem
		{
			if (_selectedIndex == -1)
			{
				return null;
			}
			return items[selectedIndex] as ISelectableListItem;
		}

		public function get selectedData():*
		{
			return selectedItem ? selectedItem.data : null;
		}

		public function set selectedData(value:*):void
		{
			// 这里没有处理翻页，可能会有问题，以后再说
			if (!dataProvider)
			{
				return;
			}
			var n:int = dataProvider.source.length;

			for (var i:int = 0; i < n; i++)
			{
				if (dataProvider.source[i] == value)
				{
					selectedIndex = i;
					return;
				}
			}
		}

		public function select(key:String, value:*):Boolean
		{ // 这里没有处理翻页，可能会有问题，以后再说
			var n:int = dataProvider.source.length;

			for (var i:int = 0; i < n; i++)
			{
				if (dataProvider.source[i][key] == value)
				{
					selectedIndex = i;
					return true;
				}
			}
			return false;
		}

		override protected function dataProvider_onCurrentPageChange(page:int):void
		{
			selectedIndex = -1;
			super.dataProvider_onCurrentPageChange(page);
		}

		override protected function dataProvider_onRemove(index:int):void
		{
			if (index == _selectedIndex)
			{
				if (isNullable || _dataProvider.currentPageContent.length == 0)
				{
					selectedIndex = -1;
				}
				else
				{
					selectedIndex--;
				}
			}
			super.dataProvider_onRemove(index);
		}

		override public function dispose():Boolean
		{
			selectedIndex = -1;
			return super.dispose();
		}
	}
}
