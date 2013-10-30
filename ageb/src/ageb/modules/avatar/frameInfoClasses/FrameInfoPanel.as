package ageb.modules.avatar.frameInfoClasses
{
	import ageb.modules.ae.ActionInfoEditable;
	import ageb.modules.ae.FrameInfoEditable;

	/**
	 * 帧属性面板<br>
	 * 根据帧图层类型包含了若干子面板
	 * @author zhanghaocong
	 *
	 */
	public class FrameInfoPanel extends FrameInfoPanelTemplate
	{
		/**
		 * 创建一个新的 FrameInfoPanel
		 *
		 */
		public function FrameInfoPanel()
		{
			super();
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
				actionInfo.onSelectedFramesChange.remove(onSelectedFramesChange);
			}
			super.actionInfo = value;

			if (actionInfo)
			{
				actionInfo.onSelectedFramesChange.add(onSelectedFramesChange);
			}
			onSelectedFramesChange(null);
		}

		/**
		 * 选择帧时的回调
		 * @param trigger
		 *
		 */
		private function onSelectedFramesChange(trigger:Object):void
		{
			if (trigger == this)
			{
				return;
			}
			// 新的选中
			const frames:Vector.<FrameInfoEditable> = actionInfo ? actionInfo.selectedFrames : null;

			// 长度为 0 无选中
			if (!frames || frames.length == 0)
			{
				// 选择最后一个（也就是 AvatarContent）
				panels.selectedIndex = panels.length - 1;
			}
			else
			{
				// 我们约定类型就是子面板索引
				panels.selectedIndex = frames[0].keyframe.type;
			}
			// 填充新数据
			currentPanel.frames = frames;
			currentPanel.keyframes = actionInfo ? actionInfo.selectedKeyframes : null;
			currentPanel.isCrossLayer = actionInfo ? actionInfo.isCrossLayer : false;
			title = currentPanel.label;
		}

		/**
		 * 获得当前子面板
		 * @return
		 *
		 */
		protected function get currentPanel():FrameInfoPanelContent
		{
			return panels.selectedChild as FrameInfoPanelContent;
		}
	}
}
