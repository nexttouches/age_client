package nt.ui.components.listitemclasses
{
	import nt.ui.components.ISelectableListItem;
	import nt.ui.components.Label;
	import nt.ui.containers.HBox;
	import nt.ui.core.Component;
	import nt.ui.core.Container;
	import nt.ui.util.ISelectable;
	import nt.ui.util.LayoutParser;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	public class LabelListItem extends Container implements ISelectableListItem
	{
		private var hBox:HBox;

		private var bg:Bg;

		public function LabelListItem()
		{
			super();
			addChild(bg = new Bg);
			addChild(hBox = LayoutParser.parse(layout) as HBox);
			width = 100;
			height = 20;
			bg.width = width;
			bg.height = height;
			onClick.add(toggle);
		}

		override public function set width(value:Number):void
		{
			if (hBox)
			{
				hBox.width = value;
				bg.width = value;
			}
			super.width = value;
		}

		public function toggle(target:Component = null):void
		{
			selected = !_selected;
		}

		private var _onSelectedChange:ISignal;

		public function get onSelectedChange():ISignal
		{
			return _onSelectedChange ||= new Signal(ISelectable, Boolean);
		}

		private var _index:int;

		public function get index():int
		{
			return _index;
		}

		public function set index(value:int):void
		{
			_index = value;
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
			invalidate();

			if (_onSelectedChange)
			{
				_onSelectedChange.dispatch(this, _selected);
			}
		}

		override public function dispose():Boolean
		{
			_data = null;

			if (_onSelectedChange)
			{
				_onSelectedChange.removeAll();
			}
			return super.dispose();
		}

		protected var _data:Object;

		public function get data():*
		{
			return _data;
		}

		public function set data(value:*):void
		{
			_data = value;
			invalidate();
		}

		override protected function render():void
		{
			if (_data)
			{
				Label(hBox.get("label")).text = _data.label;
			}
			else
			{
				Label(hBox.get("label")).text = "";
			}

			if (_selected)
			{
				bg.color = 0x00ff00;
			}
			else
			{
				bg.color = 0x009933;
			}
			super.render();
		}

		public function get layout():XML
		{
			return LAYOUT;
		}
	}
}
import nt.ui.core.Component;

class Bg extends Component
{
	public function Bg()
	{
		super();
		mouseChildren = false;
	}

	private var _color:uint;

	public function get color():uint
	{
		return _color;
	}

	public function set color(value:uint):void
	{
		_color = value;
		invalidate();
	}

	override protected function render():void
	{
		super.render();
		graphics.clear();
		graphics.beginFill(color, 1);
		graphics.drawRect(0, 0, _width, _height);
		graphics.endFill();
	}
}

const LAYOUT:XML = <HBox y="3" height="20">
		<Label id="label" />
	</HBox>;
