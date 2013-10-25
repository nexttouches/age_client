package ageb.modules.ae
{
	import flash.geom.Vector3D;
	import age.assets.LayerInfo;
	import age.assets.ObjectInfo;
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
		 * @inheritDoc
		 *
		 */
		override public function validateNow():void
		{
			var avatar:AvatarInfoEditable, action:ActionInfoEditable;

			try
			{
				avatar = avatarInfo as AvatarInfoEditable;
				action = actionInfo as ActionInfoEditable;
			}
			catch (error:Error)
			{
				// ignored
			}

			// 删除侦听
			if (avatar)
			{
				avatar.onSizeChange.remove(onAvatarIDChange.dispatch);
				avatar.onSizeChange.remove(super.validateNow);
			}

			if (action)
			{
				action.onFPSChange.remove(onFPSChange);
				action.onNumFramesChange.remove(onNumFramesChange);
				action.onLayersChange.remove(onActionNameChange.dispatch);
			}
			// 验证前使用同步的方式把 avatar 元数据载进来
			// 如果有任何错误，将弹出 Alert
			SyncInfoLoader.loadAvatar(avatarID);
			super.validateNow();
			// 添加侦听
			avatar = avatarInfo as AvatarInfoEditable

			if (avatar)
			{
				avatar.onSizeChange.add(super.validateNow);
				avatar.onSizeChange.add(onAvatarIDChange.dispatch);
			}

			if (action)
			{
				action.onFPSChange.add(onFPSChange);
				action.onNumFramesChange.add(onNumFramesChange);
				action.onLayersChange.add(onActionNameChange.dispatch);
			}
		}

		/**
		 * @private
		 *
		 */
		private function onNumFramesChange():void
		{
			// 更新后，需要保留播放头
			const cf:int = currentFrame;
			updateDurations(actionInfo);
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
