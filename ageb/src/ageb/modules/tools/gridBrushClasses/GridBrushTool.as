package ageb.modules.tools.gridBrushClasses
{
	import flash.geom.Point;
	import mx.events.FlexEvent;
	import ageb.modules.ae.SceneInfoEditable;
	import ageb.modules.document.Document;
	import ageb.modules.document.SceneDocument;
	import ageb.modules.scene.op.ChangeSceneGridCell;
	import ageb.modules.scene.op.ChangeSceneGridSize;
	import ageb.utils.FlashTip;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	/**
	 * 网格刷工具
	 * @author zhanghaocong
	 *
	 */
	public class GridBrushTool extends GridBrushPanel
	{

		[Embed(source="../assets/icons/binary.png")]
		/**
		 * 工具图标类
		 */
		private var iconClass:Class;

		/**
		 * 当前笔刷的值
		 */
		private var brushValue:int;

		/**
		 * 创建一个新的 GridBrushTool
		 *
		 */
		public function GridBrushTool()
		{
			super();
			name = "网格刷";
			shortcut = "Z"
			icon = iconClass;
			availableDocuments = new <Class>[ SceneDocument ];
		}

		/**
		 * @inheritDoc
		 * @param event
		 *
		 */
		override protected function onShow(event:FlexEvent):void
		{
			onGridSizeChange();
		}

		/**
		 * @inheritDoc
		 * @param value
		 *
		 */
		override public function set currentDocument(value:Document):void
		{
			if (currentSceneDocument)
			{
				currentSceneDocument.info.onGridSizeChange.remove(onGridSizeChange);
				sceneRenderer.removeEventListener(TouchEvent.TOUCH, onTouch);
			}
			super.currentDocument = value;

			if (currentSceneDocument)
			{
				sceneRenderer.isShowGrid = true;
				currentSceneDocument.info.onGridSizeChange.add(onGridSizeChange);
				sceneRenderer.addEventListener(TouchEvent.TOUCH, onTouch);
			}
		}

		/**
		 * 左键是否在 sceneRenderer 上按下
		 */
		private var isLeftDown:Boolean;

		/**
		 * 处理鼠标事件
		 * @param event
		 *
		 */
		private function onTouch(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(sceneRenderer);

			if (!touch)
			{
				return;
			}

			if (touch.phase == TouchPhase.BEGAN)
			{
				isLeftDown = true;
			}
			else if (touch.phase == TouchPhase.ENDED)
			{
				isLeftDown = false;
			}

			if (isLeftDown)
			{
				var p:Point = touch.getLocation(sceneRenderer.charLayer);
				var info:SceneInfoEditable = currentSceneDocument.info;

				if (p.x < 0 || p.y < 0 || p.x > info.width || p.y > info.height)
				{
					return;
				}
				// 除以网格宽高就可以算出网格位置
				var cellX:int = p.x / info.gridCellWidth;
				var cellY:int = p.y / info.gridCellHeight;

				if (info.getGridCell(cellX, cellY) != brushValue)
				{
					new ChangeSceneGridCell(currentDocument, cellX, cellY, brushValue).execute();
				}
			}
		}

		/**
		 * 更换笔刷时调用
		 *
		 */
		override protected function changeBrush():void
		{
			brushValue = brushs.selectedItem.value;
			FlashTip.show(format("网格刷：{label} ({value})", brushs.selectedItem));
		}

		/**
		 * 修改网格时调用
		 *
		 */
		override protected function saveGrid():void
		{
			new ChangeSceneGridSize(currentSceneDocument, int(gridWidth.value), int(gridHeight.value)).execute();
		}
	}
}
