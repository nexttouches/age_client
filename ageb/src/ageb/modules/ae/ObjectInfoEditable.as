package ageb.modules.ae
{
	import flash.geom.Vector3D;
	import age.data.LayerInfo;
	import age.data.ObjectInfo;
	import org.osflash.signals.Signal;

	/**
	 * 可编辑的 ObjectInfo，实现了 ISelectableInfo
	 * @author zhanghaocong
	 *
	 */
	public class ObjectInfoEditable extends ObjectInfo implements ISelectableInfo
	{
		/**
		 * 创建一个新的 ObjectInfoEditable
		 * @param raw
		 * @param parent
		 *
		 */
		public function ObjectInfoEditable(raw:Object = null, parent:LayerInfo = null)
		{
			super(raw, parent);
			_isSelectable = true;
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

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		public function moveTo(x:Number, y:Number, z:Number, snapX:Number = 1, snapY:Number = 1, snapZ:Number = 1):void
		{
			position.setTo(roundTo(x, snapX), roundTo(y, snapY), roundTo(z, snapZ));

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
			// ×2 为了快速移动
			moveTo(x + position.x, y + position.y, z * 2 + position.z, snapX, snapY, snapZ);
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

		/**
		 * @inheritDoc
		 *
		 */
		override public function set actionName(value:String):void
		{
			if (actionInfoEditable)
			{
				actionInfoEditable.onFPSChange.remove(onFPSChange);
				actionInfoEditable.onNumFramesChange.remove(onNumFramesChange);
				actionInfoEditable.onLayersChange.remove(onActionNameChange.dispatch);
			}
			super.actionName = value;

			if (actionInfoEditable)
			{
				actionInfoEditable.onFPSChange.add(onFPSChange);
				actionInfoEditable.onNumFramesChange.add(onNumFramesChange);
				actionInfoEditable.onLayersChange.add(onActionNameChange.dispatch);
			}
		}

		/**
		 * @private
		 *
		 */
		protected function get actionInfoEditable():ActionInfoEditable
		{
			return actionInfo as ActionInfoEditable;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function set avatarID(value:String):void
		{
			if (avatarInfoEditable)
			{
				avatarInfoEditable.onSizeChange.remove(super.validateNow);
				avatarInfoEditable.onSizeChange.remove(onAvatarIDChange.dispatch);
			}
			// 设置前同步加载 avatar 信息
			SyncInfoLoader.loadAvatar(value);
			super.avatarID = value;

			if (avatarInfoEditable)
			{
				avatarInfoEditable.onSizeChange.add(super.validateNow);
				avatarInfoEditable.onSizeChange.add(onAvatarIDChange.dispatch);
			}
		}

		/**
		 * @private
		 *
		 */
		protected function get avatarInfoEditable():AvatarInfoEditable
		{
			return avatarInfo as AvatarInfoEditable;
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
		 * 属性发生变化时广播<br>
		 * 正确的签名是 function (trigger:Object);<br>
		 * 其中 trigger 用于识别由哪个对象触发了该事件
		 */
		public var onPropertiesChange:Signal = new Signal(Object);

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
		 * 拖拽时的比率<br>
		 * 这里 y 设置成 0，表示不可上下拖拽
		 */
		private static var DRAG_RATIO:Vector3D = new Vector3D(1, 0, 1);

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		public function clone():ICloneable
		{
			return new ObjectInfoEditable(JSON.parse(JSON.stringify(this)));
		}

		/**
		 * @private
		 *
		 */
		private function onNumFramesChange():void
		{
			// 更新后，需要保留播放头
			const cf:int = currentFrame;
			updateDurations();
			currentFrame = cf < numFrames ? cf : numFrames - 1;
		}

		/**
		 * @private
		 *
		 */
		private function onFPSChange():void
		{
			fps = actionInfo.fps;
		}
	}
}
