package nt.ui.util
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import org.osflash.signals.Signal;

	final public class PopUpManager
	{
		private static const NumLayerMax:uint = 8;

		/**
		 * PopUp 层，最多 8 个
		 */
		private static var layers:Vector.<DisplayObjectContainer> = new Vector.<DisplayObjectContainer>(NumLayerMax, true);

		public static function registerLayer(index:uint, container:DisplayObjectContainer):void
		{
			layers[index] = container;
		}

		public static var onAdd:Signal = new Signal(DisplayObject);

		public static var onRemove:Signal = new Signal(DisplayObject);

		private static var modals:Dictionary = new Dictionary();

		/**
		 * key = DisplayObject
		 * value = layer index
		 */
		private static var popUps:Dictionary = new Dictionary();

		public static function add(object:DisplayObject, isCenter:Boolean = true, layer:uint = 0, isModal:Boolean = false):void
		{
			if (!layers[layer])
			{
				throw new Error(format("layer {0} 没有注册", layer));
			}
			popUps[object] = layer;

			// 先添加 modal
			if (isModal)
			{
				addModal(object, layer);
			}
			// 必须使用 PopUpManager.remove 方法移除添加了的 popUps
			object.addEventListener(Event.REMOVED_FROM_STAGE, onRemoveLock, false, int.MAX_VALUE);

			// 居中处理
			if (isCenter)
			{
				object.addEventListener(Event.ADDED_TO_STAGE, doCenter);
			}

			if (!(object is IPopUpClient) || !IPopUpClient(object).isSlient)
			{
				object.addEventListener(Event.ADDED_TO_STAGE, fireOnAdd);
			}
			// 添加到指定层
			layers[layer].addChild(object);
		}

		protected static function fireOnAdd(event:Event):void
		{
			event.currentTarget.removeEventListener(event.type, fireOnAdd);
			onAdd.dispatch(event.currentTarget);
		}

		protected static function doCenter(event:Event):void
		{
			var object:DisplayObject = event.currentTarget as DisplayObject;
			object.removeEventListener(event.type, doCenter);
			object.x = (object.stage.stageWidth - object.width) >> 1;
			object.y = (object.stage.stageHeight - object.height) >> 1;
		}

		protected static function onRemoveLock(event:Event):void
		{
			throw new IllegalOperationError(format("请使用 PopUpManager.remove 来删除该 PopUp：{0}", event.currentTarget));
		}

		public static function remove(object:DisplayObject):void
		{
			if (!(object in popUps))
			{
				throw new ArgumentError(format("指定的对象 {0} 并不在 popUps 中", object));
			}

			if (!(object is IPopUpClient) || !IPopUpClient(object).isSlient)
			{
				object.addEventListener(Event.REMOVED_FROM_STAGE, fireOnRemove);
			}

			// 先删 modal
			if (object in modals)
			{
				removeModal(object);
			}
			// 解锁
			object.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveLock);
			// 最后从指定层上删除
			layers[popUps[object]].removeChild(object);
			delete popUps[object];
		}

		protected static function fireOnRemove(event:Event):void
		{
			event.currentTarget.removeEventListener(event.type, fireOnRemove);
			onRemove.dispatch(event.currentTarget);
		}

		public static function has(object:DisplayObject):Boolean
		{
			return object in popUps;
		}

		private static function addModal(popUp:DisplayObject, layer:uint):void
		{
			if (popUp in modals)
			{
				throw new ArgumentError(format("指定的 popUp: {0} 已经有 modal", popUp));
			}
			var m:Modal = new Modal();
			m.relatedPopUp = popUp;
			modals[popUp] = m;
			layers[layer].addChild(m);
		}

		private static function removeModal(popUp:DisplayObject):void
		{
			if (!(popUp in modals))
			{
				throw new ArgumentError(format("指定的 popUp: {0} 没有 modal", popUp));
			}
			var m:Modal = modals[popUp];
			delete modals[popUp];

			if (!popUp.parent)
			{
				throw new ArgumentError(format("指定的 popUp: {0} 没有 parent", popUp));
			}
			layers[popUps[popUp]].removeChild(m);
		}
	}
}

/**
 * Modal 颜色
 */
const ModalColor:uint = 0;

/**
 * Modal 透明度
 */
const ModalAlpha:Number = .5;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

/**
 * 因为底下还有 stage3D 内容，不得不使用老土的办法处理遮盖
 * @author KK
 *
 */
final class Modal extends Sprite
{
	public var relatedPopUp:DisplayObject;

	public function Modal()
	{
		super();
		mouseChildren = false;
		addEventListener(Event.ADDED_TO_STAGE, onAdd);
		addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
		addEventListener(MouseEvent.MOUSE_DOWN, hintRelatedPopUp);
		addEventListener(MouseEvent.MOUSE_DOWN, killEvents);
		addEventListener(MouseEvent.MOUSE_UP, killEvents);
		addEventListener(MouseEvent.CLICK, killEvents);
	}

	private function hintRelatedPopUp(event:Event):void
	{
		trace("[Modal]", relatedPopUp);
	}

	private function killEvents(event:Event):void
	{
		event.stopPropagation();
		event.stopImmediatePropagation();
		event.preventDefault();
	}

	private function onAdd(event:Event):void
	{
		if (!relatedPopUp)
		{
			throw new Error("缺少 relatedPopUp");
		}
		draw(event);
		stage.addEventListener(Event.RESIZE, draw);
	}

	private function onRemove(event:Event):void
	{
		if (!relatedPopUp)
		{
			throw new Error("缺少 relatedPopUp");
		}
		stage.removeEventListener(Event.RESIZE, draw);
		// 只要被删过一次，该 Modal 就失效了
		relatedPopUp = null;
	}

	private function draw(event:Event):void
	{
		graphics.clear();
		graphics.beginFill(ModalColor, ModalAlpha);
		graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
		graphics.endFill();
	}
}
