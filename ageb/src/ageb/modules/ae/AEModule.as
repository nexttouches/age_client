package ageb.modules.ae
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import spark.skins.spark.WindowedApplicationSkin;
	import age.AGE;
	import ageb.modules.ModuleBase;
	import org.osflash.signals.Signal;

	/**
	 * AE 模块
	 * @author zhanghaocong
	 *
	 */
	public class AEModule extends ModuleBase
	{
		public function AEModule()
		{
			super();
		}

		/**
		 * 引擎启动后广播
		 */
		public var onEngineReady:Signal = new Signal();

		/**
		 * 检查引擎是否已启动
		 */
		public var isEngineReady:Boolean;

		/**
		 * 启动 AE 引擎
		 *
		 */
		public function startEngine():void
		{
			isEngineReady = true;
			AGE.config.isShowWireframe = true;
			AGE.paddingTop = 60;
			AGE.onStart.addOnce(function():void
			{
				// 更新相机
				AGE.camera.scene = sceneRenderer;
				AGE.camera.center = new Point(AGE.stageWidth * 0.5, AGE.stageHeight * 0.5);
				AGE.camera.isLimitBounds = false;
				AGE.isBlockNativeMouseDown = false;
			});
			AGE.start(modules.root.stage, SceneRendererEditable);
			modules.root.stage.addEventListener(Event.RESIZE, onResize);
			modules.root.systemManager.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, int.MAX_VALUE);
			modules.root.systemManager.addEventListener(MouseEvent.MOUSE_UP, onMouseDown, false, int.MAX_VALUE);
		}

		protected function onResize(event:Event):void
		{
			AGE.camera.center = new Point(AGE.stageWidth * 0.5, AGE.stageHeight * 0.5);
		}

		protected function onMouseDown(event:MouseEvent):void
		{
			switch (event.target.constructor)
			{
				case WindowedApplicationSkin:
					// 放行的同时切掉焦点
					event.target.stage.focus = event.target.stage;
					return;
			}
			event.stopPropagation();
		}

		/**
		 * 获得主渲染器
		 * @return
		 *
		 */
		public function get sceneRenderer():SceneRendererEditable
		{
			return AGE.s.root as SceneRendererEditable;
		}

		/**
		 * 切换图层轮廓
		 *
		 */
		public function toggleLayerOutline():void
		{
			sceneRenderer.isShowLayerOutline = !sceneRenderer.isShowLayerOutline;
		}

		/**
		 * 切换网格显示
		 *
		 */
		public function toggleGrid():void
		{
			sceneRenderer.isShowGrid = !sceneRenderer.isShowGrid;
		}

		/**
		 * 切换背景
		 *
		 */
		public function toggleBGOutline():void
		{
			sceneRenderer.isShowBGOutline = !sceneRenderer.isShowBGOutline;
		}
	}
}
