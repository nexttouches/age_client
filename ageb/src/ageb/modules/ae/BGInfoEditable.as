package ageb.modules.ae
{
	import flash.geom.Vector3D;
	import age.data.BGInfo;
	import age.data.LayerInfo;
	import nt.lib.reflect.Type;
	import org.osflash.signals.Signal;

	/**
	 * BGInfo 可编辑版本
	 * @author zhanghaocong
	 *
	 */
	public class BGInfoEditable extends BGInfo implements ISelectableInfo
	{
		public static const DEFAULT_EXT:String = ".png";

		/**
		 * BGInfo 在场景中拖拽时的约束
		 */
		private static var DRAG_RATIO:Vector3D = new Vector3D(1, 1, 0);

		/**
		 * constructor
		 *
		 */
		public function BGInfoEditable(raw:Object = null, parent:LayerInfo = null)
		{
			super(raw, parent);
			_isSelectable = true;
			onAtlasChange.add(updateTexture);
			onSrcChange.add(updateTexture);
		}

		private var _isDragging:Boolean = false;

		/**
		 * @inheritDoc
		 *
		 */
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

		/**
		 * @inheritDoc
		 *
		 */
		public function get onIsDraggingChange():Signal
		{
			return _onIsDraggingChange ||= new Signal();
		}

		private var _onPositionChange:Signal;

		/**
		 * @inheritDoc
		 *
		 */
		public function get onPositionChange():Signal
		{
			return _onPositionChange ||= new Signal();
		}

		/**
		 * @inheritDoc
		 *
		 */
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

		/**
		 * @inheritDoc
		 *
		 */
		public function moveBy(x:Number, y:Number, z:Number, snapX:Number = 1, snapY:Number = 1, snapZ:Number = 1):void
		{
			moveTo(x + this.x, y + this.y, z + this.z, snapX, snapY, snapZ);
		}

		private var _onIsSelectableChange:Signal;

		/**
		 * @inheritDoc
		 *
		 */
		public function get onIsSelectableChange():Signal
		{
			return _onIsSelectableChange ||= new Signal;
		}

		private var _isSelectable:Boolean;

		/**
		 * @inheritDoc
		 *
		 */
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

		/**
		 * @inheritDoc
		 *
		 */
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

		/**
		 * @inheritDoc
		 *
		 */
		public function get onIsSelectedChange():Signal
		{
			return _onIsSelectedChange ||= new Signal;
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function get dragRatio():Vector3D
		{
			return DRAG_RATIO;
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function clone():ICloneable
		{
			return new BGInfoEditable(JSON.parse(JSON.stringify(this)));
		}

		/**
		 * isFlipX 变化时广播
		 */
		public var onIsFlipXChange:Signal = new Signal();

		/**
		 * 设置 isFlipX
		 * @param value
		 *
		 */
		public function setIsFlipX(value:Boolean):void
		{
			isFlipX = value;
			onIsFlipXChange.dispatch();
		}

		/**
		 * isFlipY 变化时广播
		 */
		public var onIsFlipYChange:Signal = new Signal();

		/**
		 * 设置是否 y 反转
		 * @param value
		 *
		 */
		public function setIsFlipY(value:Boolean):void
		{
			isFlipY = value;
			onIsFlipYChange.dispatch();
		}

		/**
		 * parent 变化时广播
		 */
		public var onParentChange:Signal = new Signal();

		/**
		 * 设置 parent
		 * @param info
		 *
		 */
		public function setParent(info:LayerInfo):void
		{
			parent = info;
			onParentChange.dispatch();
		}

		/**
		 * atlas 变化时广播
		 */
		public var onAtlasChange:Signal = new Signal;

		private var _atlas:String;

		/**
		 * 设置或获取当前 BGInfo 应被打包到哪个贴图集中
		 */
		public function get atlas():String
		{
			return _atlas;
		}

		/**
		 * @private
		 */
		public function set atlas(value:String):void
		{
			if (_atlas != value)
			{
				_atlas = value;
				onAtlasChange.dispatch();
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function set texture(value:String):void
		{
			super.texture = value;
			_src = textureName;
			_atlas = texturePath;
		}

		/**
		 * src 变化时广播
		 */
		public var onSrcChange:Signal = new Signal;

		private var _src:String;

		/**
		 * 设置或获取 BGInfo 的源文件路径
		 * @return
		 *
		 */
		public function get src():String
		{
			return _src;
		}

		public function set src(value:String):void
		{
			if (_src != value)
			{
				_src = value;
				onSrcChange.dispatch();
			}
		}

		/**
		 * src + .png 后缀
		 * @return
		 *
		 */
		public function get srcWithExt():String
		{
			return _src + DEFAULT_EXT;
		}

		/**
		 * @private
		 *
		 */
		private function updateTexture():void
		{
			texture = _atlas + "#" + _src;
		}

		/**
		 * JSON 序列化时自动调用
		 * @param k
		 * @return
		 *
		 */
		public function toJSON(k:*):Object
		{
			return Type.of(this).superType.toObject(this);
		}
	}
}
