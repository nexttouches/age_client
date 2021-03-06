package ageb.modules.ae
{
	import flash.filesystem.File;
	import flash.geom.Vector3D;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import age.data.Box;
	import age.data.LayerType;
	import age.data.RegionInfo;
	import age.data.SceneInfo;
	import nt.assets.AssetConfig;
	import nt.lib.reflect.Type;
	import nt.lib.util.assert;
	import org.apache.flex.collections.VectorList;
	import org.osflash.signals.Signal;

	/**
	 * 可编辑的 SceneInfo
	 * @author zhanghaocong
	 *
	 */
	public class SceneInfoEditable extends SceneInfo implements IParent
	{
		/**
		 * 固定的，可以重复使用的空列表<br>
		 * 用来表示没有任何选中
		 */
		private static const EMPTY:Vector.<ISelectableInfo> = new Vector.<ISelectableInfo>(0, true);

		/**
		 * 尺寸变化时触发
		 */
		public var onSizeChange:Signal = new Signal();

		/**
		 * 网格分辨率变化时触发
		 */
		public var onGridResolutionChange:Signal = new Signal();

		/**
		 * 每个格子大小
		 */
		public var gridCellSize:Vector3D;

		/**
		 * 格子值变化时触发<br>
		 * 正确的签名应为<br>
		 * function (x:int, y:int, value:int):void;
		 */
		public var onGridCellChange:Signal = new Signal(int, int, int);

		/**
		 * 图层列表发生变化时（添加 / 删除）触发
		 */
		public var onLayersChange:Signal = new Signal();

		/**
		 * 供编辑器用的图层列表数组<br>
		 * 可以直接绑定到 List 等控件上
		 */
		public var layersVectorList:VectorList;

		/**
		 * 供编辑器用的区域列表数组<br>
		 * 可以直接绑定到 List 等控件上
		 */
		public var regionsVectorList:VectorList;

		/**
		 * 创建一个新的 SceneInfoEditable
		 * @param raw
		 *
		 */
		public function SceneInfoEditable(raw:Object = null)
		{
			super(raw);

			if (raw)
			{
				gridCellSize = new Vector3D(width / gridResolution.x, 0, height / gridResolution.z);
				layersVectorList = new VectorList(layers);
				layersVectorList.addEventListener(CollectionEvent.COLLECTION_CHANGE, layersVectorList_onCollectionChange);
				// 默认选中角色层
				selectedLayersIndices.push(charLayerIndex);
				// 关联 regionsArrayList
				regionsVectorList = new VectorList(regions);
				validate();
			}
		}

		protected function layersVectorList_onCollectionChange(event:CollectionEvent):void
		{
			if (event.kind == CollectionEventKind.RESET)
			{
				// reset 时需要同步
				layers = layersVectorList.source;
			}
		}

		/**
		 * 验证数据有效性
		 *
		 */
		final private function validate():void
		{
			assert(charLayerIndex < layers.length && layers[charLayerIndex], "charLayerIndex 的图层不存在");
			assert(layers[charLayerIndex].type == LayerType.OBJECT, "charLayerIndex 的图层 type 必须为 LayerType.OBJECT");
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function get layerInfoClass():Class
		{
			return LayerInfoEditable;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function get regionInfoClass():Class
		{
			return RegionInfoEditable;
		}

		/**
		 * 设置地图的宽高，然后发送 onSizeChange
		 * @param size
		 *
		 */
		public function setSize(size:Box):void
		{
			this.size = size;
			width = size.width;
			height = size.height;
			depth = size.depth;
			onSizeChange.dispatch();
		}

		/**
		 * 设置地图的网格宽高
		 * @param gridResolution 新的网格分辨率
		 * @param grids 可选，要填充的网格数据；默认是空的网格
		 *
		 */
		public function setGridResolution(gridResolution:Vector3D, grids:Array = null):void
		{
			this.gridResolution = gridResolution;
			gridCellSize = new Vector3D(width / gridResolution.x, 0, height / gridResolution.z);

			if (grids == null)
			{
				resetGridCells();
			}
			else
			{
				this.grids = grids;
			}
			onGridResolutionChange.dispatch();
		}

		/**
		 * 重置网格
		 *
		 */
		private function resetGridCells():void
		{
			grids = new Array(gridResolution.z);

			for (var i:int = 0; i < gridResolution.z; i++)
			{
				grids[i] = new Array(gridResolution.x);

				for (var j:int = 0; j < gridResolution.x; j++)
				{
					grids[i][j] = 1;
				}
			}
		}

		/**
		 * 设置网格值
		 * @param x
		 * @param y
		 * @param value
		 *
		 */
		public function setGridCell(x:int, y:int, value:int):void
		{
			if (grids[y][x] != value)
			{
				grids[y][x] = value;
				onGridCellChange.dispatch(x, y, value);
			}
		}

		/**
		 * 根据 x z 获得网格值
		 * @param x
		 * @param z
		 * @return
		 *
		 */
		public function getGridCell(x:int, z:int):int
		{
			return grids[z][x];
		}

		/**
		 * 供编辑器用的当前选中图层的列表<br>
		 * 可以直接绑到 List 等控件上
		 */
		public var selectedLayersIndices:Vector.<int> = new Vector.<int>;

		/**
		 * selectedLayersIndices 发生变化时广播<br>
		 * 正确的回调签名是：<br>
		 * function (trigger:Object):void;<br>
		 * 其中 trigger 表示当前变化由哪个对象触发
		 */
		public var onSelectedLayersIndicesChange:Signal = new Signal(Object);

		/**
		 * 供编辑器用的已选中的对象列表<br>
		 * 该列表里的所有对象都在同一图层之中
		 */
		public var selectedObjects:Vector.<ISelectableInfo> = new Vector.<ISelectableInfo>;

		/**
		 * <code>selectedObjects</code> 发生变化时广播
		 * 正确的回调签名是：<br>
		 * <code>function (trigger:Object):void;</code><br>
		 * 其中 <code>trigger</code> 表示当前变化由哪个对象触发<br>
		 * 通过判断 <code>trigger</code>，可以避免循环调用
		 */
		public var onSelectedObjectsChange:Signal = new Signal(Object);

		/**
		 * 设置或获取第一个选中的对象<br>
		 * 如果没有选中的对象则返回 null
		 * @return
		 *
		 */
		public function get selectedObject():ISelectableInfo
		{
			if (selectedObjects.length > 0)
			{
				return selectedObjects[0];
			}
			return null;
		}

		public function set selectedObject(value:ISelectableInfo):void
		{
			if (!value)
			{
				setSelectedObjects(EMPTY, this);
				return;
			}
			setSelectedObjects(new <ISelectableInfo>[ value ], this);
		}

		/**
		 * 设置选中项，然后广播 onSelectedObjectsChange
		 * @param objects 要选中的对象，可以是 Array 或者 Vector，要求所有元素都实现 ISelectableInfo 接口
		 * @param trigger 可选，设置 trigger，默认是所在 SceneInfoEditable 本身
		 *
		 */
		public function setSelectedObjects(objects:*, trigger:Object = null):void
		{
			// 临时变量
			var o:ISelectableInfo;

			// 整理参数
			if (!objects)
			{
				objects = EMPTY;
			}
			else if (!(objects is Vector.<ISelectableInfo>))
			{
				objects = Vector.<ISelectableInfo>(objects);
			}
			else
			{
				objects = objects.concat();
			}

			if (!trigger)
			{
				trigger = this;
			}

			// 旧选中项设 false
			for each (o in selectedObjects)
			{
				if (objects.indexOf(o) == -1)
				{
					o.isSelected = false;
				}
			}
			// 赋新值
			selectedObjects = objects;

			for each (o in objects)
			{
				o.isSelected = true;
			}
			onSelectedObjectsChange.dispatch(trigger);
		}

		/**
		 * 获得下一个区域 ID
		 * @return
		 *
		 */
		public function getNextRegionID():int
		{
			// 当前没有任何区域，返回 0
			if (regions.length == 0)
			{
				return 0;
			}
			var ids:Array = [];

			for each (var r:RegionInfo in regions)
			{
				ids.push(r.id);
			}
			ids.sort(Array.NUMERIC);

			for (var i:int = 0; i < ids.length - 1; i++)
			{
				// 发现当前和下一个元素不连续
				// 返回第 i 个元素的值 + 1
				if (ids[i] + 1 != ids[i + 1])
				{
					return ids[i] + 1;
				}
			}
			// 已经查询到最后了
			// 前面都是连续的
			return ids[ids.length - 1] + 1;
		}

		/**
		 * 添加一个区域
		 * @param r
		 *
		 */
		public function addRegion(r:RegionInfo):void
		{
			// 已属其他 SceneInfo，要先删除
			if (r.parent)
			{
				SceneInfoEditable(r.parent).removeRegion(r);
			}
			r.parent = this;
			regionsVectorList.addItem(r);
		}

		/**
		 * 删除一个区域
		 * @param r
		 *
		 */
		public function removeRegion(r:RegionInfo):void
		{
			assert(r.parent == this, "RegionInfo.parent 不是 this");
			r.parent = null;
			regionsVectorList.removeItem(r);
		}

		/**
		 * 添加一个子对象<br>
		 * 目前支持 RegionInfo
		 * @param child
		 *
		 */
		public function add(child:IChild):void
		{
			if (child is RegionInfo)
			{
				return addRegion(child as RegionInfo);
			}
			throw new ArgumentError("不支持的 child: " + Type.of(child).fullname);
		}

		/**
		 * 删除一个子对象<br>
		 * 目前支持 RegionInfo
		 * @param child
		 *
		 */
		public function remove(child:IChild):void
		{
			if (child is RegionInfo)
			{
				return removeRegion(child as RegionInfo);
			}
			throw new ArgumentError("不支持的 child: " + Type.of(child).fullname);
		}

		/**
		 * 根据索引获得图层
		 * @param index
		 * @return
		 *
		 */
		public function getLayerAt(index:int):LayerInfoEditable
		{
			return layers[index] as LayerInfoEditable;
		}

		/**
		 * 期待的文件夹，也就是说该场景的所有资源应在该目录下
		 * @return
		 *
		 */
		public function get expectFolder():File
		{
			return new File(AssetConfig.root + "/" + SceneInfo.folder + "/" + id);
		}
	}
}
