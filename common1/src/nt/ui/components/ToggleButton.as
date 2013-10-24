package nt.ui.components
{
	import flash.errors.IllegalOperationError;
	import flash.events.MouseEvent;
	import nt.ui.core.Component;
	import nt.ui.util.ISelectable;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	public class ToggleButton extends PushButton implements ISelectable
	{
		public function ToggleButton(skin:* = null)
		{
			super(skin);
			onClick.add(toggle);
		}

		public function toggle(target:Component = null):void
		{
			selected = !selected;
		}

		private var _onSelectedChange:ISignal;

		public function get onSelectedChange():ISignal
		{
			return _onSelectedChange ||= new Signal(ISelectable, Boolean);
		}

		public function get index():int
		{
			throw new IllegalOperationError("ToggleButton 本身尚未实现 index");
			return 0;
		}

		public function set index(value:int):void
		{
			throw new IllegalOperationError("ToggleButton 本身尚未实现 index");
		}

		protected var _selectable:Boolean;

		public function get selectable():Boolean
		{
			return _selectable;
		}

		public function set selectable(value:Boolean):void
		{
			_selectable = value;
		}

		protected var _selected:Boolean;

		public function get selected():Boolean
		{
			return _selected;
		}

		public function set selected(value:Boolean):void
		{
			_selected = value;

			if (_selected)
			{
				state = PushButtonState.DOWN;
			}
			else
			{
				state = PushButtonState.UP;
			}
			invalidate();

			if (_onSelectedChange)
			{
				_onSelectedChange.dispatch(this, _selected);
			}
		}

		override public function dispose():Boolean
		{
			if (_onSelectedChange)
			{
				_onSelectedChange.removeAll();
			}
			return super.dispose();
		}
	}
}
