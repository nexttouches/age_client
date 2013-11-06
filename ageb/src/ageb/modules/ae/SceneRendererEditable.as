package ageb.modules.ae
{
	import flash.geom.Point;
	import mx.events.CollectionEvent;
	import age.data.SceneInfo;
	import age.renderers.MouseResponder;
	import age.renderers.SceneRenender;
	import starling.display.DisplayObject;

	/**
	 * 可编辑的场景渲染器
	 * @author zhanghaocong
	 *
	 */
	public class SceneRendererEditable extends SceneRenender
	{
		/**
		 * constructor
		 *
		 */
		public function SceneRendererEditable(layerRendererClass:Class = null)
		{
			super(LayerRendererEditable);
			trace("[SceneRendererEditable] 已实例化");
			touchable = true;
			x = 205;
		}

		public var isShowBGOutline:Boolean;

		private var _isShowGrid:Boolean;

		/**
		 * 切换是否显示网格
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

			if (info)
			{
				charLayer.isShowGrid = value;
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function addLayers():void
		{
			super.addLayers();
			charLayer.isShowGrid = _isShowGrid;
			charLayer.isShowRegions = _isShowRegions;
		}

		private var _isShowLayerOutline:Boolean = true;

		/**
		 * 是否显示图层轮廓
		 * @return
		 *
		 */
		public function get isShowLayerOutline():Boolean
		{
			return _isShowLayerOutline;
		}

		public function set isShowLayerOutline(value:Boolean):void
		{
			_isShowLayerOutline = value;

			for (var i:int = 0; i < numChildren; i++)
			{
				var l:LayerRendererEditable = getChildAt(i) as LayerRendererEditable;
				l.isShowLayerOutline = value;
			}
		}

		private var _isShowRegions:Boolean;

		/**
		 * 设置或获取是否显示区域
		 * @return
		 *
		 */
		public function get isShowRegions():Boolean
		{
			return _isShowRegions;
		}

		public function set isShowRegions(value:Boolean):void
		{
			_isShowRegions = value;

			if (info)
			{
				charLayer.isShowRegions = value;
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function set info(value:SceneInfo):void
		{
			if (infoEditable)
			{
				infoEditable.regionsVectorList.removeEventListener(CollectionEvent.COLLECTION_CHANGE, regionsArrayList_onChange);
				infoEditable.onSizeChange.remove(onSizeChange);
				infoEditable.onGridResolutionChange.remove(onGridSizeChange);
				infoEditable.onGridCellChange.remove(onGridCellChange);
				infoEditable.onLayersChange.remove(onLayersChange);
			}

			if (value)
			{
//				// 因为没有打包好的 atlas 等文件
//				// 这里先做预加载操作
//				// 完成后再调用 super.info = value
//				var bgAssets:Vector.<Asset> = value.getBGAssets();
//				var uniqueHelper:Object = {};
//
//				for each (var a:Asset in bgAssets)
//				{
//					uniqueHelper[a.path] = true;
//				}
//				var fs:FileStream = new FileStream();
//
//				for (var path:String in uniqueHelper)
//				{
//					var ai:AssetInfo = AssetConfig.getInfo(path + ".xml")
//					var f:File = new File(ai.url);
//
//					if (!f.exists)
//					{
//						Alert.show("找不到指定的文件 " + f.nativePath);
//						continue;
//					}
//					fs.open(f, FileMode.READ);
//					var content:String = fs.readUTFBytes(fs.bytesAvailable);
//					fs.close();
//					TextureAtlasConfig.addAtlas(ai.path.split(".")[0], XML(content));
//				}
			}
			super.info = value;

			if (infoEditable)
			{
				infoEditable.regionsVectorList.addEventListener(CollectionEvent.COLLECTION_CHANGE, regionsArrayList_onChange);
				infoEditable.onGridResolutionChange.add(onGridSizeChange);
				infoEditable.onSizeChange.add(onSizeChange);
				infoEditable.onGridCellChange.add(onGridCellChange);
				infoEditable.onLayersChange.add(onLayersChange);
				charLayer.isShowGrid = _isShowGrid;
			}
		}

		/**
		 * @private
		 *
		 */
		protected function regionsArrayList_onChange(event:CollectionEvent):void
		{
			if (_isShowRegions)
			{
				charLayer.addRegionInfoRenderers();
			}
		}

		/**
		 * @private
		 *
		 */
		protected function onLayersChange():void
		{
			// 刷新全部图层
			removeLayers();
			addLayers();
		}

		/**
		 * @private
		 *
		 */
		private function onGridCellChange(x:int, y:int, value:int):void
		{
			if (_isShowGrid)
			{
				charLayer.getGridCellRenderer(x, y).value = value;
			}
		}

		/**
		 * @private
		 *
		 */
		private function onGridSizeChange():void
		{
			if (_isShowGrid)
			{
				charLayer.isShowGrid = false;
				charLayer.isShowGrid = true;
			}
		}

		/**
		 * @private
		 *
		 */
		private function onSizeChange():void
		{
			// 尺寸变化时，重新绘制图层轮廓，重新调整 BG 位置
			// 其中对象每帧都会自动改，无需设置
			forEachLayers(function(l:LayerRendererEditable):void
			{
				l.updateBGPositions();
				l.addOutline();
			});
			// 也需要重新绘制网格
			onGridSizeChange();
		}

		/**
		 * @private
		 *
		 */
		protected function get infoEditable():SceneInfoEditable
		{
			return info as SceneInfoEditable;
		}

		/**
		 * 遍历所有图层，并调用 callback(LayerRendererEditable);
		 * @param callback
		 *
		 */
		public function forEachLayers(callback:Function):void
		{
			for (var i:int = 0, n:int = numChildren; i < n; i++)
			{
				callback(getChildAt(i));
			}
		}

		/**
		 * 在 MouseResponder 的基础上，增加 CellRendererEditable 的响应
		 * @param localPoint
		 * @param forTouch
		 * @return
		 *
		 */
		public override function hitTest(localPoint:Point, forTouch:Boolean = false):DisplayObject
		{
			var result:DisplayObject = $hitTest(localPoint, forTouch);

			// 通过 MouseResponder.owner 可以知道点击了哪个 AvatarRenderer
			if (result is MouseResponder)
			{
				return result;
			}

			if (result is GridCellRendererEditable)
			{
				return result;
			}

			// ISelectableRenderer 对象
			if (result is ISelectableRenderer)
			{
				return result;
			}
			return this;
		}
	}
}
