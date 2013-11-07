package ageb.modules.ae
{
	import flash.geom.Vector3D;
	import age.data.Box;
	import age.data.FrameInfo;
	import org.osflash.signals.Signal;

	/**
	 * FrameInfoEditable 的可编辑版本
	 * @author zhanghaocong
	 *
	 */
	public class FrameInfoEditable extends FrameInfo implements ISelectableInfo
	{
		/**
		 * 只允许 xy 方向拖拽
		 */
		private static const DRAG_RATIO:Vector3D = new Vector3D(1, 1, 0);

		/**
		 * 创建一个新的 FrameInfoEditable
		 * @param raw
		 *
		 */
		public function FrameInfoEditable(raw:Object = null)
		{
			super(raw);
			// TODO 日后开启拖拽支持
			_isSelectable = false;
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		public function clone():ICloneable
		{
			return new FrameInfoEditable(JSON.parse(JSON.stringify(this)));
		}

		/**
		 * @inheritDoc
		 * @param texture
		 *
		 */
		override protected function parseTexture(texture:String):void
		{
			if (texture)
			{
				texture = texture.replace("#", "/");
				texture = texture.replace("_", "/");
				texturePath = texture;
				textureName = "";
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function parseSound(sound:String):void
		{
			if (sound)
			{
				soundPath = sound.replace(/_/g, "/") + ".mp3";
			}
		}

		private var _isDragging:Boolean = false;

		/**
		 * @inheritDoc
		 * @return
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
		 * @return
		 *
		 */
		public function get onIsDraggingChange():Signal
		{
			return _onIsDraggingChange ||= new Signal();
		}

		private var _onPositionChange:Signal;

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		public function get onPositionChange():Signal
		{
			return _onPositionChange ||= new Signal();
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		public function moveTo(x:Number, y:Number, z:Number, snapX:Number = 1, snapY:Number = 1, snapZ:Number = 1):void
		{
			box.x = roundTo(x, snapX);
			box.y = roundTo(y, snapY);
			box.z = roundTo(z, snapZ);

			if (_onPositionChange)
			{
				_onPositionChange.dispatch();
			}
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		public function moveBy(x:Number, y:Number, z:Number, snapX:Number = 1, snapY:Number = 1, snapZ:Number = 1):void
		{
			moveTo(x + box.x, y + box.y, z + box.z, snapX, snapY, snapZ);
		}

		private var _onIsSelectableChange:Signal;

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		public function get onIsSelectableChange():Signal
		{
			return _onIsSelectableChange ||= new Signal;
		}

		private var _isSelectable:Boolean;

		/**
		 * @inheritDoc
		 * @return
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
		 * @return
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
		 * @return
		 *
		 */
		public function get onIsSelectedChange():Signal
		{
			return _onIsSelectedChange ||= new Signal;
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		public function get dragRatio():Vector3D
		{
			return DRAG_RATIO;
		}

		/**
		 * box 变化时广播
		 */
		public var onBoxChange:Signal = new Signal();

		/**
		 * 设置 Box
		 * @param box
		 *
		 */
		public function setBox(box:Box):void
		{
			this.box = box;
			onBoxChange.dispatch();
		}

		/**
		 * isKeyframe 变化时广播
		 * @return
		 *
		 */
		public var onIsKeyframeChange:Signal = new Signal();

		/**
		 * 设置是否是关键帧
		 * @param value
		 *
		 */
		public function setIsKeyframe(value:Boolean):void
		{
			// 第一帧必须是关键帧
			if (!value && isHead)
			{
				return;
			}

			if (isKeyframe != value)
			{
				isKeyframe = value;
				onIsKeyframeChange.dispatch();
			}
		}

		/**
		 * 当前帧关键帧的 FrameInfoEditable 类型
		 * @return
		 *
		 */
		public function get keyframeEditable():FrameInfoEditable
		{
			return keyframe as FrameInfoEditable;
		}
	}
}
