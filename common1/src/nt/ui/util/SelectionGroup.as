package nt.ui.util
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import nt.lib.util.IDisposable;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	/**
	 * SelectionGroup 表示一组选区，比如可以用在一组 RadioButton 上
	 * @author KK
	 *
	 */
	dynamic public class SelectionGroup extends Array implements IDisposable
	{
		public function SelectionGroup()
		{
		}

		private var _onChange:ISignal;

		public function get onChange():ISignal
		{
			return _onChange ||= new Signal(int);;
		}

		private var _selectedIndex:int = -1;

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
				if (value >= length)
				{
					throw new Error("越界了");
				}
				_selectedIndex = value;
				var n:int = length;

				for (var i:int = 0; i < n; i++)
				{
					var item:ISelectable = this[i];
					item.selected = item.index == i;
				}

				if (_onChange)
				{
					_onChange.dispatch(_selectedIndex);
				}
			}
		}

		protected function updateSelectedIndex(target:ISelectable):void
		{
			selectedIndex = target.index;
		}

		/**
		 * 获取当前选中的 ISelectable<br/>
		 * @return
		 *
		 */
		public function get selectedItem():ISelectable
		{
			return this[selectedIndex];
		}

		public function concat(... parameters):Array
		{
			throw new Error("不支持");
			return null;
		}

		public function pop():*
		{
			var result:ISelectable = super.pop();
			result.onClick.remove(updateSelectedIndex);
			return result;
		}

		public function push(... parameters):uint
		{
			for each (var item:ISelectable in parameters)
			{
				item.onClick.add(updateSelectedIndex);
			}
			return super.push(parameters);
		}

		public function shift():*
		{
			var result:ISelectable = super.shift();
			result.onClick.remove(updateSelectedIndex);
			return result;
		}

		public function splice(... parameters):*
		{
			var result:Array = super.splice(parameters);

			for each (var item:ISelectable in result)
			{
				item.onClick.remove(updateSelectedIndex);
			}
			return result;
		}

		public function unshift(... parameters):uint
		{
			for each (var item:ISelectable in parameters)
			{
				item.onClick.remove(updateSelectedIndex);
			}
			return super.unshift(parameters);
		}

		private var _disposed:Boolean;

		public function get isDisposed():Boolean
		{
			return _disposed;
		}

		public function dispose():Boolean
		{
			while (length)
			{
				pop();
			}

			if (_onDispose)
			{
				_onDispose.dispatch(this);
			}
			return _disposed = true;
		}

		private var _onDispose:ISignal;

		public function get onDispose():ISignal
		{
			return _onDispose ||= new Signal(SelectionGroup);
		}
	}
}
