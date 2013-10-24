package ageb.modules.avatar.timelineClasses
{
	import flash.events.MouseEvent;
	import mx.core.ClassFactory;
	import spark.components.List;

	/**
	 * 图层列表
	 * @author zhanghaocong
	 *
	 */
	public class LayerList extends List
	{
		/**
		 * 创建一个新的图层列表
		 *
		 */
		public function LayerList()
		{
			super();
			setStyle("selectionColor", 0x3399ff);
			allowMultipleSelection = true;
			itemRenderer = new ClassFactory(LayerListItemRenderer);
			percentWidth = 100;
			percentHeight = 100;
		}

		/**
		 * 禁用滚轮事件
		 * @param event
		 *
		 */
		protected function scroller_onMouseWheel(event:MouseEvent):void
		{
			event.preventDefault();
			event.stopPropagation();
			event.stopImmediatePropagation();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function attachSkin():void
		{
			super.attachSkin();
			scroller.addEventListener(MouseEvent.MOUSE_WHEEL, scroller_onMouseWheel, true, int.MAX_VALUE);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function detachSkin():void
		{
			scroller.removeEventListener(MouseEvent.MOUSE_WHEEL, scroller_onMouseWheel, true);
			super.detachSkin();
		}
	}
}
