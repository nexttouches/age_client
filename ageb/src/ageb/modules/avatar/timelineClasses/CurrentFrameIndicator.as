package ageb.modules.avatar.timelineClasses
{
	import flash.display.Shape;

	/**
	 * 当前帧指示器
	 * @author zhanghaocong
	 *
	 */
	public class CurrentFrameIndicator extends Shape
	{
		/**
		 * constructor
		 *
		 */
		public function CurrentFrameIndicator()
		{
			super();
		}

		/**
		 * 绘制这样的图形<br>
		 * <pre>
		 * +---+
		 * |   |
		 * +---+
		 *   |
		 *   |
		 *   |
		 *   |
		 * </pre>
		 * @param x
		 * @param width
		 * @param height
		 *
		 */
		public function draw(x:int, width:int, bottom:int):void
		{
			// 已知 header 的高度是 21
			const rectHeight:int = 21;
			const paddingV:int = 2;
			const paddingH:int = 1;
			var lineX:int = x + width / 2;
			graphics.clear();
			graphics.lineStyle(1, 0xff0000, 1, true);
			graphics.beginFill(0xff0000, 0.2);
			// 方块
			graphics.drawRect(x + paddingH, -rectHeight - 1 + paddingV, width - paddingH * 2, rectHeight - paddingV * 2);
			// 线段
			graphics.moveTo(lineX, -1 - paddingV);
			graphics.lineTo(lineX, bottom);
		}
	}
}
