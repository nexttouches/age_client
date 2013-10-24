package nt.ui.dnd
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class DnDManager
	{
		/**
		 * 共享了的 point
		 */
		private static var point:Point = new Point();

		/**
		 * 共享了的 dropList
		 */
		private static var dropList:Array = [];

		public static var container:DisplayObjectContainer;

		/**
		 * ref
		 */
		private static var stage:Stage;

		/**
		 * 当前允许放下的对象
		 */
		private static var target:IDroppable;

		/**
		 * 共享了的 dragInfo
		 */
		private static var info:DragInfo = new DragInfo();

		public static function starDrag(source:IDraggable):void
		{
			if (!container)
			{
				throw new Error("container 尚未设置");
			}

			if (!stage)
			{
				stage = container.stage;
			}

			if (source.isDraggable)
			{
				if (info.isDisposed)
				{
					info.renew();
				}
				info.source = source;
				info.phase = DragPhase.Ready;
				info.mouseOffsetX = source.mouseX;
				info.mouseOffsetY = source.mouseY;
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseStartMove);
				doInstantMouseUpCheck();
			}
		}

		private static function onStageMouseStartMove(event:MouseEvent):void
		{
			if (event.buttonDown)
			{
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
				stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown, true);
				stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp, true);
				finishInstantMouseUpCheck();
				info.thumb.draw(info.source);
				container.addChild(info.thumb);
				info.phase = DragPhase.Start;
			}
		}

		private static function doInstantMouseUpCheck():void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, instantMouseUpHandler);
		}

		private static function instantMouseUpHandler(event:MouseEvent):void
		{
			finishInstantMouseUpCheck();
		}

		private static function finishInstantMouseUpCheck():void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseStartMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, instantMouseUpHandler);
		}

		private static function onStageMouseDown(event:MouseEvent):void
		{
			if (info.source != null)
			{
				//for sometimes, the event.buttonDown was not the correct value
				//if source was not null, we treat mouse down as the mouse up behavior
				onStageMouseUp(event);
			}
		}

		private static function onStageMouseMove(event:MouseEvent):void
		{
			if (!event.buttonDown)
			{
				return;
			}
			event.updateAfterEvent();
			point.x = stage.mouseX;
			point.y = stage.mouseY;
			dropList.length = 0;
			getObjectsUnderPoint(container.parent, point, dropList);
			var newTarget:IDroppable;

			if (dropList.length > 0)
			{
				newTarget = dropList[dropList.length - 1];
			}

			//trace(target, newTarget);
			if (target != newTarget)
			{
				// 一共分 3 步
				// 首先是原 target.dragExit
				if (target != null)
				{
					info.phase = DragPhase.Exit;
					target.dragExit(info);

					if (target == info.target)
					{
						info.target = null;
					}
				}
				// 更换 target 到 newTarget
				target = newTarget;

				// 此时 target == newTarget，调用 dragEnter
				if (target != null)
				{
					info.phase = DragPhase.Enter;

					if (target.dragEnter(info))
					{
						info.target = target;
					}
				}
			}
		}

		private static function getObjectsUnderPoint(obj:DisplayObject, pt:Point, result:Array):void
		{
			if (obj.hitTestPoint(pt.x, pt.y))
			{
				if (obj is IDroppable && IDroppable(obj).isDroppable)
				{
					result.push(obj);
				}

				if (obj is DisplayObjectContainer)
				{
					var container:DisplayObjectContainer = DisplayObjectContainer(obj);

					for (var i:int = container.numChildren - 1; i >= 0; i--)
					{
						getObjectsUnderPoint(container.getChildAt(i), pt, result);
					}
				}
			}
		}

		private static function onStageMouseUp(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown, true);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp, true);

			if (info.target != null)
			{
				doDrop();
			}
			else
			{
				doDropOutside();
			}
			clearDrag();
		}

		private static function clearDrag():void
		{
			dropList.length = 0;
			info.dispose();
			container.removeChild(info.thumb);
			target = null;
		}

		private static function doDrop():void
		{
			info.phase = DragPhase.Drop;
			info.target.dragDrop(info);
			info.phase = DragPhase.Complete;
			info.source.dragComplete(info);
		}

		private static function doDropOutside():void
		{
			info.phase = DragPhase.Drop;
			info.source.dragDropOutSide(info);
			info.phase = DragPhase.Complete;
			info.source.dragComplete(info);
		}
	}
}
