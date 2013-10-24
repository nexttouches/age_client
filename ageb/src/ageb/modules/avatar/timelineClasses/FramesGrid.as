package ageb.modules.avatar.timelineClasses
{
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import mx.collections.IList;
	import mx.events.ResizeEvent;
	import spark.components.Grid;
	import spark.components.gridClasses.CellPosition;
	import spark.events.GridSelectionEvent;

	/**
	 * 时间轴帧网格的网格
	 * @author zhanghaocong
	 *
	 */
	[ExcludeClass]
	public class FramesGrid extends Grid
	{
		/**
		 * 当前帧指示器（红色竖线）
		 */
		private var currentFrameIndicator:CurrentFrameIndicator;

		/**
		 * @inheritDoc
		 *
		 */
		public function FramesGrid()
		{
			super();
			addEventListener(ResizeEvent.RESIZE, onResize);
		}

		/**
		 * @private
		 * @param event
		 *
		 */
		protected function onResize(event:ResizeEvent):void
		{
			validateCurrentFrame();
		}

		/**
		 * 滚动条滚动时广播<br>
		 * 调用时的正确签名是<br>
		 * function (value:Number):void;
		 */
		public var onVerticalScrollPositionChange:Function;

		/**
		 * @inheritDoc
		 *
		 */
		override public function set verticalScrollPosition(value:Number):void
		{
			const old:int = verticalScrollPosition;
			super.verticalScrollPosition = value;

			if (old != value)
			{
				if (onVerticalScrollPositionChange != null)
				{
					onVerticalScrollPositionChange(value);
				}
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			currentFrameIndicator = new CurrentFrameIndicator();
			overlay.addDisplayObject(currentFrameIndicator);
			addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown);
		}

		/**
		 * @private
		 * @param event
		 *
		 */
		protected function onRightMouseDown(event:MouseEvent):void
		{
			const fc:FrameCell = event.target as FrameCell;

			if (fc)
			{
				if (!selectionContainsCell(fc.rowIndex, fc.columnIndex))
				{
					selectedCell = new CellPosition(fc.rowIndex, fc.columnIndex);
					dispatchEvent(new GridSelectionEvent(GridSelectionEvent.SELECTION_CHANGE, true));
				}
			}
		}

		/**
		 * 标记当前帧指示器是否需要刷新
		 */
		private var isCurrentFrameIndicatorInvalidate:Boolean;

		private var _currentFrame:int = -1;

		/**
		 * 设置或获取当前帧<br>
		 * 默认 -1，也就是不是任何帧
		 * @return
		 *
		 */
		public function get currentFrame():int
		{
			return _currentFrame;
		}

		public function set currentFrame(value:int):void
		{
			if (_currentFrame != value)
			{
				_currentFrame = value;
				validateCurrentFrame();
			}
		}

		/**
		 * @private
		 *
		 */
		protected function validateCurrentFrame():void
		{
			var bounds:Rectangle = getCellBounds(0, _currentFrame);

			if (bounds)
			{
				isCurrentFrameIndicatorInvalidate = false;
				currentFrameIndicator.draw(bounds.x, bounds.width, height)
			}
			else
			{
				isCurrentFrameIndicatorInvalidate = true;
				invalidateDisplayList();
			}
		}

		/**
		 * @inheritDoc
		 * @param unscaledWidth
		 * @param unscaledHeight
		 *
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			if (isCurrentFrameIndicatorInvalidate)
			{
				validateCurrentFrame();
			}
		}
	}
}
