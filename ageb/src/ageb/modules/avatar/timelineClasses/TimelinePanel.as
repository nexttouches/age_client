package ageb.modules.avatar.timelineClasses
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import spark.components.Button;
	import spark.components.ButtonBar;
	import spark.components.ComboBox;
	import spark.components.TextInput;
	import spark.events.IndexChangeEvent;
	import age.data.ObjectInfo;
	import ageb.ageb_internal;
	import ageb.prompt;
	import ageb.components.IntInput;
	import ageb.modules.ae.ActionInfoEditable;
	import ageb.modules.ae.FrameInfoEditable;
	import ageb.modules.avatar.op.AddAction;
	import ageb.modules.avatar.op.AddFrameLayer;
	import ageb.modules.avatar.op.ChangeActionFPS;
	import ageb.modules.avatar.op.RemoveAction;
	import ageb.modules.avatar.op.RemoveFrameLayer;
	import ageb.modules.avatar.op.RenameAction;
	import ageb.modules.avatar.op.SelectAction;
	import ageb.modules.avatar.supportClasses.AvatarDocumentPanel;
	import ageb.modules.document.Document;
	import nt.lib.util.assert;
	import ageb.modules.avatar.op.ChangeActionAtlas;

	/**
	 * 时间轴面板
	 * @author zhanghaocong
	 *
	 */
	public class TimelinePanel extends AvatarDocumentPanel
	{

		[SkinPart(required="true")]
		public var actionsField:ComboBox;

		[SkinPart(required="true")]
		public var addActionButton:Button;

		[SkinPart(required="true")]
		public var removeActionButton:Button;

		[SkinPart(required="true")]
		public var renameActionButton:Button;

		[SkinPart(required="true")]
		public var prevFrameButton:Button;

		[SkinPart(required="true")]
		public var playPauseButton:Button;

		[SkinPart(required="true")]
		public var nextFrameButton:Button;

		[SkinPart(required="true")]
		public var currentFrameField:IntInput;

		[SkinPart(required="true")]
		public var fpsField:IntInput;

		[SkinPart(required="true")]
		public var currentTimeField:TextInput;

		[SkinPart(required="true")]
		public var directionButtons:ButtonBar;

		[SkinPart(required="true")]
		public var framesDataGrid:FramesDataGrid;

		[SkinPart(required="true")]
		public var layerList:FrameLayerList;

		[SkinPart(required="true")]
		public var addLayerButton:Button;

		[SkinPart(required="true")]
		public var removeLayerButton:Button;

		[SkinPart(required="true")]
		public var atlasField:TextInput;

		[SkinPart(required="true")]
		public var setAtlasAsActionNameButton:Button;

		/**
		 * 创建一个新的 TimelinePanel
		 *
		 */
		public function TimelinePanel()
		{
			super();
			setStyle("skinClass", TimelinePanelSkin);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			framesDataGrid.onVerticalScrollPositionChange.add(framesGrid_onVerticalScrollPositionChange);
			actionsField.addEventListener(IndexChangeEvent.CHANGE, actionsField_onChange);
			actionsField.addEventListener(IndexChangeEvent.CHANGING, actionsField_onChanging);
			nextFrameButton.addEventListener(MouseEvent.CLICK, frameButton_onClick);
			playPauseButton.addEventListener(MouseEvent.CLICK, frameButton_onClick);
			prevFrameButton.addEventListener(MouseEvent.CLICK, frameButton_onClick);
			currentFrameField.addEventListener(Event.CHANGE, currentFrameField_onClick);
			directionButtons.addEventListener(IndexChangeEvent.CHANGE, directionButtons_onChange);
			layerList.addEventListener(MouseEvent.CLICK, layersField_onClick);
			layerList.onMouseWheel.add(layersField_onMouseWheel);
			fpsField.addEventListener(Event.CHANGE, fpsField_onChange);
			addLayerButton.addEventListener(MouseEvent.CLICK, addLayerButton_onClick);
			removeLayerButton.addEventListener(MouseEvent.CLICK, removeLayerButton_onClick);
			addActionButton.addEventListener(MouseEvent.CLICK, addActionButton_onClick);
			removeActionButton.addEventListener(MouseEvent.CLICK, removeActionButton_onClick);
			renameActionButton.addEventListener(MouseEvent.CLICK, renameActionButton_onClick);
			setAtlasAsActionNameButton.addEventListener(MouseEvent.CLICK, setAtlasAsActionNameButton_onClick);
		}

		/**
		 * @private
		 *
		 */
		protected function setAtlasAsActionNameButton_onClick(event:MouseEvent):void
		{
			new ChangeActionAtlas(doc, atlasField.text).execute();
		}

		/**
		 * @private
		 * @param event
		 *
		 */
		protected function renameActionButton_onClick(event:MouseEvent):void
		{
			prompt(function(newName:String):void
			{
				if (newName)
				{
					new RenameAction(doc, actionInfo, newName).execute();
				}
			}, "动作改名", "新名字", actionInfo.name);
		}

		/**
		 * @private
		 * @param event
		 *
		 */
		protected function removeActionButton_onClick(event:MouseEvent):void
		{
			new RemoveAction(doc, actionInfo).execute();
		}

		/**
		 * @private
		 * @param event
		 *
		 */
		protected function addActionButton_onClick(event:MouseEvent):void
		{
			prompt(function(newName:String):void
			{
				if (newName)
				{
					new AddAction(doc, newName).execute();
				}
			}, "新建动作", "动作名");
		}

		/**
		 * @private
		 *
		 */
		private function layersField_onMouseWheel():void
		{
			framesDataGrid.grid.verticalScrollPosition = layerList.scroller.viewport.verticalScrollPosition;
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

			if (layerList.selectedIndex != -1)
			{
				for each (var rowIndex:int in layerList.selectedIndices)
				{
					frames = frames.concat(Vector.<FrameInfoEditable>(actionInfo.layers[rowIndex].frames));
				}
			}

			if (actionInfo)
			{
				actionInfo.ageb_internal::setSelectedFrames(frames, this);
			}
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
			callLater(new SelectAction(doc, ActionInfoEditable(actionsField.selectedItem).name).execute);
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
			new RemoveFrameLayer(doc, layerList.selectedIndices).execute();
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
				framesDataGrid.avatarDoc = null;
				// 当前动作
				actionInfo = null;
			}
			super.doc = value;

			if (avatarDoc)
			{
				assert(avatarDoc.avatar == objectInfo.avatarInfo);
				actionsField.dataProvider = avatarDoc.avatar.actionsVectorList;
				framesDataGrid.avatarDoc = avatarDoc;
				objectInfo.onCurrentFrameChange.add(onCurrentFrameChange);
			}
			onCurrentFrameChange(objectInfo);
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
				actionsField.textInput.text = null;
				// 当前帧
				currentFrameField.maximum = 0;
				// FPS
				fpsField.value = 0;
				// 图层列表
				layerList.dataProvider = null;
				// 一些事件
				actionInfo.onSelectedFramesChange.remove(onSelectedFramesChange);
				actionInfo.onFPSChange.remove(onFPSChange);
				actionInfo.onAtlasChange.remove(onAtalsChange);
			}
			super.actionInfo = value;

			if (actionInfo)
			{
				// 更新选中项
				actionsField.selectedItem = actionInfo;
				// 当前帧
				currentFrameField.maximum = actionInfo.numFrames - 1; // currentFrame 从 0  开始
				// 图层列表
				layerList.dataProvider = actionInfo.layersVectorList;
				// 一些事件
				actionInfo.onSelectedFramesChange.add(onSelectedFramesChange);
				onSelectedFramesChange(null);
				actionInfo.onFPSChange.add(onFPSChange);
				actionInfo.onAtlasChange.add(onAtalsChange);
			}
			const hasAction:Boolean = actionInfo != null;
			fpsField.enabled = hasAction;
			renameActionButton.enabled = hasAction;
			removeActionButton.enabled = hasAction;
			removeLayerButton.enabled = hasAction;
			addLayerButton.enabled = hasAction;
			onFPSChange();
			onAtalsChange();
		}

		private function onAtalsChange():void
		{
			if (actionInfo)
			{
				atlasField.text = actionInfo.atlas;
			}
			else
			{
				atlasField.text = "";
			}
		}

		/**
		 * @private
		 *
		 */
		private function onFPSChange():void
		{
			if (actionInfo)
			{
				fpsField.value = actionInfo.fps;
			}
			else
			{
				fpsField.value = 0;
			}
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
			layerList.selectedIndices = selectedIndices;
		}

		/**
		 * 此为同步滚动条位置
		 * @param value
		 *
		 */
		private function framesGrid_onVerticalScrollPositionChange(value:Number):void
		{
			layerList.dataGroup.verticalScrollPosition = value;
		}

		/**
		 * 更新当前播放的帧
		 * @param target
		 *
		 */
		private function onCurrentFrameChange(target:ObjectInfo):void
		{
			if (actionInfo)
			{
				currentFrameField.value = currentFrame;
				currentTimeField.text = (currentFrame * actionInfo.defautFrameDuration).toFixed(3) + "s";
			}
			else
			{
				currentFrameField.value = 0;
				currentTimeField.text = (0).toFixed(3) + "s";
			}
		}
	}
}
