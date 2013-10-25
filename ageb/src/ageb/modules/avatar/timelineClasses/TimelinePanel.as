package ageb.modules.avatar.timelineClasses
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import spark.events.IndexChangeEvent;
	import age.assets.ObjectInfo;
	import ageb.ageb_internal;
	import ageb.modules.ae.ActionInfoEditable;
	import ageb.modules.ae.FrameInfoEditable;
	import ageb.modules.avatar.op.AddFrameLayer;
	import ageb.modules.avatar.op.ChangeActionFPS;
	import ageb.modules.avatar.op.RemoveFrameLayer;
	import ageb.modules.avatar.op.SelectAction;
	import ageb.modules.document.Document;
	import nt.lib.util.assert;

	/**
	 * 时间轴面板
	 * @author zhanghaocong
	 *
	 */
	public class TimelinePanel extends TimelinePanelTemplate
	{
		/**
		 * 创建一个新的 TimelinePanel
		 *
		 */
		public function TimelinePanel()
		{
			super();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			framesGrid.onVerticalScrollPositionChange.add(framesGrid_onVerticalScrollPositionChange);
			actionsField.addEventListener(IndexChangeEvent.CHANGE, actionsField_onChange);
			actionsField.addEventListener(IndexChangeEvent.CHANGING, actionsField_onChanging);
			nextFrameButton.addEventListener(MouseEvent.CLICK, frameButton_onClick);
			playPauseButton.addEventListener(MouseEvent.CLICK, frameButton_onClick);
			prevFrameButton.addEventListener(MouseEvent.CLICK, frameButton_onClick);
			currentFrameField.addEventListener(Event.CHANGE, currentFrameField_onClick);
			directionButtons.addEventListener(IndexChangeEvent.CHANGE, directionButtons_onChange);
			layersField.addEventListener(MouseEvent.CLICK, layersField_onClick);
			layersField.onMouseWheel.add(layersField_onMouseWheel);
			fpsField.addEventListener(Event.CHANGE, fpsField_onChange);
			addLayerButton.addEventListener(MouseEvent.CLICK, addLayerButton_onClick);
			removeLayerButton.addEventListener(MouseEvent.CLICK, removeLayerButton_onClick);
		}

		private function layersField_onMouseWheel():void
		{
			framesGrid.grid.verticalScrollPosition = layersField.scroller.viewport.verticalScrollPosition;
		}

		/**
		 * @private
		 * @param event
		 *
		 */
		protected function fpsField_onChange(event:Event):void
		{
			new ChangeActionFPS(doc, fpsField.value).execute();
		}

		/**
		 * 点击列表任意项等于选择中该图层所有帧
		 * @param event
		 *
		 */
		protected function layersField_onClick(event:MouseEvent):void
		{
			var frames:Vector.<FrameInfoEditable> = new Vector.<FrameInfoEditable>;

			if (layersField.selectedIndex != -1)
			{
				for each (var rowIndex:int in layersField.selectedIndices)
				{
					frames = frames.concat(Vector.<FrameInfoEditable>(actionInfo.layers[rowIndex].frames));
				}
			}
			actionInfo.ageb_internal::setSelectedFrames(frames, this);
		}

		/**
		 * 更换方向
		 * @param event
		 *
		 */
		protected function directionButtons_onChange(event:IndexChangeEvent):void
		{
			objectInfo.direction = directionButtons.selectedItem.value;
		}

		/**
		 * 切换到指定帧
		 * @param event
		 *
		 */
		protected function currentFrameField_onClick(event:Event):void
		{
			objectInfo.gotoAndStop(currentFrameField.value);
		}

		/**
		 * 回放控制
		 * @param event
		 *
		 */
		protected function frameButton_onClick(event:MouseEvent):void
		{
			switch (event.currentTarget)
			{
				case playPauseButton:
				{
					if (objectInfo.isPlaying)
					{
						objectInfo.pause();
					}
					else
					{
						objectInfo.play();
					}
					break;
				}
				case nextFrameButton:
				{
					objectInfo.nextFrame();
					break;
				}
				case prevFrameButton:
				{
					objectInfo.prevFrame();
					break;
				}
				default:
				{
					throw new Error("不该进这里");
					break;
				}
			}
		}

		/**
		 * @private
		 * @param event
		 *
		 */
		protected function actionsField_onChanging(event:IndexChangeEvent):void
		{
			// 拦截不存在的动作
			if (!(actionsField.selectedItem is ActionInfoEditable))
			{
				event.preventDefault();
			}
		}

		/**
		 * 更换渲染的动作
		 * @param event
		 *
		 */
		protected function actionsField_onChange(event:IndexChangeEvent):void
		{
			new SelectAction(doc, ActionInfoEditable(actionsField.selectedItem).name).execute();
		}

		/**
		 * 添加图层
		 * @param event
		 *
		 */
		protected function addLayerButton_onClick(event:MouseEvent):void
		{
			new AddFrameLayer(doc).execute();
		}

		/**
		 * 删除图层
		 * @param event
		 *
		 */
		protected function removeLayerButton_onClick(event:MouseEvent):void
		{
			new RemoveFrameLayer(doc, layersField.selectedIndices).execute();
		}

		/**
		 * 返回 objectInfo.currentFrame
		 * @return
		 *
		 */
		[Inline]
		final protected function get currentFrame():int
		{
			return objectInfo.currentFrame;
		}

		/**
		 * @inheritDoc
		 * @param value
		 *
		 */
		override public function set doc(value:Document):void
		{
			if (avatarDoc)
			{
				objectInfo.onCurrentFrameChange.remove(onCurrentFrameChange);
				// 动作列表
				actionsField.dataProvider = null;
				// 帧网格
				framesGrid.avatarDoc = null;
				// 当前动作
				actionInfo = null;
			}
			super.doc = value;

			if (avatarDoc)
			{
				assert(avatarDoc.avatar == objectInfo.avatarInfo);
				actionsField.dataProvider = avatarDoc.avatar.actionsArrayList;
				framesGrid.avatarDoc = avatarDoc;
				objectInfo.onCurrentFrameChange.add(onCurrentFrameChange);
				onCurrentFrameChange(objectInfo);
			}
		}

		/**
		 * @inheritDoc
		 * @param value
		 *
		 */
		override public function set actionInfo(value:ActionInfoEditable):void
		{
			// 重设
			if (actionInfo)
			{
				// 更新选中项
				actionsField.selectedItem = null;
				// 当前帧
				currentFrameField.maximum = 0;
				// FPS
				fpsField.value = 0;
				// 图层列表
				layersField.dataProvider = null;
				// 一些事件
				actionInfo.onSelectedFramesChange.remove(onSelectedFramesChange);
				actionInfo.onFPSChange.remove(onFPSChange);
			}
			super.actionInfo = value;

			if (actionInfo)
			{
				// 更新选中项
				actionsField.selectedItem = actionInfo;
				// 当前帧
				currentFrameField.maximum = actionInfo.numFrames - 1; // currentFrame 从 0  开始
				// 图层列表
				layersField.dataProvider = actionInfo.layersVectorList;
				// 一些事件
				actionInfo.onSelectedFramesChange.add(onSelectedFramesChange);
				onSelectedFramesChange(null);
				actionInfo.onFPSChange.add(onFPSChange);
				onFPSChange();
			}
		}

		/**
		 * @private
		 *
		 */
		private function onFPSChange():void
		{
			fpsField.value = actionInfo.fps;
		}

		/**
		 * @private
		 *
		 */
		private function onSelectedFramesChange(trigger:Object):void
		{
			if (trigger == this)
			{
				return;
			}
			const frames:Vector.<FrameInfoEditable> = actionInfo.selectedFrames;
			var selectedIndices:Vector.<int> = new Vector.<int>;

			for (var i:int = 0, n:int = frames.length; i < n; i++)
			{
				const layerIndex:int = frames[i].layerIndex;

				if (selectedIndices.indexOf(layerIndex) == -1)
				{
					selectedIndices.push(layerIndex);
				}
			}
			layersField.selectedIndices = selectedIndices;
		}

		/**
		 * 此为同步滚动条位置
		 * @param value
		 *
		 */
		private function framesGrid_onVerticalScrollPositionChange(value:Number):void
		{
			layersField.dataGroup.verticalScrollPosition = value;
		}

		/**
		 * 更新当前播放的帧
		 * @param target
		 *
		 */
		private function onCurrentFrameChange(target:ObjectInfo):void
		{
			currentFrameField.value = currentFrame;
			currentTimeField.text = (currentFrame * actionInfo.defautFrameDuration).toFixed(3) + "s";
		}
	}
}
