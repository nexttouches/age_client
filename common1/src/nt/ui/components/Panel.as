package nt.ui.components
{
	import com.greensock.TweenLite;
	
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import nt.ui.configs.DefaultStyle;
	import nt.ui.containers.SkinnableContainer;
	import nt.ui.core.Component;
	import nt.ui.util.IPopUpClient;
	import nt.ui.util.PopUpManager;

	public class Panel extends SkinnableContainer implements IPopUpClient
	{

		[Skin]
		public var bg:Scale9Image;

		public function Panel(skin:* = null)
		{
			super(skin || DefaultStyle.PanelSkin);
		}

		override protected function render():void
		{
			super.render();

			if (_autoSize)
			{
				bg.width = super.width;
				bg.height = super.height;
			}
		}

		override public function set height(value:Number):void
		{
			bg.height = value;
			super.height = value;
		}

		override public function set width(value:Number):void
		{
			bg.width = value;
			super.width = value;
		}

		private var _draggable:Boolean;

		/**
		 * 设置或获取面板是否是可拖动的<br/>
		 * 请注意：这里的拖拽并没有通过 DnDManager 实现
		 * @return
		 *
		 */
		override public function get isDraggable():Boolean
		{
			return _draggable;
		}

		override public function set isDraggable(value:Boolean):void
		{
			if (value != _draggable)
			{
				_draggable = value;

				if (value)
				{
					bg.onMouseDown.add(bg_mouseDownHandler);
				}
				else
				{
					bg.onMouseDown.remove(bg_mouseDownHandler);
				}
			}
		}

		protected function mouseMoveHandler(event:MouseEvent):void
		{
			event.updateAfterEvent();

			if (_onMove)
			{
				_onMove.dispatch(this);
			}
		}

		protected function bg_mouseDownHandler(target:Component):void
		{
			startDrag(false);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, bg_mouseUpHandler);
			parent.setChildIndex(this, parent.numChildren - 1);
			TweenLite.to(this, .1, { alpha: .5 });
		}

		protected function bg_mouseUpHandler(event:MouseEvent):void
		{
			stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, bg_mouseUpHandler);
			Mouse.cursor = MouseCursor.AUTO;
			TweenLite.to(this, .1, { alpha: 1 });
			dragComplete(null);
		}

		override public function dispose():Boolean
		{
			TweenLite.killTweensOf(this);
			return super.dispose();
		}

		public function close():void
		{
			PopUpManager.remove(this);
		}

		public function get isSlient():Boolean
		{
			return false;
		}

		public function popUp(isCenter:Boolean = true, layer:uint = 0, isModal:Boolean = false):void
		{
			PopUpManager.add(this, isCenter, layer, isModal);
		}
	}
}
