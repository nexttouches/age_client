package ageb.modules.document.op
{
	import flash.errors.IllegalOperationError;
	import ageb.modules.Modules;
	import ageb.modules.document.Document;
	import ageb.modules.settings.SettingsModule;
	import ageb.utils.FlashTip;
	import org.osflash.signals.Signal;

	/**
	 * 所有操作的基类
	 * @author zhanghaocong
	 *
	 */
	public class OpBase
	{
		/**
		 * 索引是否已锁
		 */
		private var isIndexLocked:Boolean;

		private var _index:int;

		/**
		 * 当前操作的索引
		 */
		final public function get index():int
		{
			return _index;
		}

		/**
		 * @private
		 */
		public function set index(value:int):void
		{
			if (isIndexLocked)
			{
				throw new IllegalOperationError("索引已锁，不可再次更改");
			}
			isIndexLocked = true;
			_index = value;
		}

		/**
		 * 当前操作对于文档对象是否是当前操作
		 * @return
		 *
		 */
		public function get isCurrent():Boolean
		{
			return _doc.historyCursor == index;
		}

		/**
		 * 当前 OP 的文档操作对象
		 */
		protected var _doc:Document;

		/**
		 * 创建一个新的 OpBase
		 * @param doc
		 *
		 */
		public function OpBase(doc:Document)
		{
			_doc = doc;
		}

		/**
		 * 标记是否已执行过
		 */
		public var isExecuted:Boolean;

		/**
		 * 执行操作
		 * @return 是否成功
		 *
		 */
		public function execute():Boolean
		{
			if (isExecuted)
			{
				throw new IllegalOperationError("已经执行过，不可重复执行");
			}
			isExecuted = true;
			FlashTip.show(name);
			_doc.addHistory(this);
			return true;
		}

		/**
		 * 操作名
		 * @return
		 *
		 */
		public function get name():String
		{
			return "未命名操作";
		}

		/**
		 * 获得设置数据
		 * @return
		 *
		 */
		protected function get settings():SettingsModule
		{
			return Modules.getInstance().settings;
		}

		/**
		 * isOverwritable 变化时广播
		 */
		public var onIsOverwritableChange:Signal = new Signal();

		private var _isOverwritable:Boolean;

		/**
		 * 标记当前操作（历史记录）是否将会被覆盖
		 */
		public function get isOverwritable():Boolean
		{
			return _isOverwritable;
		}

		/**
		 * @private
		 */
		public function set isOverwritable(value:Boolean):void
		{
			_isOverwritable = value;
			onIsOverwritableChange.dispatch();
		}
	}
}
