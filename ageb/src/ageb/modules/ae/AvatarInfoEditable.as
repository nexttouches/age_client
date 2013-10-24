package ageb.modules.ae
{
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import age.assets.ActionInfo;
	import age.assets.AvatarInfo;
	import age.assets.Box;
	import nt.lib.util.assert;
	import org.apache.flex.collections.VectorList;
	import org.osflash.signals.Signal;

	/**
	 * 编辑时使用的 AvatarInfo<br>
	 * 在原有基础上增加了一些编辑器专用的功能
	 * @author zhanghaocong
	 *
	 */
	public class AvatarInfoEditable extends AvatarInfo
	{
		/**
		 * constructor
		 * @param raw
		 *
		 */
		public function AvatarInfoEditable(raw:Object = null)
		{
			super(raw);
			// 初始化时填充一些
			var buffer:Array = [];

			for each (var info:ActionInfoEditable in actions)
			{
				buffer.push(info);
			}
			buffer.sortOn("name");
			actionsArrayList = new VectorList(Vector.<ActionInfoEditable>(buffer));
			assert(actionsArrayList.length == numActions);
			// 最后才添加事后同步方法
			actionsArrayList.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange);
		}

		/**
		 * 所有动作的 ArrayList<br>
		 * 可以直接绑定到组件上
		 */
		public var actionsArrayList:VectorList;

		/**
		 * 添加一个动作
		 * @param value
		 *
		 */
		public function addAction(value:ActionInfo):void
		{
			assert(!hasAction(value.name), "添加失败：" + value.name + " 重复")
			actionsArrayList.addItem(value);
		}

		/**
		 * 删除一个动作
		 * @param value
		 *
		 */
		public function removeAction(value:ActionInfo):void
		{
			assert(hasAction(value.name), "删除失败：" + value.name + " 不存在");
			actionsArrayList.removeItem(value);
		}

		/**
		 * @inhertDoc
		 * @return
		 *
		 */
		override protected function get actionInfoClass():Class
		{
			return ActionInfoEditable;
		}

		protected function onCollectionChange(event:CollectionEvent):void
		{
			var info:ActionInfoEditable;

			if (event.kind == CollectionEventKind.ADD)
			{
				for each (info in event.items)
				{
					actions[info.name] = info;
				}
			}
			else if (event.kind == CollectionEventKind.REMOVE)
			{
				for each (info in event.items)
				{
					delete actions[info.name];
				}
			}
			else
			{
				throw new ArgumentError("不支持");
			}
		}

		/**
		 * <code>size</code> 发生变化时广播
		 */
		public var onSizeChange:Signal = new Signal();

		/**
		 * 设置 size<br>
		 * @param value
		 *
		 */
		public function setSize(value:Box):void
		{
			size = value;
			onSizeChange.dispatch();
		}

		/**
		* 导出到 JSON
		* @param k
		* @return
		*
		*/
		public function toJSON(k:*):*
		{
			return { id: id, actions: actions, size: size };
		}
	}
}
