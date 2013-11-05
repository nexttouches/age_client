package ageb.modules.tools.gridBrushClasses
{
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import mx.events.FlexEvent;
	import ageb.modules.ae.SceneInfoEditable;
	import ageb.modules.document.Document;
	import ageb.modules.document.SceneDocument;
	import ageb.modules.scene.op.ChangeSceneGridCell;
	import ageb.modules.scene.op.ChangeSceneGridResolution;
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
			availableDocs = new <Class>[ SceneDocument ];
		}

		/**
		 * @inheritDoc
		 * @param event
		 *
		 */
		override protected function onShow(event:FlexEvent):void
		{
			onGridResolutionChange();
		}

		/**
		 * @inheritDoc
		 * @param value
		 *
		 */
		override public function set doc(value:Document):void
		{
			if (sceneDoc)
			{
				sceneDoc.info.onGridResolutionChange.remove(onGridResolutionChange);
				sceneRenderer.removeEventListener(TouchEvent.TOUCH, onTouch);
			}
			super.doc = value;

			if (sceneDoc)
			{
				sceneRenderer.isShowGrid = true;
				sceneDoc.info.onGridResolutionChange.add(onGridResolutionChange);
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
				const mouse:Point = touch.getLocation(sceneRenderer.charLayer);
				const info:SceneInfoEditable = sceneDoc.info;

				if (mouse.x < 0 || mouse.y < 0 || mouse.x > info.width || mouse.y > info.height)
				{
					return;
				}
				const scene:Vector3D = new Vector3D(mouse.x, info.uiToY(mouse.y), info.uiToZ(mouse.y));

				// 判断是否点击范围超过了 depth
				if (scene.z > info.depth)
				{
					return;
				}
				// 除以网格宽高可以快速算出网格位置
				var cellZ:int = scene.z / info.gridCellSize.z;
				var cellX:int = scene.x / info.gridCellSize.x;

				if (info.getGridCell(cellX, cellZ) != brushValue)
				{
					new ChangeSceneGridCell(doc, cellX, cellZ, brushValue).execute();
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
			new ChangeSceneGridResolution(sceneDoc, new Vector3D(int(gridWidth.value), 0, int(gridDepth.value))).execute();
		}
	}
}
