package nt.ui.containers
{
	import flash.display.Sprite;
	import flash.events.Event;
	import nt.lib.util.Stats;
	import nt.ui.core.Component;
	import nt.ui.core.Container;
	import nt.ui.dnd.DnDManager;
	import nt.ui.tooltips.ToolTipManager;
	import nt.ui.util.PopUpManager;

	public class UIContainer extends Component
	{
		public var topLeft:Container;

		public var top:Container;

		public var topRight:Container;

		public var right:Container;

		public var bottomRight:Container;

		public var bottom:Container;

		public var bottomLeft:Container;

		public var left:Container;

		public var center:Container;

		public var popUp0:Sprite;

		public var popUp1:Sprite;

		public var popUp2:Sprite;

		public function UIContainer()
		{
			super();
			onAdd.addOnce(addListeners);
			onAdd.addOnce(setup);
			popUp0 = new Sprite();
			popUp1 = new Sprite();
			popUp2 = new Sprite();
			// 初始化 managers
			ToolTipManager.container = popUp2;
			DnDManager.container = popUp2;
			PopUpManager.registerLayer(0, popUp0);
			PopUpManager.registerLayer(1, popUp1);
			PopUpManager.registerLayer(2, popUp2);
		}

		private function setup(target:Component):void
		{
			addChild(popUp0);
			addChild(popUp1);
			addChild(popUp2);
		}

		protected function addListeners(target:Component):void
		{
			stage.addEventListener(Event.RESIZE, onResizeHandler);
			topLeft.onResize.add(onResizeHandler);
			top.onResize.add(onResizeHandler);
			topRight.onResize.add(onResizeHandler);
			right.onResize.add(onResizeHandler);
			bottomRight.onResize.add(onResizeHandler);
			bottom.onResize.add(onResizeHandler);
			bottomLeft.onResize.add(onResizeHandler);
			left.onResize.add(onResizeHandler);
			center.onResize.add(onResizeHandler);
			positionContainers(stage.stageWidth, stage.stageHeight);
		}

		protected function positionContainers(width:int, height:int):void
		{
			topLeft.x = 0;
			topLeft.y = 0;
			top.x = (width - top.width) >> 1;
			top.y = 0;
			topRight.x = width - topRight.width;
			topRight.y = 0;
			right.x = width - right.width;
			right.y = (height - right.height) >> 1;
			bottomRight.x = width - bottomRight.width;
			bottomRight.y = height - bottomRight.height;
			bottom.x = (width - bottom.width) >> 1;
			bottom.y = height - bottom.height;
			bottomLeft.x = 0;
			bottomLeft.y = height - bottomLeft.height;
			left.x = 0;
			left.y = (height - left.height) >> 1;
			center.x = (width - center.width) >> 1;
			center.y = (height - center.height) >> 1;
			setSize(width, height);
		}

		protected function onResizeHandler(... args):void
		{
			positionContainers(stage.stageWidth, stage.stageHeight);
		}

		private var stats:Stats;

		private var _showStats:Boolean;

		/**
		 * 设置或获取是否显示性能统计
		 * @return
		 *
		 */
		public function get showStats():Boolean
		{
			return _showStats;
		}

		public function set showStats(value:Boolean):void
		{
			if (value != _showStats)
			{
				_showStats = value;

				if (value)
				{
					popUp2.addChild(stats = new Stats());
				}
				else
				{
					popUp2.removeChild(stats);
					stats = null;
				}
			}
		}
	}
}
