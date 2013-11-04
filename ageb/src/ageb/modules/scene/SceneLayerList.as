package ageb.modules.scene
{
	import flash.geom.Point;
	import mx.core.ClassFactory;
	import mx.core.DragSource;
	import mx.core.IUIComponent;
	import mx.core.mx_internal;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	import spark.components.List;
	import spark.layouts.supportClasses.DropLocation;
	import ageb.modules.Modules;
	import ageb.modules.scene.op.DragReorderSceneLayerOP;
	import ageb.utils.FlashTip;
	import nt.lib.util.clone;

	/**
	 * 场景图层列表
	 * @author zhanghaocong
	 *
	 */
	public class SceneLayerList extends List
	{
		/**
		 * constructor
		 *
		 */
		public function SceneLayerList()
		{
			super();
			allowMultipleSelection = true;
			requireSelection = true;
			dragEnabled = true;
			dragMoveEnabled = true;
			dropEnabled = true;
			itemRenderer = new ClassFactory(LayerInfoItemRenderer);
			setStyle("selectionColor", 0x3399ff);
		}

		private function compareValues(a:int, b:int):int
		{
			return a - b;
		}

		/**
		 * 覆盖 dragDropHandler，实现基于 OP 的拖放操作
		 * @param event
		 *
		 */
		override protected function dragDropHandler(event:DragEvent):void
		{
			if (event.isDefaultPrevented())
			{
				return;
			}
			// 隐藏 drop 图形
			layout.hideDropIndicator();
			destroyDropIndicator();
			// 隐藏焦点
			drawFocus(false);
			mx_internal::drawFocusAnyway = false;

			// 验证拖拽数据
			if (!enabled || !event.dragSource.hasFormat("itemsByIndex"))
			{
				return
			}
			// 下落位置
			const dropLocation:DropLocation = layout.calculateDropLocation(event);
			// 索引
			const dropIndex:int = dropLocation.dropIndex;
			// 更新反馈（复制 / 移动）
			DragManager.showFeedback(event.ctrlKey ? DragManager.COPY : DragManager.MOVE);
			// 调用封装后的重新排序方法
			var dragSource:DragSource = event.dragSource;
			// 插入位置
			var caretIndex:int = -1;

			if (dragSource.hasFormat("caretIndex"))
				caretIndex = event.dragSource.dataForFormat("caretIndex") as int;
			var items:Vector.<Object> = dragSource.dataForFormat("itemsByIndex") as Vector.<Object>;
			// 创建一个 OP，之后的事情全部在 OP 里做
			var op:DragReorderSceneLayerOP = new DragReorderSceneLayerOP(Modules.getInstance().document.currentDoc, dropIndex, caretIndex, items, event.action, this);
			op.execute();
		}

		public function reorder(dropIndex:int, caretIndex:int, items:Vector.<Object>, action:String, dragInitiator:IUIComponent = null):void
		{
			var indices:Vector.<int> = selectedIndices;
			// 在修改 dataProvider 前，先取消所有选中状态
			// 等到全部弄完了再设置回来
			mx_internal::setSelectedIndices(new Vector.<int>(), false);
			validateProperties(); // 要求立即刷新

			// 重新排序就是先删除项
			// 同时再根据 dropIndex 重新添加项
			// 
			// 如果项被拖到其他列表（容器）中
			// 将在 ''对方'' 的 dragCompleteHandler 中处理以下删除操作
			// 此时 event.dragInitiator != this
			if (dragMoveEnabled && (action == DragManager.MOVE || action == DragManager.COPY) && (dragInitiator == null || dragInitiator == this))
			{
				// Remove the previously selected items
				indices.sort(compareValues);

				for (var i:int = indices.length - 1; i >= 0; i--)
				{
					if (indices[i] < dropIndex)
						dropIndex--;
					dataProvider.removeItemAt(indices[i]);
				}
			}
			// 新的选中区域数组
			var newSelection:Vector.<int> = new Vector.<int>();

			// 根据插入位置更新新的选择索引
			if (caretIndex != -1)
				newSelection.push(dropIndex + caretIndex);
			// 是否要复制？
			var copyItems:Boolean = action == DragManager.COPY;

			if (copyItems)
			{
				FlashTip.show("暂不支持复制");
				copyItems = false;
			}

			for (i = 0; i < items.length; i++)
			{
				// Get the item, clone if needed
				var item:Object = items[i];

				if (copyItems)
					item = clone(item);
				// Copy the data
				dataProvider.addItemAt(item, dropIndex + i);

				// Update the selection
				if (i != caretIndex)
					newSelection.push(dropIndex + i);
			}
			// 重新选择（刚刚移动 / 复制了的）项
			mx_internal::setSelectedIndices(newSelection, true);
		}

		public function scrollTo(index:int):void
		{
			// Sometimes we may need to scroll several times as for virtual layouts
			// this is not guaranteed to bring in the element in view the first try
			// as some items in between may not be loaded yet and their size is only
			// estimated.
			var delta:Point;
			var loopCount:int = 0;

			while (loopCount++ < 10)
			{
				validateNow();
				delta = layout.getScrollPositionDeltaToElement(index);

				if (!delta || (delta.x == 0 && delta.y == 0))
					break;
				layout.horizontalScrollPosition += delta.x;
				layout.verticalScrollPosition += delta.y;
			}
		}
	}
}
