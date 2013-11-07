package ageb.modules.ae
{
	import age.data.ActionInfo;
	import age.data.FrameInfo;
	import age.data.FrameLayerInfo;
	import age.data.FrameLayerType;
	import org.osflash.signals.Signal;

	/**
	 * 可编辑的 FrameLayerInfo
	 * @author kk
	 *
	 */
	public class FrameLayerInfoEditable extends FrameLayerInfo
	{
		/**
		 * 创建一个新的 FrameLayerInfoEditable
		 * @param raw
		 * @param parent
		 *
		 */
		public function FrameLayerInfoEditable(raw:Object = null, parent:ActionInfo = null)
		{
			super(raw, parent);
			onFramesChange.add(reloadAssets);
			isTextureUseThumb = false;
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override protected function get frameInfoClass():Class
		{
			return FrameInfoEditable;
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function addFrameFromRaw(raw:Object):void
		{
			super.addFrameFromRaw(raw);
			const info:FrameInfoEditable = lastFrame;
			info.onSoundChange.add(reloadAssets);
			info.onTextureChange.add(reloadAssets);
			info.onIsKeyframeChange.add(reloadAssets);
		}

		/**
		 * 重新加载所有 assets
		 *
		 */
		private function reloadAssets(... ignored):void
		{
			addAnimationAssets();
			addSoundAssets();
			load();
		}

		/**
		 * 添加帧时调用<br>
		 * 正确的签名是 function (info:FrameInfoEditable, index:int):void;
		 */
		public var onAddFrame:Signal = new Signal(FrameInfoEditable, int);

		/**
		 * 插入帧到最后
		 * @param info
		 *
		 */
		public function addFrame(info:FrameInfoEditable):void
		{
			addFrameAt(info, frames.length);
		}

		/**
		 * 插入帧到指定位置，后续帧会往后移动
		 * @param info
		 * @param index
		 *
		 */
		public function addFrameAt(info:FrameInfoEditable, index:int):void
		{
			if (index < 0 || index > frames.length)
			{
				throw new RangeError("index 不能为：" + index);
			}

			// 优化：使用 push
			if (index == frames.length)
			{
				frames.push(info);
			}
			else
			{
				frames.splice(index, 0, info);
			}
			info.parent = this;
			info.onSoundChange.add(reloadAssets);
			info.onTextureChange.add(reloadAssets);
			info.onIsKeyframeChange.add(reloadAssets);
			onAddFrame.dispatch(info, index);
		}

		/**
		 * 替换帧时广播<br>
		 * 正确的签名是 function (oldInfo:FrameInfoEditable, newInfo:FrameInfoEditable, index:int):void;
		 */
		public var onReplaceFrame:Signal = new Signal(FrameInfoEditable, FrameInfoEditable, int);

		/**
		 * 替换指定位置的帧
		 * @param info
		 * @param index
		 *
		 */
		public function replaceFrameAt(info:FrameInfoEditable, index:int):void
		{
			if (index < 0 || index > frames.length)
			{
				throw new RangeError("index 不能为：" + index);
			}
			const oldInfo:FrameInfoEditable = frames[index] as FrameInfoEditable;
			oldInfo.onTextureChange.remove(reloadAssets);
			oldInfo.onSoundChange.remove(reloadAssets);
			oldInfo.onIsKeyframeChange.remove(reloadAssets);
			oldInfo.parent = null;
			frames[index] = info;
			info.parent = this;
			info.onTextureChange.add(reloadAssets);
			info.onIsKeyframeChange.add(reloadAssets);
			info.onSoundChange.add(reloadAssets);
			onReplaceFrame.dispatch(oldInfo, info, index);
		}

		/**
		 * 删除帧时调用<br>
		 * 正确的签名是 function (info:FrameInfoEditable, index:int):void;
		 * @return
		 *
		 */
		public var onRemoveFrame:Signal = new Signal(FrameInfoEditable, int);

		/**
		 * frames 属性发生变化时广播<br>
		 * 通常由外部调用
		 */
		public var onFramesChange:Signal = new Signal(FrameLayerInfoEditable);

		/**
		 * 最后一帧
		 * @return
		 *
		 */
		public function get lastFrame():FrameInfoEditable
		{
			return frames[frames.length - 1] as FrameInfoEditable;
		}

		/**
		 * 第一帧
		 * @return
		 *
		 */
		public function get firstFrame():FrameInfoEditable
		{
			return frames[0] as FrameInfoEditable;
		}

		/**
		 * 提示当前图层的 frames 已变化
		 *
		 */
		public function notifyFramesChange():void
		{
			onFramesChange.dispatch(this);
		}

		/**
		 * 删除帧
		 * @param info
		 *
		 */
		public function removeFrame(info:FrameInfoEditable):void
		{
			removeFrameAt(frames.indexOf(info));
		}

		/**
		 * 删除指定位置的帧，后续帧会连上来
		 * @param index
		 *
		 */
		public function removeFrameAt(index:int):void
		{
			if (index < 0 || index >= frames.length)
			{
				throw new RangeError("index 不能为：" + index);
			}
			const info:FrameInfoEditable = frames.splice(index, 1)[0];
			info.parent = null;
			info.onSoundChange.remove(reloadAssets);
			info.onTextureChange.remove(reloadAssets);
			info.onIsKeyframeChange.remove(reloadAssets);
			onRemoveFrame.dispatch(info, index);
		}

		/**
		 * 根据索引获得指定的 FrameInfoEditable
		 * @param index
		 * @return 如果 numFrames > index，返回实际帧，否则返回 null
		 *
		 */
		public function getFrameInfoAt(index:int):FrameInfoEditable
		{
			if (numFrames > index)
			{
				return frames[index] as FrameInfoEditable;
			}
			return null;
		}

		/**
		 * 替换 frames 为 newFrames
		 * @param newFrames
		 *
		 */
		public function setFrames(newFrames:Vector.<FrameInfo>):void
		{
			var i:int, n:int, info:FrameInfoEditable;

			for (i = 0, n = frames.length; i < n; i++)
			{
				info = frames[i] as FrameInfoEditable;
				info.parent = null;
				info.onSoundChange.remove(reloadAssets);
				info.onTextureChange.remove(reloadAssets);
				info.onIsKeyframeChange.remove(reloadAssets);
			}
			frames = newFrames.concat();

			for (i = 0, n = frames.length; i < n; i++)
			{
				info = frames[i] as FrameInfoEditable;
				info.parent = this;
				info.onSoundChange.add(reloadAssets);
				info.onTextureChange.add(reloadAssets);
				info.onIsKeyframeChange.add(reloadAssets);
			}
			notifyFramesChange();
		}

		/**
		 * name 发生变化时广播
		 */
		public var onNameChange:Signal = new Signal();

		/**
		 * 设置图层名字
		 * @param value
		 *
		 */
		public function setName(value:String):void
		{
			name = value;
			onNameChange.dispatch();
		}

		/**
		 * type 发生变化时广播
		 */
		public var onTypeChange:Signal = new Signal(FrameLayerInfoEditable);

		/**
		 * 设置图层类型<br>
		 * 如果设置成功，将会广播 onTypeChange 和 onFramesChange
		 * @param newType
		 *
		 */
		public function setType(value:int):void
		{
			type = value;
			empty();
			load();
			onTypeChange.dispatch(this);
			onFramesChange.dispatch(this);
		}
	}
}
