package ageb.modules.ae
{
	import flash.geom.Vector3D;
	import age.assets.BGInfo;
	import age.assets.LayerInfo;
	import nt.lib.reflect.Type;
	import org.osflash.signals.Signal;

	public class BGInfoEditable extends BGInfo implements ISelectableInfo
	{
		public function BGInfoEditable(raw:Object = null, parent:LayerInfo = null)
		{
			super(raw, parent);
			_isSelectable = true;
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

		public function get dragRatio():Vector3D
		{
			return DRAG_RATIO;
		}

		private static var DRAG_RATIO:Vector3D = new Vector3D(1, 1, 0);

		public function clone():ICloneable
		{
			return new BGInfoEditable(JSON.parse(JSON.stringify(this)));
		}

		public var onIsFlipXChange:Signal = new Signal();

		public function setIsFlipX(value:Boolean):void
		{
			isFlipX = value;
			onIsFlipXChange.dispatch();
		}

		public var onIsFlipYChange:Signal = new Signal();

		public function setIsFlipY(value:Boolean):void
		{
			isFlipY = value;
			onIsFlipYChange.dispatch();
		}

		public var onParentChange:Signal = new Signal();

		public function setParent(info:LayerInfo):void
		{
			parent = info;
			onParentChange.dispatch();
		}

		public function toJSON(k:*):*
		{
			return Type.of(this).superType.toObject(this, [ "textureName", "texturePath",
															"parent" ]);
		}
	}
}
