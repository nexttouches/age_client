package ageb.modules.ae
{
	import flash.filesystem.File;
	import mx.collections.ArrayList;
	import age.assets.LayerInfo;
	import age.assets.LayerType;
	import age.assets.SceneInfo;
	import nt.assets.AssetConfig;
	import nt.lib.reflect.Type;
	import org.apache.flex.collections.VectorList;
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
		public var bgsVectorList:VectorList;

		/**
		 * 对应 objects，可以直接绑定到 List 组件
		 */
		public var objectsVectorList:VectorList;

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
			bgsVectorList = new VectorList(bgs);
			objectsVectorList = new VectorList(objects);

			// 如果没有 raw 设置默认值
			if (!raw)
			{
				type = LayerType.BG;
				scrollRatio = 1;
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
			objectsVectorList.addItem(info);
			info.parent = this;
		}

		/**
		 * 删除 ObjectInfoEditable 对应的渲染器
		 * @param info
		 *
		 */
		public function removeObject(info:ObjectInfoEditable):void
		{
			objectsVectorList.removeItem(info);
			info.parent = null;
		}

		/**
		 * 添加 BGInfoEditable 对应的渲染器
		 * @param info
		 *
		 */
		public function addBg(info:BGInfoEditable):void
		{
			bgsVectorList.addItem(info);
			info.parent = this;
		}

		/**
		 * 删除 BGInfoEditable 对应的渲染器
		 * @param info
		 *
		 */
		public function removeBg(info:BGInfoEditable):void
		{
			bgsVectorList.removeItem(info);
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

		/**
		 * @inheritDoc
		 *
		 */
		override protected function get bgInfoClass():Class
		{
			return BGInfoEditable;
		}

		/**
		 * @inheritDoc
		 *
		 */
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
