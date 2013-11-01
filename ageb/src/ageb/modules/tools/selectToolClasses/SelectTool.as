package ageb.modules.tools.selectToolClasses
{
	import flash.display.Stage;
	import flash.events.ContextMenuEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import mx.managers.PopUpManager;
	import spark.skins.spark.WindowedApplicationSkin;
	import age.AGE;
	import age.renderers.GridCellRenderer;
	import age.renderers.LayerRenderer;
	import age.renderers.MouseResponder;
	import ageb.components.TextureBrowser;
	import ageb.modules.Modules;
	import ageb.modules.ae.*;
	import ageb.modules.ae.ISelectableInfo;
	import ageb.modules.ae.ISelectableRenderer;
	import ageb.modules.ae.LayerInfoEditable;
	import ageb.modules.ae.LayerRendererEditable;
	import ageb.modules.ae.ObjectInfoEditable;
	import ageb.modules.ae.RegionInfoEditable;
	import ageb.modules.ae.SceneInfoEditable;
	import ageb.modules.ae.dnd.BgDragThumb;
	import ageb.modules.ae.dnd.IDragThumb;
	import ageb.modules.ae.dnd.ObjectDragThumb;
	import ageb.modules.ae.dnd.RegionInfoDragThumb;
	import ageb.modules.document.Document;
	import ageb.modules.scene.op.AddBG;
	import ageb.modules.scene.op.MoveObject;
	import ageb.modules.scene.op.RemoveObject;
	import ageb.modules.tools.selectToolClasses.menus.SelectToolMenu;
	import nt.lib.util.assert;
	import nt.ui.util.ShortcutUtil;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	/**
	 * 选择工具
	 * @author zhanghaocong
	 *
	 */
	public class SelectTool extends SelectToolPanel
	{

		[Embed(source="../assets/icons/arrow2_nw.png")]
		private var iconClass:Class;

		/**
		 * 右键按下位置
		 */
		protected var rightDownPoint:Point = new Point();

		/**
		 * 左键按下位置
		 */
		protected var downPoint:Point = new Point();

		/**
		 * 当前鼠标位置
		 */
		protected var currentPoint:Point = new Point();

		/**
		 * 标记是否开始拖动
		 */
		protected var isDragStart:Boolean;

		/**
		 * 标记是否正在拖动
		 */
		protected var isDragMoving:Boolean;

		/**
		 * 是否刚刚拖拽完成
		 */
		protected var isJustDragged:Boolean;

		/**
		 * 拖拽时的 DragThumb 列表
		 */
		protected var dragThumbs:Vector.<IDragThumb> = new Vector.<IDragThumb>;

		/**
		 * 使用键盘调整坐标的像素大小
		 */
		private const NUDE_STEP:int = 1;

		/**
		 * 拖拽的阈值
		 */
		private const DRAG_MOVE_THRESHOLD:Number = 8;

		/**
		 * constructor
		 *
		 */
		public function SelectTool()
		{
			super();
			name = "选择";
			shortcut = "V";
			icon = iconClass;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function set doc(value:Document):void
		{
			if (sceneDoc)
			{
				sceneRenderer.removeEventListener(TouchEvent.TOUCH, onTouch);
				ShortcutUtil.unregister([ Keyboard.LEFT ]);
				ShortcutUtil.unregister([ Keyboard.RIGHT ]);
				ShortcutUtil.unregister([ Keyboard.UP ]);
				ShortcutUtil.unregister([ Keyboard.DOWN ]);
				ShortcutUtil.unregister([ Keyboard.LEFT, Keyboard.CONTROL ]);
				ShortcutUtil.unregister([ Keyboard.RIGHT, Keyboard.CONTROL ]);
				ShortcutUtil.unregister([ Keyboard.UP, Keyboard.CONTROL ]);
				ShortcutUtil.unregister([ Keyboard.DOWN, Keyboard.CONTROL ]);
				ShortcutUtil.unregister([ Keyboard.DELETE ])
				nativeStage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				nativeStage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				nativeStage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				nativeStage.removeEventListener(MouseEvent.RIGHT_CLICK, onRightClick);
				onMouseUp(null);
			}
			super.doc = value;

			if (sceneDoc)
			{
				sceneRenderer.addEventListener(TouchEvent.TOUCH, onTouch);
				ShortcutUtil.register([ Keyboard.LEFT ], moveLeft);
				ShortcutUtil.register([ Keyboard.RIGHT ], moveRight);
				ShortcutUtil.register([ Keyboard.UP ], moveUp);
				ShortcutUtil.register([ Keyboard.DOWN ], moveDown);
				ShortcutUtil.register([ Keyboard.LEFT, Keyboard.CONTROL ], moveLeft);
				ShortcutUtil.register([ Keyboard.RIGHT, Keyboard.CONTROL ], moveRight);
				ShortcutUtil.register([ Keyboard.UP, Keyboard.CONTROL ], moveUp);
				ShortcutUtil.register([ Keyboard.DOWN, Keyboard.CONTROL ], moveDown);
				ShortcutUtil.register([ Keyboard.DELETE ], removeObject)
				nativeStage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				nativeStage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				nativeStage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				nativeStage.addEventListener(MouseEvent.RIGHT_CLICK, onRightClick);
				sceneRenderer.isShowRegions = isShowRegions;
			}
		}

		/**
		 * @private
		 *
		 */
		protected function onRightClick(event:MouseEvent):void
		{
			if (isInSceneRenderer(event))
			{
				rightDownPoint.x = nativeStage.mouseX;
				rightDownPoint.y = nativeStage.mouseY;
				SelectToolMenu.show(sceneRenderer.getLayerAt(sceneDoc.info.selectedLayersIndices[0]) as LayerRendererEditable);
			}
		}

		/**
		 * @private
		 *
		 */
		private function removeObject():void
		{
			new RemoveObject(doc, selectedObjects).execute();
		}

		/**
		 * 设置 isJustDragged 的小方法<br>
		 * @param value
		 *
		 */
		final private function setIsJustDraggedFalse():void
		{
			isJustDragged = false;
		}

		/**
		 * 判断当前鼠标是否在 SceneRenderer 上
		 * @param event
		 * @return
		 *
		 */
		final protected function isInSceneRenderer(event:MouseEvent):Boolean
		{
			return event.target is WindowedApplicationSkin;
		}

		/**
		 * @private
		 *
		 */
		protected function onMouseDown(event:MouseEvent):void
		{
			onMouseUp(event);

			if (isInSceneRenderer(event))
			{
				downPoint.x = nativeStage.mouseX;
				downPoint.y = nativeStage.mouseY;
				currentPoint.x = nativeStage.mouseX;
				currentPoint.y = nativeStage.mouseY;
			}
		}

		/**
		 * @private
		 *
		 */
		protected function onMouseUp(event:MouseEvent):void
		{
			if (isDragMoving)
			{
				// onTouch 的 hacking
				isJustDragged = true;
				callLater(setIsJustDraggedFalse);

				// 恢复拖拽状态
				for each (var o:ISelectableInfo in selectedObjects)
				{
					o.isDragging = false;
				}

				// 检查是否需要执行
				if (event && isInSceneRenderer(event))
				{
					currentPoint.x = nativeStage.mouseX;
					currentPoint.y = nativeStage.mouseY;
					var dx:Number = currentPoint.x - downPoint.x;
					var dy:Number = currentPoint.y - downPoint.y;
					new MoveObject(doc, selectedObjects, dx, -dy, -dy, snapX, snapY, snapZ, event.controlKey, true).execute();
				}
				else
				{
					// 什么也不做				
				}

				// 清空缩略图
				while (dragThumbs.length)
				{
					dragThumbs.pop().displayObject.removeFromParent(true);
				}
				isDragMoving = false;
				isDragStart = false;
			}
		}

		/**
		 * @private
		 *
		 */
		protected function onMouseMove(event:MouseEvent):void
		{
			if (isDragStart && ShortcutUtil.isLeftDown && selectedObjects.length > 0 && isInSceneRenderer(event))
			{
				currentPoint.x = nativeStage.mouseX;
				currentPoint.y = nativeStage.mouseY;

				// 拖拽中，更新坐标
				if (isDragMoving)
				{
					updateThumbsPosition();
				}
				else
				{
					// 计算出距离，判断阈值，开始拖拽
					var d:Number = Point.distance(currentPoint, downPoint);
					isDragMoving = d >= DRAG_MOVE_THRESHOLD;

					// 此时开始拖拽
					if (isDragMoving)
					{
						for each (var o:ISelectableInfo in selectedObjects)
						{
							// 标记拖拽中
							o.isDragging = true;
							// 分别创建 DragThumb
							// TODO if else 太傻逼，找个时间整理下
							var dt:IDragThumb;
							var lr:LayerRenderer;

							if (o is BGInfoEditable)
							{
								var bgInfo:BGInfoEditable = o as BGInfoEditable;
								lr = sceneRenderer.getLayerAt(bgInfo.layerIndex);
								dt = new BgDragThumb();
								dt.setSource(lr.getBGRendererByInfo(bgInfo));
							}
							else if (o is ObjectInfoEditable)
							{
								var objectInfo:ObjectInfoEditable = o as ObjectInfoEditable;
								lr = sceneRenderer.getLayerAt(objectInfo.layerIndex);
								dt = new ObjectDragThumb();

								if (lr.getObjectRendererByInfo(objectInfo).animations.length > 0)
								{
									dt.setSource(lr.getObjectRendererByInfo(objectInfo).animations[0]);
								}
								else
								{
									dt.setSource(lr.getObjectRendererByInfo(objectInfo).displayObject);
								}
							}
							else if (o is RegionInfoEditable)
							{
								var regionInfo:RegionInfoEditable = o as RegionInfoEditable;
								lr = sceneRenderer.charLayer;
								dt = new RegionInfoDragThumb();
								dt.setSource(lr.getRegionInfoRenderer(regionInfo));
							}
							assert(lr != null, "找不到对应的 LayerRenderer");
							lr.addChild(dt.displayObject);
							dragThumbs.push(dt);
						}
					}
				}
			}
		}

		/**
		 * 根据参数更新所有缩略图的位置
		 *
		 */
		final protected function updateThumbsPosition():void
		{
			var dx:Number = currentPoint.x - downPoint.x;
			var dy:Number = currentPoint.y - downPoint.y;

			for each (var thumb:IDragThumb in dragThumbs)
			{
				// 显示对象采用笛卡尔坐标系
				// 这里 y 取负值
				thumb.offset(dx, -dy, snapX, snapY);
			}
		}

		/**
		 * 获得 nativeStage
		 * @return
		 *
		 */
		final protected function get nativeStage():Stage
		{
			return AGE.s.nativeStage;
		}

		/**
		 * 设置或获取选中的对象列表
		 * @return
		 *
		 */
		final public function get selectedObjects():Vector.<ISelectableInfo>
		{
			return sceneDoc.info.selectedObjects;
		}

		final public function set selectedObjects(value:Vector.<ISelectableInfo>):void
		{
			sceneDoc.info.selectedObjects = value;
		}

		/**
		 * 获取调整坐标的像素大小<br>
		 * 按住 SHIFT 可以十倍速移动
		 * @return
		 *
		 */
		final private function getNudeStep():int
		{
			if (ShortcutUtil.isDown(Keyboard.SHIFT))
			{
				return NUDE_STEP * 10;
			}
			return NUDE_STEP;
		}

		/**
		 * @private
		 *
		 */
		private function moveDown():void
		{
			if (selectedObjects.length > 0)
			{
				new MoveObject(doc, selectedObjects, 0, -getNudeStep(), -getNudeStep(), 1, 1, 1, ShortcutUtil.isDown(Keyboard.CONTROL), true).execute();
			}
		}

		/**
		 * @private
		 *
		 */
		private function moveUp():void
		{
			if (selectedObjects.length > 0)
			{
				new MoveObject(doc, selectedObjects, 0, getNudeStep(), getNudeStep(), 1, 1, 1, ShortcutUtil.isDown(Keyboard.CONTROL), true).execute();
			}
		}

		/**
		 * @private
		 *
		 */
		private function moveRight():void
		{
			if (selectedObjects.length > 0)
			{
				new MoveObject(doc, selectedObjects, getNudeStep(), 0, 0, 1, 1, 1, ShortcutUtil.isDown(Keyboard.CONTROL), true).execute();
			}
		}

		/**
		 * @private
		 *
		 */
		private function moveLeft():void
		{
			if (selectedObjects.length > 0)
			{
				new MoveObject(doc, selectedObjects, -getNudeStep(), 0, 0, 1, 1, 1, ShortcutUtil.isDown(Keyboard.CONTROL), true).execute();
			}
		}

		/**
		 * @private
		 *
		 */
		private function onTouch(event:TouchEvent):void
		{
			if (isJustDragged)
			{
				return;
			}
			// 获得 Touch 对象
			var touch:Touch = event.getTouch(sceneRenderer);

			// 以下任意情况将不退出
			if (!touch || touch.phase == TouchPhase.HOVER || touch.phase == TouchPhase.MOVED || touch.phase == TouchPhase.STATIONARY)
			{
				return;
			}
			var info:ISelectableInfo, oo:ISelectableInfo;
			var index:int;
			var sceneInfo:SceneInfoEditable = sceneDoc.info;

			// 根据点击的类型获取对应的 ISelectable
			if (touch.target is ISelectableRenderer)
			{
				info = ISelectableRenderer(touch.target).selectableInfo;
			}
			else if (touch.target is MouseResponder)
			{
				info = ISelectableRenderer(MouseResponder(touch.target).owner).selectableInfo;
			}

			// 根据 phase 决定操作类型 
			// 首先是 BEGAN，这将决定 onMouseMove 中是否要执行拖拽操作
			if (!isDragStart && touch.phase == TouchPhase.BEGAN)
			{
				// 检查该 info 是否在选中列表中
				// 如果是，我们就可以拖拽
				if (info && selectedObjects.indexOf(info) != -1)
				{
					isDragStart = true;
				}
			}
			// 然后是 ENDED，这将更新选中对象
			else if (touch.phase == TouchPhase.ENDED)
			{
				// 选中了对象
				if (info)
				{
					// 该对象不可选，我们退出
					if (!info.isSelectable)
					{
						return;
					}
					index = sceneInfo.selectedObjects.indexOf(info);

					if (event.ctrlKey)
					{
						// 添加
						if (index == -1)
						{
							sceneInfo.selectedObjects.push(info);
							info.isSelected = true;
						}
						// 删除
						else
						{
							sceneInfo.selectedObjects.splice(index, 1);
							info.isSelected = false;
						}
						sceneInfo.onSelectedObjectsChange.dispatch(this);
					}
					else
					{
						// 设置单个选中
						sceneInfo.selectedObject = info;
					}
				}
				// 没按住 CTRL
				else if (!event.ctrlKey)
				{
					// 点击了空白区域，我们清空选择
					if (touch.target == sceneRenderer || touch.target is GridCellRenderer)
					{
						if (sceneInfo.selectedObjects.length > 0)
						{
							sceneInfo.selectedObject = null;
						}
					}
				}
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function saveRegionSettings():void
		{
			settings.isShowRegions = isShowRegionsField.selected;
			saveSettings();
			loadSettings();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function saveSnap():void
		{
			isSameAsWidth = isSameAsWidthField.selected;
			settings.snapX = snapXField.value;

			if (isSameAsWidth)
			{
				settings.snapY = snapXField.value;
				settings.snapZ = snapXField.value;
			}
			else
			{
				settings.snapY = snapYField.value;
				settings.snapZ = snapZField.value;
			}
			settings.isSameAsWidth = isSameAsWidth;
			saveSettings();
			loadSettings();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function loadSettings():void
		{
			snapX = settings.snapX || 1;
			snapY = settings.snapY || 1;
			snapZ = settings.snapZ || 1;
			isSameAsWidth = settings.isSameAsWidth == true;
			isShowRegions = settings.isShowRegions == true;

			if (sceneRenderer)
			{
				sceneRenderer.isShowRegions = isShowRegions;
			}
		}
	}
}
