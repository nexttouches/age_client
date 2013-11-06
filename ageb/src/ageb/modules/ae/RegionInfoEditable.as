package ageb.modules.ae
{
	import flash.geom.Vector3D;
	import age.data.RegionInfo;
	import nt.lib.util.assert;
	import org.osflash.signals.Signal;

	public class RegionInfoEditable extends RegionInfo implements ISelectableInfo
	{
		public function RegionInfoEditable(raw:Object = null)
		{
			super(raw);
			_isSelectable = true;
		}

		public var onWidthChange:Signal = new Signal();

		public function setWidth(value:Number):void
		{
			width = value;
			onWidthChange.dispatch();
		}

		public var onHeightChange:Signal = new Signal();

		public function setHeight(value:Number):void
		{
			height = value;
			onHeightChange.dispatch();
		}

		private var _isDragging:Boolean = false;

		public function get isDragging():Boolean
		{
			return _isDragging
		}

		public function set isDragging(value:Boolean):void
		{
			if (value != _isDragging)
			{
				_isDragging = value;

				if (_onIsDraggingChange)
				{
					_onIsDraggingChange.dispatch();
				}
			}
		}

		private var _onIsDraggingChange:Signal;

		public function get onIsDraggingChange():Signal
		{
			return _onIsDraggingChange ||= new Signal();
		}

		private var _onPositionChange:Signal;

		public function get onPositionChange():Signal
		{
			return _onPositionChange ||= new Signal();
		}

		public function moveTo(x:Number, y:Number, z:Number, snapX:Number = 1, snapY:Number = 1, snapZ:Number = 1):void
		{
			this.x = roundTo(x, snapX);
			this.y = roundTo(y, snapY);
			this.z = roundTo(z, snapZ);

			if (_onPositionChange)
			{
				_onPositionChange.dispatch();
			}
		}

		public function moveBy(x:Number, y:Number, z:Number, snapX:Number = 1, snapY:Number = 1, snapZ:Number = 1):void
		{
			moveTo(x + this.x, y + this.y, z + this.z, snapX, snapY, snapZ);
		}

		private var _onIsSelectableChange:Signal;

		public function get onIsSelectableChange():Signal
		{
			return _onIsSelectableChange ||= new Signal;
		}

		private var _isSelectable:Boolean;

		public function get isSelectable():Boolean
		{
			return _isSelectable;
		}

		public function set isSelectable(value:Boolean):void
		{
			_isSelectable = value;

			if (_onIsSelectableChange)
			{
				_onIsSelectableChange.dispatch();
			}
		}

		private var _isSelected:Boolean;

		public function get isSelected():Boolean
		{
			return _isSelected;
		}

		public function set isSelected(value:Boolean):void
		{
			if (value == _isSelected)
			{
				return;
			}
			_isSelected = value;

			if (_onIsSelectedChange)
			{
				_onIsSelectedChange.dispatch();
			}
		}

		private var _onIsSelectedChange:Signal;

		public function get onIsSelectedChange():Signal
		{
			return _onIsSelectedChange ||= new Signal;
		}

		public function clone():ICloneable
		{
			assert(parent != null, "parent 必须不为 null");
			var result:RegionInfoEditable = new RegionInfoEditable(JSON.parse(JSON.stringify(this)));
			// 通过 “当前” 所在 SceneInfo 获得下一个 id
			result.id = SceneInfoEditable(parent).getNextRegionID();
			return result;
		}

		public function get dragRatio():Vector3D
		{
			return DRAG_RATIO;
		}

		private static var DRAG_RATIO:Vector3D = new Vector3D(1, 0, 0);

		override public function toJSON(k:*):*
		{
			// 只需序列化输出 3 个属性
			return { id: id, x: x,
					width: width,
					depth: depth }
		}
	}
}
