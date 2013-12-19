package ageb.modules.ae
{
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	import age.data.ActionInfo;
	import age.data.AvatarInfo;
	import age.data.FrameLayerInfo;
	import ageb.ageb_internal;
	import nt.assets.AssetConfig;
	import nt.lib.util.assert;
	import org.apache.flex.collections.VectorList;
	import org.osflash.signals.Signal;
	use namespace ageb_internal;

	/**
	 * 可编辑的动作信息
	 * @author zhanghaocong
	 *
	 */
	public class ActionInfoEditable extends ActionInfo
	{
		/**
		 * 空列表
		 */
		private static const EMPTY:Vector.<FrameInfoEditable> = new Vector.<FrameInfoEditable>(0, true);

		/**
		 * 所有图层列表<br>
		 * 可以绑定到 spark 组件上
		 */
		public var layersVectorList:VectorList;

		/**
		 * 创建一个新的 ActionInfoEditable
		 * @param raw
		 *
		 */
		public function ActionInfoEditable(raw:Object = null)
		{
			super(raw);
			layersVectorList = new VectorList(layers);
		}

		/**
		 * 添加图层时广播
		 */
		public var onAddLayer:Signal = new Signal(FrameLayerInfoEditable);

		/**
		 * 添加图层
		 * @param info
		 *
		 */
		public function addLayer(info:FrameLayerInfo):void
		{
			info.parent = this;
			layersVectorList.addItem(info);
			updateLayerFlags();
			onAddLayer.dispatch(info);
			onLayersChange.dispatch();
		}

		/**
		 * 删除图层时调用
		 */
		public var onRemoveLayer:Signal = new Signal(FrameLayerInfo);

		/**
		 * 删除图层
		 * @param info
		 *
		 */
		public function removeLayer(info:FrameLayerInfo):void
		{
			assert(info.parent == this, "info.parent 不为当前动作");
			layersVectorList.removeItem(info);
			info.parent = null;
			updateLayerFlags();
			onRemoveLayer.dispatch(info);
		}

		/**
		 * layers 整个数组被替换时广播
		 */
		public var onLayersChange:Signal = new Signal()

		/**
		 * 设置图层
		 * @param newLayers
		 * @return
		 *
		 */
		public function setLayers(newLayers:Vector.<FrameLayerInfo>):void
		{
			layers = newLayers.concat();
			// WORKAROUND:
			// 直接设置 layersVectorList.source = layers 会导致组件刷新出问题
			// 这里先 new 一个新的 VectorList
			layersVectorList = new VectorList(layers);
			updateLayerFlags();
			onLayersChange.dispatch();
			updateNumFrames();
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override protected function get frameLayerInfoClass():Class
		{
			return FrameLayerInfoEditable;
		}

		private var _isCrossLayer:Boolean;

		/**
		 * 选中的帧是否跨图层
		 * @return
		 *
		 */
		public function get isCrossLayer():Boolean
		{
			return _isCrossLayer;
		}

		private var _selectedKeyframes:Vector.<FrameInfoEditable>;

		/**
		 * 选中了的关键帧（数组）
		 */
		public function get selectedKeyframes():Vector.<FrameInfoEditable>
		{
			return _selectedKeyframes;
		}

		/**
		 * 选中了的（第一个）关键帧
		 * @return
		 *
		 */
		public function get selectedKeyframe():FrameInfoEditable
		{
			return _selectedFrames ? _selectedFrames[0] : null;
		}

		/**
		 * 更新选中了的关键帧
		 *
		 */
		private function updateSelectedKeyframes():void
		{
			_selectedKeyframes = null;
			const uniqueFrames:Dictionary = new Dictionary();
			const uniqueLayers:Dictionary = new Dictionary();

			for (var i:int = 0; i < _selectedFrames.length; i++)
			{
				uniqueFrames[_selectedFrames[i].keyframe] = true;
				uniqueLayers[_selectedFrames[i].keyframe.layerIndex] = true;
			}

			for (var key:* in uniqueFrames)
			{
				if (!_selectedKeyframes)
				{
					_selectedKeyframes = new Vector.<FrameInfoEditable>();
				}
				_selectedKeyframes.push(key as FrameInfoEditable);
			}

			if (_selectedKeyframes)
			{
				_selectedKeyframes.sort(compareFrame);
			}
			else
			{
				_selectedKeyframes = EMPTY;
			}
			_isCrossLayer = count(uniqueLayers) > 1;
		}

		/**
		 * selectedFrames 变化时广播
		 */
		public var onSelectedFramesChange:Signal = new Signal(Object);

		private var _selectedFrames:Vector.<FrameInfoEditable> = new Vector.<FrameInfoEditable>;

		/**
		 * 设置或获取选中帧<br>
		 * 请注意：这里的读写操作都是<strong>副本</strong>
		 * @return
		 *
		 */
		public function get selectedFrames():Vector.<FrameInfoEditable>
		{
			return _selectedFrames.concat();
		}

		public function set selectedFrames(value:Vector.<FrameInfoEditable>):void
		{
			setSelectedFrames(value, this);
		}

		/**
		 * 设置选中的帧
		 * @param value 新选中帧
		 * @param trigger 本次改动由谁触发
		 * @param isForceChange 是否不比较数组，强制刷新
		 */
		ageb_internal function setSelectedFrames(frames:Vector.<FrameInfoEditable>, trigger:Object, isForceChange:Boolean = false):Boolean
		{
			// 默认值
			if (!trigger)
			{
				trigger = this;
			}

			// 传入 null，我们改成空数组
			if (!frames)
			{
				frames = EMPTY;
			}
			// 比较新旧值
			const isChange:Boolean = isForceChange || !isEqual(frames, _selectedFrames);

			// 设置 _selectedFrames 为 frames 的副本
			if (isChange)
			{
				_selectedFrames = frames.concat();
				updateSelectedKeyframes();
				onSelectedFramesChange.dispatch(trigger);
			}
			// OK
			return isChange;
		}

		/**
		 * 检查 ab 数组是否相等
		 * @param a
		 * @param b
		 * @return
		 *
		 */
		private static function isEqual(a:Vector.<FrameInfoEditable>, b:Vector.<FrameInfoEditable>):Boolean
		{
			// 长度不同肯定不同
			if (a.length != b.length)
			{
				return false;
			}

			// 长度相同的，我们逐个检查
			for (var i:int = 0, n:int = a.length; i < n; i++)
			{
				// a 有任何一项不在 b 的，视为不同
				if (a.indexOf(b[i]) == -1)
				{
					return false;
				}
			}
			return true;
		}

		/**
		 * 2 个帧的排序方法
		 * @param a
		 * @param b
		 * @return
		 *
		 */
		private static function compareFrame(a:FrameInfoEditable, b:FrameInfoEditable):int
		{
			if (a.layerIndex < b.layerIndex)
			{
				return -1;
			}
			else if (a.layerIndex == b.layerIndex)
			{
				if (a.index < b.index)
				{
					return -1;
				}
				else if (a.index == b.index)
				{
					return 0;
				}
				else
				{
					return 1;
				}
			}
			else
			{
				return 1;
			}
		}

		/**
		 * fps 变化时广播
		 */
		public var onFPSChange:Signal = new Signal();

		/**
		 * 设置 fps
		 * @param value
		 *
		 */
		public function setFPS(value:int):void
		{
			if (fps == value)
			{
				return;
			}
			fps = value;
			onFPSChange.dispatch();
		}

		/**
		 * 期待的文件夹，也就是说该动作的所有资源应在该目录下
		 * @return
		 *
		 */
		public function get expectFolder():File
		{
			return new File(AssetConfig.root + "/" + AvatarInfo.folder + "/" + parent.id + "/" + name);
		}

		/**
		 * 根据 index 获得指定的图层，如果 index 过大，将返回 null
		 * @param index
		 * @return null 或实际图层
		 *
		 */
		public function getLayerAt(index:int):FrameLayerInfoEditable
		{
			if (index < layers.length)
			{
				return layers[index] as FrameLayerInfoEditable;
			}
			return null;
		}

		/**
		 * name 发生变化时广播
		 */
		public var onNameChange:Signal = new Signal();

		/**
		 * 设置 name
		 * @param value
		 *
		 */
		public function setName(value:String):void
		{
			if (value != name)
			{
				name = value;
				onNameChange.dispatch();
			}
		}

		/**
		 * atlas 变化时广播
		 */
		public var onAtlasChange:Signal = new Signal();

		/**
		 * 设置 atlas
		 * @param value
		 *
		 */
		public function setAtlas(value:String):void
		{
			if (value != atlas)
			{
				_atlas = value;
				onAtlasChange.dispatch();
			}
		}
	}
}
