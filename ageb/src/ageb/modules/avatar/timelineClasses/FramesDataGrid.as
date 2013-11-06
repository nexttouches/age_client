package ageb.modules.avatar.timelineClasses
{
	import flash.events.MouseEvent;
	import mx.core.ClassFactory;
	import mx.core.ScrollPolicy;
	import spark.components.DataGrid;
	import spark.components.gridClasses.CellPosition;
	import spark.components.gridClasses.GridColumn;
	import spark.components.gridClasses.GridSelectionMode;
	import spark.events.GridCaretEvent;
	import spark.events.GridSelectionEvent;
	import age.data.ObjectInfo;
	import ageb.ageb_internal;
	import ageb.modules.ae.ActionInfoEditable;
	import ageb.modules.ae.FrameInfoEditable;
	import ageb.modules.ae.FrameLayerInfoEditable;
	import ageb.modules.ae.ObjectInfoEditable;
	import ageb.modules.ae.ceilTo;
	import ageb.modules.document.AvatarDocument;
	import org.apache.flex.collections.VectorList;
	import org.osflash.signals.Signal;
	import ageb.modules.avatar.timelineClasses.contextMenus.FrameMenu;

	/**
	 * 时间轴帧网格
	 * @author zhanghaocong
	 *
	 */
	public class FramesDataGrid extends DataGrid
	{
		/**
		 * 滚动条滚动时广播<br>
		 * 正确的签名是<br>
		 * <code>function (value:Number):void;</code><br>
		 * 其中 value 是当前滚动的位置<br>
		 * 可以直接赋值给其他 Group 的 verticalScrollPosition 进行同步滚动
		 */
		public var onVerticalScrollPositionChange:Signal = new Signal(Number);

		/**
		 * 创建一个新的 FramesDataGrid
		 *
		 */
		public function FramesDataGrid()
		{
			super();
			percentWidth = 100;
			percentHeight = 100;
			setStyle("verticalScrollPolicy", ScrollPolicy.ON);
			setStyle("horizontalScrollPolicy", ScrollPolicy.ON);
			setStyle("skinClass", FramesGridSkin);
			itemRenderer = new ClassFactory(FrameCell);
			resizableColumns = false;
			sortableColumns = false;
			selectionMode = GridSelectionMode.MULTIPLE_CELLS;
			// 空数组，数据之后再填
			columns = new VectorList(new Vector.<GridColumn>);
		}

		/**
		* 获得使用中的 FramesGrid
		* @return
		*
		*/
		final protected function get framesGrid():FramesGrid
		{
			return grid as FramesGrid;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function attachSkin():void
		{
			super.attachSkin();
			// 需要广播当前滚动位置
			framesGrid.onVerticalScrollPositionChange = onVerticalScrollPositionChange.dispatch;
			framesGrid.addEventListener(MouseEvent.RIGHT_CLICK, onRightClick);
		}

		/**
		 * @private
		 * @param event
		 *
		 */
		protected function onRightClick(event:MouseEvent):void
		{
			const cell:FrameCell = event.target as FrameCell;

			if (cell && cell.selected)
			{
				FrameMenu.show(actionInfo, selectedCells);
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function detachSkin():void
		{
			framesGrid.onVerticalScrollPositionChange = null;
			framesGrid.removeEventListener(MouseEvent.RIGHT_CLICK, onRightClick);
			super.detachSkin();
		}

		/**
		 * 我们视焦点为当前选中帧，这里做一些处理
		 * @param event
		 *
		 */
		protected function onCaretChange(event:GridCaretEvent):void
		{
			// 当没有任何动作时撤退
			if (!actionInfo)
			{
				return;
			}

			// 这个 newColumnIndex 就是我们要的当前帧
			// 满足以下任一条件，当前选中帧则无效
			// 
			// 与旧值相同
			if (event.newColumnIndex == event.oldColumnIndex)
			{
				return;
			}

			// 新值为 -1
			if (event.newColumnIndex == -1)
			{
				return;
			}

			// 对象播放中
			if (objectInfo.isPlaying)
			{
				return;
			}

			// 点过头
			if (actionInfo.numFrames <= event.newColumnIndex)
			{
				return;
			}
			objectInfo.currentFrame = event.newColumnIndex;
		}

		private var _numColumns:int = 0;

		/**
		 * 设置或获取有多少帧<br>
		 * 根据参数将创建对应数目的 GridColumn
		 * @return
		 *
		 */
		public function get numColumns():int
		{
			return _numColumns;
		}

		public function set numColumns(value:int):void
		{
			if (value > _numColumns)
			{
				_numColumns = value;

				for (var i:int = 0; i < _numColumns; i++)
				{
					var gc:GridColumn = new GridColumn();
					gc.minWidth = 0;
					columns.addItem(gc);
				}
			}
		}

		private var _avatarDoc:AvatarDocument;

		/**
		 * 设置或获取当前显示的 AvatarDocument
		 * @return
		 *
		 */
		public function get avatarDoc():AvatarDocument
		{
			return _avatarDoc;
		}

		public function set avatarDoc(value:AvatarDocument):void
		{
			if (_avatarDoc)
			{
				removeEventListener(GridSelectionEvent.SELECTION_CHANGE, onSelectionChange);
				removeEventListener(GridCaretEvent.CARET_CHANGE, onCaretChange);
				objectInfo.onActionNameChange.remove(onActionNameChange);
				objectInfo.onCurrentFrameChange.remove(onCurrentFrameChange);
			}
			_avatarDoc = value;

			if (_avatarDoc)
			{
				objectInfo.onCurrentFrameChange.add(onCurrentFrameChange);
				objectInfo.onActionNameChange.add(onActionNameChange);
				addEventListener(GridCaretEvent.CARET_CHANGE, onCaretChange);
				addEventListener(GridSelectionEvent.SELECTION_CHANGE, onSelectionChange);
			}
			onActionNameChange();
		}

		/**
		 * 整理所有的 CellPosition 到 FrameInfo 再交给 actionInfo
		 * @param event
		 *
		 */
		protected function onSelectionChange(event:GridSelectionEvent):void
		{
			// XXX 应根据 event.kind 做判断优化选区更新事件
			// 不这么做性能也还可以，暂且用一下
			const cells:Vector.<CellPosition> = selectedCells; // 当没有选中任何项时，cells.length 为 0
			var frames:Vector.<FrameInfoEditable> = new Vector.<FrameInfoEditable>();

			for (var i:int = 0, n:int = cells.length; i < n; i++)
			{
				const rowIndex:int = cells[i].rowIndex;
				const columnIndex:int = cells[i].columnIndex;

				// 选中的格子超过了总长度
				if (columnIndex >= actionInfo.layers[rowIndex].frames.length)
				{
					continue;
				}
				frames.push(actionInfo.layers[rowIndex].frames[columnIndex] as FrameInfoEditable);
			}
			actionInfo.ageb_internal::setSelectedFrames(frames, this);
		}

		/**
		 * 更新当前显示的动作信息
		 * @see actionInfo
		 */
		private function onActionNameChange():void
		{
			if (objectInfo)
			{
				actionInfo = objectInfo.actionInfo as ActionInfoEditable;
			}
			else
			{
				actionInfo = null;
			}
		}

		/**
		 * 设置或获取当前渲染的帧图层列表
		 * @return
		 *
		 */
		public function get layers():VectorList
		{
			return dataProvider as VectorList;
		}

		public function set layers(value:VectorList):void
		{
			var i:int, n:int, layer:FrameLayerInfoEditable;

			if (layers)
			{
				// 删除图层的侦听
				for (i = 0, n = layers.length; i < n; i++)
				{
					layer = layers.getItemAt(i) as FrameLayerInfoEditable;
					layer.onFramesChange.remove(onFramesChange);
				}
			}
			dataProvider = value;

			if (layers)
			{
				for (i = 0, n = layers.length; i < n; i++)
				{
					// 添加图层的侦听
					for (i = 0; i < n; i++)
					{
						layer = layers.getItemAt(i) as FrameLayerInfoEditable;
						layer.onFramesChange.add(onFramesChange);
					}
				}
			}
		}

		/**
		 * 根据图层位置，刷新指定行的 FrameCell
		 * @param layer
		 *
		 */
		private function onFramesChange(layer:FrameLayerInfoEditable):void
		{
			const rowIndex:int = layer.index;

			for (var columnIndex:int = 0; columnIndex < _numColumns; columnIndex++)
			{
				(grid.getItemRendererAt(rowIndex, columnIndex) as FrameCell).prepare(true);
			}
			onSelectionChange(null);
		}

		private var _actionInfo:ActionInfoEditable;

		/**
		 * 设置或获取当前显示的动作
		 * @return
		 *
		 */
		public function get actionInfo():ActionInfoEditable
		{
			return _actionInfo;
		}

		public function set actionInfo(value:ActionInfoEditable):void
		{
			if (_actionInfo)
			{
				framesGrid.currentFrame = 0;
				layers = null;
				_actionInfo.onSelectedFramesChange.remove(onSelectedFramesChange);
			}
			_actionInfo = value;
			enabled = actionInfo != null;

			if (_actionInfo)
			{
				numColumns = getNumColumns(actionInfo.numFrames);
				layers = actionInfo.layersVectorList;
				_actionInfo.onSelectedFramesChange.add(onSelectedFramesChange);
				onSelectedFramesChange(null);
				onCurrentFrameChange(objectInfo);
			}
		}

		/**
		 * 更新当前选中的帧
		 * @param trigger
		 *
		 */
		private function onSelectedFramesChange(trigger:Object):void
		{
			if (trigger == this)
			{
				return;
			}
			const frames:Vector.<FrameInfoEditable> = actionInfo.selectedFrames;
			var cells:Vector.<CellPosition> = new Vector.<CellPosition>;

			for (var i:int = 0, n:int = frames.length; i < n; i++)
			{
				cells.push(new CellPosition(frames[i].layerIndex, frames[i].index));
			}
			selectedCells = cells;
		}

		/**
		 * 更新当前播放的帧
		 * @param target
		 *
		 */
		private function onCurrentFrameChange(target:ObjectInfo):void
		{
			framesGrid.currentFrame = objectInfo.currentFrame;
		}

		/**
		 * 获取当前编辑的 ObjectInfoEditable<br>
		 * 如果没有 avatarDoc，则返回 null
		 * @return
		 *
		 */
		[Inline]
		final protected function get objectInfo():ObjectInfoEditable
		{
			return avatarDoc ? avatarDoc.object : null;
		}

		/**
		 * 获得要创建的列数
		 * @param numFrames
		 * @return
		 *
		 */
		private function getNumColumns(numFrames:int):int
		{
			return ceilTo(numFrames, 150);
		}
	}
}
