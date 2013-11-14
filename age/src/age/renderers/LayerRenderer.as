package age.renderers
{
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import age.AGE;
	import age.data.BGInfo;
	import age.data.LayerInfo;
	import age.data.LayerType;
	import age.data.ObjectInfo;
	import age.data.RegionInfo;
	import nt.lib.util.assert;
	import starling.animation.IAnimatable;
	import starling.display.DisplayObject;
	import starling.display.Sprite;

	/**
	 * LayerRenderer 将包含 BaseRenderer
	 * 根据参数，可以每帧按 BaseRenderer.index 执行排序操作
	 * @author zhanghaocong
	 *
	 */
	public class LayerRenderer extends Sprite implements IAnimatable
	{
		/**
		 * 用于创建 BGRenderer 的类
		 */
		public var bgRendererClass:Class;

		/**
		 * 用于创建 ObjectRenderer 的类
		 */
		public var objectRendererClass:Class;

		/**
		 * 创建一个新的 LayerRenderer
		 * @param bgRendererClass
		 * @param objectRendererClass
		 *
		 */
		public function LayerRenderer(bgRendererClass:Class = null, objectRendererClass:Class = null)
		{
			super();
			this.bgRendererClass = bgRendererClass || BGRenderer;
			this.objectRendererClass = objectRendererClass || ObjectRenderer;
		}

		protected var _info:LayerInfo;

		/**
		 * 设置或获取 LayerInfo
		 * @return
		 *
		 */
		public function get info():LayerInfo
		{
			return _info;
		}

		public function set info(value:LayerInfo):void
		{
			unflatten();

			if (_info)
			{
				// 停止物理引擎
				_info.stop();
				// 反注册快捷键
				_info.onTypeChange.remove(onTypeChange);
				_info.onIsVisibleChange.remove(onIsVisibleChange);
				removeGridCellRenderer();
				removeChildren(0, -1, true);
			}
			_info = value;

			if (_info)
			{
				_info.onIsVisibleChange.add(onIsVisibleChange);
				onIsVisibleChange();
				_info.onTypeChange.add(onTypeChange);
				onTypeChange();
			}
			visibleRect.x = visibleRect.y = visibleRect.width = visibleRect.height = 0;
		}

		private function onTypeChange():void
		{
			removeGridCellRenderer();
			removeChildren(0, -1, true);
			isAutoSort = info.isAutoSort;

			if (_info.type == LayerType.BG)
			{
				addBGs();
			}

			if (_info.type == LayerType.OBJECT)
			{
				addObjects();

				if (_isShowGrid)
				{
					addGridCellRenderer();
				}

				if (_isShowRegions)
				{
					addRegionInfoRenderers();
				}
				// 开始物理引擎
				_info.start();
			}
		}

		private function onIsVisibleChange():void
		{
			visible = info.isVisible;
		}

		/**
		 * 获得用于创建 RegionInfoRenderer 的具体 Class
		 * @return
		 *
		 */
		protected function get regionInfoRendererClass():Class
		{
			return RegionInfoRenderer;
		}

		/**
		 * 储存所有的 RegionInfoRenderer<br>
		 * 以 RegionInfo 为 key，值是由 RegionInfoRenderer 或其子类的实例
		 */
		protected var regions:Dictionary = new Dictionary();

		/**
		 * 根据参数获得指定的 RegionInfoRenderer
		 * @param info
		 * @return
		 *
		 */
		public function getRegionInfoRenderer(info:RegionInfo):RegionInfoRenderer
		{
			return regions[info];
		}

		/**
		 * 删除所有的 RegionInfoRenderer
		 *
		 */
		public function removeRegionInfoRenderers():void
		{
			for each (var r:RegionInfoRenderer in regions)
			{
				r.removeFromParent(true);
			}
			regions = new Dictionary();
		}

		/**
		 * 添加所有的 RegionInfoRenderer
		 *
		 */
		public function addRegionInfoRenderers():void
		{
			// 没有数据不绘制
			if (!info)
			{
				return;
			}

			// 不是角色层不绘制
			if (!info.isCharLayer)
			{
				return;
			}
			removeRegionInfoRenderers();

			for each (var regionInfo:RegionInfo in info.parent.regions)
			{
				var r:RegionInfoRenderer = new regionInfoRendererClass();
				r.info = regionInfo;
				addChild(r);
				regions[regionInfo] = r;
			}
		}

		/**
		 * 获得用于创建网格渲染器的具体 Class
		 * @return
		 *
		 */
		protected function get gridCellClass():Class
		{
			return GridCellRenderer;
		}

		/**
		 * 储存所有的 gridCellRenderer
		 */
		protected var gridCellRenderers:Vector.<Vector.<GridCellRenderer>> = new Vector.<Vector.<GridCellRenderer>>;

		/**
		 * 根据 XY 获得 GridCellRenderer
		 * @param x
		 * @param y
		 * @return
		 *
		 */
		public function getGridCellRenderer(x:int, y:int):GridCellRenderer
		{
			return gridCellRenderers[y][x];
		}

		/**
		 * 删除所有网格渲染器
		 *
		 */
		protected function removeGridCellRenderer():void
		{
			for (var i:int = numChildren - 1; i >= 0; i--)
			{
				var child:GridCellRenderer = getChildAt(i) as GridCellRenderer;

				if (child)
				{
					child.removeFromParent(true);
				}
			}
			gridCellRenderers = new Vector.<Vector.<GridCellRenderer>>;
		}

		/**
		 * 添加网格渲染器
		 *
		 */
		protected function addGridCellRenderer():void
		{
			if (!_info)
			{
				return;
			}
			removeGridCellRenderer();
			const gridResolution:Vector3D = _info.parent.gridResolution;
			const cellSize:Vector3D = new Vector3D(_info.scaledWidth / gridResolution.x, 0, _info.scaledDepth / gridResolution.z);
			GridCellRenderer.updateTexture(cellSize);

			// 循环创建 GridCellRenderer
			for (var z:int = 0; z < gridResolution.z; z++)
			{
				gridCellRenderers.push(new Vector.<GridCellRenderer>);

				for (var x:int = 0; x < gridResolution.x; x++)
				{
					var cell:GridCellRenderer = new gridCellClass();
					cell.projectY = info.parent.projectY;
					cell.cellX = x;
					cell.cellZ = z;
					cell.size = cellSize;
					cell.value = _info.parent.grids[z][x];
					gridCellRenderers[z].push(cell);
					addChild(cell);
				}
			}
		}

		/**
		 * 以 BGInfo 做 key，储存所有 BGRenderer
		 */
		private var bgs:Dictionary = new Dictionary;

		/**
		 * 添加所有 BGInfo 的渲染器
		 *
		 */
		protected function addBGs():void
		{
			for (var i:int = 0, n:int = _info.bgs.length; i < n; i++)
			{
				addBg(_info.bgs[i]);
			}
			sortChildren(sort);

			if (_info.isFlatten)
			{
				flatten();
			}
			else
			{
				unflatten();
			}
		}

		/**
		 * 删除 BGInfo 对应的渲染器
		 * @param info
		 *
		 */
		public function removeBg(info:BGInfo):void
		{
			assert(info in bgs, "指定的 BgInfo 不在 bgs 中，无法删除");
			var r:BGRenderer = bgs[info];
			r.removeFromParent(true);
			delete bgs[info];
			// 不必调用 r.info = null
			// 因为 r.dispose 方法中已经包含了该语句
		}

		/**
		 * 为 BGInfo 添加对应的渲染器
		 * @param info
		 *
		 */
		public function addBg(info:BGInfo):void
		{
			assert(!(info in bgs), "已有 BgInfo 在 bgs 中，不可重复添加");
			var r:BGRenderer = new bgRendererClass();
			r.onRender = flatten;
			r.info = info;
			addChild(r);
			bgs[info] = r;
		}

		/**
		 * 以 ObjectInfo 作为 key 储存的 ObjectRenderer 列表
		 */
		private var objects:Dictionary = new Dictionary();

		/**
		 * 根据 ObjectInfo 添加对应渲染器
		 * @param info
		 *
		 */
		public function addObject(info:ObjectInfo):void
		{
			assert(!(info in objects), "已有 ObjectInfo 在 objects 中，不可重复添加");
			var r:ObjectRenderer = new objectRendererClass();
			r.parent = this;
			r.info = info;
			objects[info] = r;
		}

		/**
		 * 根据 ObjectInfo 删除对应渲染器
		 * @param info
		 *
		 */
		public function removeObject(info:ObjectInfo):void
		{
			assert(info in objects, "指定的 ObjectInfo 不在 objects 中，无法删除");
			var r:ObjectRenderer = objects[info];
			r.parent = null;
			r.info = null;
			delete objects[info];
		}

		/**
		 * 为所有的 ObjectInfo 添加对应的渲染器
		 *
		 */
		protected function addObjects():void
		{
			for (var i:int = 0, n:int = _info.objects.length; i < n; i++)
			{
				addObject(_info.objects[i]);
			}
		}

		private var _isAutoSort:Boolean;

		private var _isShowGrid:Boolean;

		/**
		 * 切换渲染器是否显示网格<br>
		 * 只有 type 为 OBJECT 的图层才可以显示网格
		 * @return
		 *
		 */
		public function get isShowGrid():Boolean
		{
			return _isShowGrid;
		}

		public function set isShowGrid(value:Boolean):void
		{
			_isShowGrid = value;

			if (_isShowGrid)
			{
				addGridCellRenderer();
			}
			else
			{
				removeGridCellRenderer();
			}
		}

		/**
		 * 设置或获取是否每帧都进行排序操作
		 * @return
		 *
		 */
		public function get isAutoSort():Boolean
		{
			return _isAutoSort;
		}

		public function set isAutoSort(value:Boolean):void
		{
			if (value != _isAutoSort)
			{
				_isAutoSort = value;

				if (_isAutoSort)
				{
					AGE.s.juggler.add(this);
				}
				else
				{
					AGE.s.juggler.remove(this);
				}
			}
		}

		private var _isShowRegions:Boolean;

		/**
		 * 设置或获取是否显示区域
		 */
		public function get isShowRegions():Boolean
		{
			return _isShowRegions;
		}

		/**
		 * @private
		 */
		public function set isShowRegions(value:Boolean):void
		{
			_isShowRegions = value;

			if (_isShowRegions)
			{
				addRegionInfoRenderers();
			}
			else
			{
				removeRegionInfoRenderers();
			}
		}

		public function advanceTime(time:Number):void
		{
			arrange();
		}

		/**
		 * 可见区域
		 */
		public var visibleRect:Rectangle = new Rectangle();

		/**
		 * 调用后进行排序操作
		 *
		 */
		final public function arrange():void
		{
			sortChildren(sort);
			// 控制范围外的对象不显示
			const stageWidth:int = AGE.s.stage.stageWidth;
			const stageHeight:int = AGE.s.stage.stageHeight;
			const scrollX:int = -x;
			const scrollY:int = -y;
			const zoom:Number = AGE.camera.zoomScale;
			const threshold:int = 64; // 负数缩小范围，正数放大范围
			visibleRect.right = scrollX + threshold + (zoom == 1 ? stageWidth : stageWidth / zoom);
			visibleRect.x = scrollX - threshold;
			visibleRect.bottom = scrollY + threshold + (zoom == 1 ? stageHeight : stageHeight / zoom);
			visibleRect.top = scrollY - threshold;

			for (var i:int = 0, n:int = numChildren; i < n; i++)
			{
				var child:DisplayObject = getChildAt(i);

				if (child is IDetailRenderer)
				{
					IDetailRenderer(child).updateDetail(visibleRect);
				}
				else
				{
					// 为没有实现 IDetailRenderer 的对象设置一个简单方法
					// 只考虑 X，不考虑宽高，效率较高
					child.visible = (child.x >= visibleRect.x) && (child.x <= visibleRect.right);
				}
			}
		}

		/**
		 * 排序时使用的方法
		 * @param a
		 * @param b
		 * @return
		 *
		 */
		protected function sort(a:IArrangeable, b:IArrangeable):int
		{
			return b.zIndex - a.zIndex;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function dispose():void
		{
			if (_isAutoSort)
			{
				AGE.s.juggler.remove(this);
			}
			info = null;

			for each (var o:ObjectRenderer in objects)
			{
				o.dispose();
			}
			objects = null;
			bgs = null;
			regions = null;
			super.dispose();
		}

		public function getObjectRendererByInfo(info:ObjectInfo):ObjectRenderer
		{
			return objects[info];
		}

		public function getBGRendererByInfo(info:BGInfo):BGRenderer
		{
			var n:int = numChildren;

			for (var i:int = 0; i < n; i++)
			{
				var result:BGRenderer = getChildAt(i) as BGRenderer;

				if (result && result.info == info)
				{
					return result;
				}
			}
			return null;
		}
	}
}
