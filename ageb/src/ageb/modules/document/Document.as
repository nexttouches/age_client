package ageb.modules.document
{
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import mx.collections.ArrayList;
	import ageb.modules.Modules;
	import ageb.modules.document.op.ChangeDocumentOP;
	import ageb.modules.document.op.OpBase;
	import org.osflash.signals.Signal;

	/**
	 * 文档的基类<br>
	 * 继承 EventDispatcher 是为了实现 [Bindable]
	 * @author zhanghaocong
	 *
	 */
	public class Document extends EventDispatcher
	{

		/**
		 * 设置或获取当前出现在 TabBar 中的标签
		 */
		[Bindable]
		public var label:String;

		/**
		 * 获取当前文档将要使用的视图类
		 * @return
		 *
		 */
		public function get viewClass():Class
		{
			throw new IllegalOperationError("需子类实现");
		}

		/**
		 * state 变化时广播
		 */
		public var onStateChange:Signal = new Signal();

		private var _state:int = DocumentState.READY;

		/**
		 * 文档状态
		 */
		final public function get state():int
		{
			return _state;
		}

		/**
		 * @private
		 */
		public function set state(value:int):void
		{
			if (_state != value)
			{
				_state = value;
				updateLabel();
				onStateChange.dispatch();
			}
		}

		/**
		 * 刷 Label
		 *
		 */
		protected function updateLabel():void
		{
			label = name + (isChanged ? " * " : "") + " (" + ((zoomScale * 100).toFixed(0) + "%)");
		}

		/**
		 * 当前相机跟踪的点
		 */
		public var focus:Point = new Point();

		private var _zoomScale:Number = 1;

		/**
		 * 缩放比例
		 */
		public function get zoomScale():Number
		{
			return _zoomScale;
		}

		/**
		 * @private
		 */
		public function set zoomScale(value:Number):void
		{
			_zoomScale = value;
			updateLabel();
		}

		/**
		 * 当前文档关联的文件
		 */
		public var file:File;

		/**
		 * 读取进来的原始 JSON
		 */
		public var raw:Object;

		/**
		 * 撤销时广播
		 */
		public var onUndo:Signal = new Signal();

		/**
		 * 重做时广播
		 */
		public var onRedo:Signal = new Signal();

		/**
		 * 历史记录指针发生变化时广播
		 */
		public var onHistoryCursorChange:Signal = new Signal();

		/**
		 * 开始保存时广播
		 */
		public var onSaveStart:Signal = new Signal();

		/**
		 * 保存完成时广播
		 */
		public var onSaveComplete:Signal = new Signal();

		/**
		 * 文档关闭时广播
		 */
		public var onClose:Signal = new Signal();

		/**
		 * 创建一个新文档
		 * @param file
		 * @param raw
		 *
		 */
		public function Document(file:File, raw:Object)
		{
			this.file = file;
			this.raw = raw;
			updateLabel();
		}

		/**
		 * 保存当前文档<br>
		 * 如果当前文档的 file 为 null，将报错
		 *
		 */
		public function save():void
		{
			if (isSaving)
			{
				return;
			}

			if (file == null)
			{
				throw new IllegalOperationError("保存文档时出错，file 不可为 null");
			}
			state = DocumentState.SAVING;
			onSaveStart.dispatch();
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			fs.writeUTFBytes(rawString);
			fs.close();
			state = DocumentState.READY;
			onSaveComplete.dispatch();
		}

		/**
		 * 撤销
		 *
		 */
		public function undo():void
		{
			if (historyCursor > 0)
			{
				// 撤销是指 *当前* 历史记录撤销
				currentOP.undo();
				// 然后修改指针 -1
				historyCursor--;
				onUndo.dispatch();
			}
			else
			{
			}
		}

		/**
		 * 重做
		 *
		 */
		public function redo():void
		{
			if (historyCursor < numHistores - 1)
			{
				// 先修改指针 +1
				historyCursor++;
				// 重做是指 *下一个* 历史记录重做
				currentOP.redo();
				onRedo.dispatch();
			}
		}

		/**
		 * 预览
		 *
		 */
		public function preview():void
		{
			throw new Error("需子类实现");
		}

		/**
		 * 发布
		 *
		 */
		public function publish():void
		{
			throw new Error("需子类实现");
		}

		/**
		 * 返回 file.nativePath
		 * @return
		 *
		 */
		public function get nativePath():String
		{
			return file ? file.nativePath : null;
		}

		/**
		 * 文档名称
		 * @return
		 *
		 */
		public function get name():String
		{
			return file ? file.name : null;
		}

		/**
		 * 是否是新建文档
		 * @return
		 *
		 */
		final public function get isNew():Boolean
		{
			return _state == DocumentState.NEW;
		}

		/**
		 * 是否已就绪
		 * @return
		 *
		 */
		final public function get isReady():Boolean
		{
			return _state == DocumentState.READY;
		}

		/**
		 * 是否正在保存
		 * @return
		 *
		 */
		final public function get isSaving():Boolean
		{
			return _state == DocumentState.SAVING;
		}

		/**
		 * 是否已改动
		 * @return
		 *
		 */
		final public function get isChanged():Boolean
		{
			return _state == DocumentState.CHANGED || _state == DocumentState.NEW;
		}

		/**
		 * 添加历史
		 * @param op
		 *
		 */
		public function addHistory(op:OpBase):void
		{
			// 截断掉后面的历史记录
			for (var i:int = histores.length - 1; i > historyCursor; i--)
			{
				histores.removeItemAt(i);
			}
			// 追加一条
			histores.addItem(op);
			// 更新操作对象的索引
			op.index = histores.length - 1;
			// 更新指针
			historyCursor = op.index;
		}

		/**
		 * 操作过的历史记录
		 */
		public var histores:ArrayList = new ArrayList();

		private var _historyCursor:int;

		/**
		 * 返回序列化后的字符串，一般是 JSON 格式
		 * @return
		 *
		 */
		public function get rawString():String
		{
			throw new IllegalOperationError("需子类实现");
		}

		/**
		 * 获得历史记录个数
		 * @return
		 *
		 */
		public function get numHistores():int
		{
			return histores.length;
		}

		/**
		 * 当前历史的指针<br>
		 * # 每次添加新记录时，将删除指针后的所有记录，并设置成 histores.length - 1<br>
		 * # 每次 undo 时 -1<br>
		 * # 每次 redo 时 +1<br>
		 */
		public function get historyCursor():int
		{
			return _historyCursor;
		}

		/**
		 * @private
		 */
		public function set historyCursor(value:int):void
		{
			if (_historyCursor < 0 || _historyCursor > numHistores - 1 || _historyCursor == value)
			{
				return;
			}
			_historyCursor = value;

			// historyCursor 之后的记录全部标记为可覆盖
			for (var i:int = 0, n:int = numHistores; i < n; i++)
			{
				var op:OpBase = histores.getItemAt(i) as OpBase;
				op.isOverwritable = i > _historyCursor;
			}
			onHistoryCursorChange.dispatch();
		}

		/**
		 * 当前操作的 OP
		 * @return
		 *
		 */
		public function get currentOP():ChangeDocumentOP
		{
			return histores.getItemAt(historyCursor) as ChangeDocumentOP;
		}

		/**
		 * 下一个 OP
		 * @return
		 *
		 */
		public function get nextOP():ChangeDocumentOP
		{
			if (historyCursor + 1 >= histores.length)
			{
				return null;
			}
			return histores.getItemAt(historyCursor + 1) as ChangeDocumentOP;
		}

		/**
		 * 获得所有模块
		 * @return
		 *
		 */
		protected function get modules():Modules
		{
			return Modules.getInstance();
		}
	}
}
