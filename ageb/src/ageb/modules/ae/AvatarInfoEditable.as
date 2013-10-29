package ageb.modules.ae
{
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import age.assets.AvatarInfo;
	import age.assets.Box;
	import nt.lib.util.assert;
	import org.apache.flex.collections.VectorList;
	import org.osflash.signals.Signal;

	/**
	 * <p>AvatarInfoEditable 在 AvatarInfo 基础上增加了一些编辑器专用的功能</p>
	 * @author zhanghaocong
	 *
	 */
	public class AvatarInfoEditable extends AvatarInfo
	{
		/**
		 * 所有动作的 ArrayList<br>
		 * 可以直接绑定到组件上
		 */
		public var actionsVectorList:VectorList;

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
			actionsVectorList = new VectorList(Vector.<ActionInfoEditable>(buffer));
			assert(actionsVectorList.length == numActions);
			// 我们侦听列表变化以更新 actions
			actionsVectorList.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange);
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

		/**
		 * @private
		 * @param event
		 *
		 */
		protected function onCollectionChange(event:CollectionEvent):void
		{
			var info:ActionInfoEditable;

			if (event.kind == CollectionEventKind.ADD)
			{
				for each (info in event.items)
				{
					info.parent = this;
					actions[info.name] = info;
				}
			}
			else if (event.kind == CollectionEventKind.REMOVE)
			{
				for each (info in event.items)
				{
					delete actions[info.name];
					info.parent = null;
				}
			}
			else if (event.kind == CollectionEventKind.UPDATE)
			{
				// 不做任何事
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
