package ageb.modules.ae
{
	import mx.collections.ArrayList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import age.assets.LayerInfo;
	import age.assets.LayerType;
	import age.assets.RegionInfo;
	import age.assets.SceneInfo;
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
		 * 网格尺寸变化时触发
		 */
		public var onGridSizeChange:Signal = new Signal();

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
		 * 每个格子的宽度
		 */
		public var gridCellWidth:Number;

		/**
		 * 每个格子的高度
		 */
		public var gridCellHeight:Number;

		/**
		 * 供编辑器用的图层列表数组<br>
		 * 可以直接绑定到 List 等控件上
		 */
		public var layersArrayList:ArrayList = new ArrayList();

		/**
		 * 供编辑器用的区域列表数组<br>
		 * 可以直接绑定到 List 等控件上
		 */
		public var regionsArrayList:VectorList = new VectorList();

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
				gridCellWidth = width / gridWidth;
				gridCellHeight = height / gridHeight;

				// 同步 layers 和 layersArrayList，供组件和编辑时使用
				for (var i:int = 0; i < layers.length; i++)
				{
					layersArrayList.addItem(layers[i]);
				}
				// 我们的 layersArrayList 将会被其他对象改变
				// 内部侦听好事件，以便与 layers 同步
				layersArrayList.addEventListener(CollectionEvent.COLLECTION_CHANGE, layersArrayList_onCollectionChange);
				// 默认选中角色层
				selectedLayersIndices.push(charLayerIndex);
				// 关联 regionsArrayList
				regionsArrayList.source = regions;
				validate();
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
		 * layersArrayList 变化时调用<br>
		 * 负责同步 layers 和 layersArrayList
		 * @param event
		 *
		 */
		protected function layersArrayList_onCollectionChange(event:CollectionEvent):void
		{
			// 删除
			if (event.kind == CollectionEventKind.REMOVE)
			{
				assert(event.items.length == 1);
				layers.splice(event.location, 1);
			}
			// 增加
			else if (event.kind == CollectionEventKind.ADD)
			{
				assert(event.items.length == 1);
				layers.splice(event.location, 0, event.items[0]);
			}
			// 撤销时都是走这个方法
			else if (event.kind == CollectionEventKind.RESET)
			{
				layers = Vector.<LayerInfo>(layersArrayList.source);
			}
			else
			{
				throw new ArgumentError("不支持的 kind");
			}
		}

		override protected function get layerInfoClass():Class
		{
			return LayerInfoEditable;
		}

		override protected function get regionInfoClass():Class
		{
			return RegionInfoEditable;
		}

		/**
		 * 设置地图的宽高，然后发送 onSizeChange
		 * @param width
		 * @param height
		 *
		 */
		public function setSize(width:Number, height:Number, depth:Number = NaN):void
		{
			this.width = width;
			this.height = height;
			this.depth = isNaN(depth) ? height : depth;
			onSizeChange.dispatch();
		}

		/**
		 * 设置地图的网格宽高，然后发送 onGridSizeChange<br>
		 * @param gridWidth
		 * @param gridHeight
		 * @param grids 可选，要填充的网格数据；默认是空的网格
		 *
		 */
		public function setGridSize(gridWidth:Number, gridHeight:Number, grids:Array = null):void
		{
			this.gridWidth = gridWidth;
			this.gridHeight = gridHeight;
			gridCellWidth = width / gridWidth;
			gridCellHeight = height / gridHeight;

			if (grids == null)
			{
				resetGridCells();
			}
			else
			{
				this.grids = grids;
			}
			onGridSizeChange.dispatch();
		}

		/**
		 * 重置网格
		 *
		 */
		private function resetGridCells():void
		{
			grids = new Array(gridHeight);

			for (var i:int = 0; i < gridHeight; i++)
			{
				grids[i] = new Array(gridWidth);

				for (var j:int = 0; j < gridWidth; j++)
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
		 * 根据 x y 获得网格值
		 * @param x
		 * @param y
		 * @return
		 *
		 */
		public function getGridCell(x:int, y:int):int
		{
			return grids[y][x];
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
				// 第 i 和 i+1 个元素不连续
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

		override public function addRegion(r:RegionInfo):void
		{
			super.addRegion(r);
			// 刷一下 source，触发 COLLECTION_CHANGE 事件
			regionsArrayList.source = regions;
		}

		override public function removeRegion(r:RegionInfo):void
		{
			super.removeRegion(r);
			// 刷一下 source，触发 COLLECTION_CHANGE 事件
			regionsArrayList.source = regions;
		}
	}
}
