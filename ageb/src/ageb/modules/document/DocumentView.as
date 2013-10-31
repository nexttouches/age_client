package ageb.modules.document
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.getTimer;
	import spark.components.Group;
	import age.AGE;
	import age.renderers.Camera2D;
	import ageb.modules.Modules;
	import ageb.modules.ae.SceneRendererEditable;
	import ageb.utils.FlashTip;
	import nt.lib.util.assert;
	import starling.display.DisplayObject;

	/**
	 * 所有文档视图的基类，提供了一些公用方法
	 * @author zhanghaocong
	 *
	 */
	public class DocumentView extends Group
	{
		/**
		 * 缓存了的跟踪点
		 */
		public var cachedFocus:Point = new Point();

		/**
		 * 每次按住空格并左键按下时的点
		 */
		public var mouseDownPoint:Point = new Point();

		/**
		 * 当前鼠标位置缓存
		 */
		public var mousePoint:Point = new Point();

		/**
		 * 按住空格拖拽地图时的速度倍率
		 */
		public var scrollRatio:Number = 4;

		/**
		 * 空格键是否已按下
		 */
		public var isSpaceDown:Boolean;

		/**
		 * 创建一个新的 DocumentView
		 *
		 */
		public function DocumentView()
		{
			super();
		}

		/**
		 * 获得鼠标位置
		 * @return
		 *
		 */
		protected function get mousePointRelative():DisplayObject
		{
			if (sceneRenderer.info && sceneRenderer.numChildren > 0 && sceneRenderer.charLayer)
			{
				return sceneRenderer.charLayer;
			}
			return null;
		}

		/**
		 * 鼠标移动时回调
		 * @param event
		 *
		 */
		protected function onMouseMove(event:MouseEvent):void
		{
			if (mousePointRelative)
			{
				mousePoint.x = stage.mouseX - AGE.paddingLeft - mousePointRelative.pivotX;
				mousePoint.y = stage.mouseY - AGE.paddingTop - mousePointRelative.pivotY;
				mousePointRelative.globalToLocal(mousePoint, mousePoint);
			}
			else
			{
				mousePoint.x = NaN;
				mousePoint.y = NaN;
			}
		}

		/**
		 * 实现松开空格后，离开地图拖拽状态
		 * @param event
		 *
		 */
		protected function onKeyUp(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.SPACE)
			{
				Mouse.cursor = MouseCursor.AUTO;
				onMouseUp(null);
				stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				modules.tools.selectedTool.doc = doc;
				isSpaceDown = false;
			}
		}

		/**
		 * 实现按下空格后，进入地图拖拽状态
		 * @param event
		 *
		 */
		protected function onKeyDown(event:KeyboardEvent):void
		{
			if (!isSpaceDown && event.keyCode == Keyboard.SPACE)
			{
				isSpaceDown = true;
				Mouse.cursor = MouseCursor.HAND;
				stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
				stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				modules.tools.selectedTool.doc = null;
			}
		}

		/**
		 * 实现 CTRL + 滚轮滚动缩放地图
		 * @param event
		 *
		 */
		protected function onMouseWheel(event:MouseEvent):void
		{
			if (!event.ctrlKey)
			{
				return;
			}

			if (event.delta > 0)
			{
				_doc.zoomScale += 0.1;
			}
			else if (event.delta < 0)
			{
				_doc.zoomScale -= 0.1;
			}

			if (_doc.zoomScale <= 0.1)
			{
				_doc.zoomScale = 0.1;
			}
			camera.zoom(_doc.zoomScale);
		}

		/**
		 * 实现松开鼠标，取消拖拽地图
		 * @param event
		 *
		 */
		protected function onMouseUp(event:Event):void
		{
			stage.removeEventListener(Event.ENTER_FRAME, updateFocus);
		}

		/**
		 * 当空格按下时，该回调被注册，进入拖拽地图状态
		 * @param event
		 *
		 */
		protected function onMouseDown(event:MouseEvent):void
		{
			cachedFocus.x = _doc.focus.x;
			cachedFocus.y = _doc.focus.y;
			mouseDownPoint.x = stage.mouseX;
			mouseDownPoint.y = stage.mouseY;
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(Event.ENTER_FRAME, updateFocus);
		}

		/**
		 * 拖拽地图时，刷焦点位置，Camera 将自动更新
		 * @param event
		 *
		 */
		protected function updateFocus(event:Event):void
		{
			_doc.focus.x = cachedFocus.x - (stage.mouseX - mouseDownPoint.x) * scrollRatio;
			_doc.focus.y = cachedFocus.y - (stage.mouseY - mouseDownPoint.y) * scrollRatio;
		}

		private var _doc:Document;

		/**
		 * 设置或获取当关联的 Document<br>
		 * 设置时，将会先调用 onRemoveDoc，然后调用 onAddDoc
		 * @return
		 *
		 */
		public function get doc():Document
		{
			return _doc;
		}

		public function set doc(value:Document):void
		{
			if (_doc)
			{
				onRemoveDoc(doc);
			}
			_doc = value;

			if (_doc)
			{
				onAddDoc(doc);
			}
		}

		/**
		 * 文档被添加时，调用该方法<br>
		 * 这里可以执行一些事件侦听，初始化等操作
		 *
		 */
		protected function onAddDoc(doc:Document):void
		{
			// 手动切换焦点，否则收不到键盘事件
			stage.focus = stage;
			// 实现滚轮缩放操作
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			// 实现显示鼠标位置
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			// 实现按住空格后，可以拖放窗口
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			camera.track(_doc.focus, _doc.zoomScale, false, 0);
			doc.onRedo.add(doc_onRedo);
			doc.onUndo.add(doc_onUndo);
			doc.onSaveComplete.add(doc_onSaveComplete);
			doc.onSaveStart.add(doc_onSaveStart);
			camera.zoom(_doc.zoomScale);
		}

		/**
		 * 文档被删除时，调用该方法<br>
		 * 这里可以执行一些事件侦听，初始化等操作
		 *
		 */
		protected function onRemoveDoc(doc:Document):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.removeEventListener(Event.ENTER_FRAME, updateFocus);
			camera.track(null);
			doc.onRedo.remove(doc_onRedo);
			doc.onUndo.remove(doc_onUndo);
			doc.onSaveComplete.remove(doc_onSaveComplete);
			doc.onSaveStart.remove(doc_onSaveStart);
		}

		/**
		 * 保存开始时的时间
		 */
		private var saveStart:int;

		/**
		 * doc 开始保存时调用
		 *
		 */
		protected function doc_onSaveStart():void
		{
			saveStart = getTimer();
			FlashTip.show("保存…");
		}

		/**
		 * doc 保存完毕时调用
		 *
		 */
		protected function doc_onSaveComplete():void
		{
			FlashTip.show("保存完毕 (" + (getTimer() - saveStart) + "ms)");
		}

		/**
		 * doc 撤销时调用
		 *
		 */
		protected function doc_onUndo():void
		{
			FlashTip.show(format("撤销：{name}", _doc.nextOP));
		}

		/**
		 * doc 重做时调用
		 *
		 */
		protected function doc_onRedo():void
		{
			FlashTip.show(format("重做：{name}", _doc.currentOP));
		}

		/**
		 * 获得 Modules
		 * @return
		 *
		 */
		public function get modules():Modules
		{
			return Modules.getInstance();
		}

		/**
		 * 获得 SceneRendererEditable
		 * @return
		 *
		 */
		public function get sceneRenderer():SceneRendererEditable
		{
			assert(modules.ae.isEngineReady, "AE 尚未准备好");
			return modules.ae.sceneRenderer;
		}

		/**
		 * 获得 Camera
		 * @return
		 *
		 */
		public function get camera():Camera2D
		{
			return AGE.camera;
		}
	}
}
