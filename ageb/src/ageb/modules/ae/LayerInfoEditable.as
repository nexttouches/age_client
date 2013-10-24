package ageb.modules.ae
{
	import mx.collections.ArrayList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import age.assets.BGInfo;
	import age.assets.LayerInfo;
	import age.assets.LayerType;
	import age.assets.ObjectInfo;
	import age.assets.SceneInfo;
	import nt.lib.reflect.Type;
	import org.osflash.signals.Signal;

	/**
	 * 可编辑的图层信息<br>
	 * 为编辑器提供额外的接口
	 * @author zhanghaocong
	 *
	 */
	public class LayerInfoEditable extends LayerInfo implements IParent
	{
		/**
		 * 对应 bgs，可以直接绑定到 List 组件
		 */
		public var bgsArrayList:ArrayList;

		/**
		 * 对应 objects，可以直接绑定到 List 组件
		 */
		public var objectsArrayList:ArrayList;

		/**
		 * scrollRatio 发生变化时广播<br>
		 * 只有通过调用 setScrollRatio 才会广播该事件
		 * @see setScrollRatio
		 */
		public var onScrollRatioChange:Signal = new Signal();

		/**
		 * 创建一个新的 LayerInfoEditable
		 * @param raw
		 *
		 */
		public function LayerInfoEditable(raw:Object = null, parent:SceneInfo = null)
		{
			super(raw, parent);
			// 同步 bgs 和 objects
			bgsArrayList = new ArrayList();
			objectsArrayList = new ArrayList();
			sync(bgs, bgsArrayList);
			sync(objects, objectsArrayList);
			bgsArrayList.addEventListener(CollectionEvent.COLLECTION_CHANGE, bgsArrayList_onChange);
			objectsArrayList.addEventListener(CollectionEvent.COLLECTION_CHANGE, objectsArrayList_onChange);

			// 如果没有 raw 设置默认值
			if (!raw)
			{
				type = LayerType.BG;
				scrollRatio = 1;
			}
		}

		protected function bgsArrayList_onChange(event:CollectionEvent):void
		{
			var info:BGInfo;

			if (event.kind == CollectionEventKind.ADD)
			{
				for each (info in event.items)
				{
					bgs.push(info);
				}
			}
			else if (event.kind == CollectionEventKind.REMOVE)
			{
				for each (info in event.items)
				{
					bgs.splice(bgs.indexOf(info), 1);
				}
			}
			else
			{
				throw new Error("不支持的 kind");
			}
		}

		protected function objectsArrayList_onChange(event:CollectionEvent):void
		{
			var info:ObjectInfo;

			if (event.kind == CollectionEventKind.ADD)
			{
				for each (info in event.items)
				{
					objects.push(info);
				}
			}
			else if (event.kind == CollectionEventKind.REMOVE)
			{
				for each (info in event.items)
				{
					objects.splice(objects.indexOf(info), 1);
				}
			}
			else
			{
				throw new Error("不支持的 kind");
			}
		}

		/**
		 * 复制 src 到 dest
		 * @param src
		 * @param dest
		 *
		 */
		final private function sync(src:*, dest:ArrayList):void
		{
			for (var i:int = 0, n:int = src.length; i < n; i++)
			{
				dest.addItem(src[i]);
			}
		}

		/**
		 * 添加一个 info<br>
		 * 其中 info 的类型会自动判断
		 * @param info
		 *
		 */
		public function add(info:IChild):void
		{
			if (info is ObjectInfoEditable)
			{
				return addObject(info as ObjectInfoEditable);
			}
			else if (info is BGInfoEditable)
			{
				return addBg(info as BGInfoEditable);
			}
			throw new ArgumentError("不支持类型 " + Type.of(info).fullname);
		}

		/**
		 * 删除一个 info<br>
		 * 其中 info 的类型会自动判断
		 * @param info
		 *
		 */
		public function remove(info:IChild):void
		{
			if (info is ObjectInfoEditable)
			{
				return removeObject(info as ObjectInfoEditable);
			}
			else if (info is BGInfoEditable)
			{
				return removeBg(info as BGInfoEditable);
			}
			throw new ArgumentError("不支持类型 " + Type.of(info).fullname);
		}

		/**
		 * 添加 ObjectInfoEditable 对应的渲染器
		 * @param info
		 *
		 */
		public function addObject(info:ObjectInfoEditable):void
		{
			objectsArrayList.addItem(info);
			info.parent = this;
		}

		/**
		 * 删除 ObjectInfoEditable 对应的渲染器
		 * @param info
		 *
		 */
		public function removeObject(info:ObjectInfoEditable):void
		{
			objectsArrayList.removeItem(info);
			info.parent = null;
		}

		/**
		 * 添加 BGInfoEditable 对应的渲染器
		 * @param info
		 *
		 */
		public function addBg(info:BGInfoEditable):void
		{
			bgsArrayList.addItem(info);
			info.parent = this;
		}

		/**
		 * 删除 BGInfoEditable 对应的渲染器
		 * @param info
		 *
		 */
		public function removeBg(info:BGInfoEditable):void
		{
			bgsArrayList.removeItem(info);
			info.parent = null;
		}

		/**
		 * 修改 scrollRatio，然后广播 onScrollRatioChange
		 * @param value
		 *
		 */
		public function setScrollRatio(value:Number):void
		{
			scrollRatio = value;
			onScrollRatioChange.dispatch();
		}

		override protected function get bgInfoClass():Class
		{
			return BGInfoEditable;
		}

		override protected function get objectInfoClass():Class
		{
			return ObjectInfoEditable;
		}

		/**
		 * JSON 序列化时使用的对象
		 * @param k
		 * @return
		 *
		 */
		public function toJSON(k:*):*
		{
			return Type.of(this).superType.toObject(this, [ "parent", "onIsVisibleChange",
															"isCharLayer" ]);
		}
	}
}
