package ageb.modules.document
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.system.Capabilities;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import spark.components.TabBar;
	import spark.events.IndexChangeEvent;
	import ageb.modules.ModuleBase;
	import ageb.modules.document.op.NewDocument;
	import ageb.modules.document.op.OpenDocument;
	import ageb.utils.FileUtil;
	import ageb.utils.FlashTip;
	import nt.lib.util.assert;
	import nt.lib.util.callLater;
	import org.apache.flex.collections.VectorList;
	import org.osflash.signals.Signal;

	/**
	 * 文档模块
	 * @author zhanghaocong
	 *
	 */
	public class DocumentModule extends ModuleBase
	{
		/**
		 * 创建一个新的文档模块
		 *
		 */
		public function DocumentModule()
		{
			// 没用的构造函数
		}

		/**
		 * 打开了的文档列表
		 */
		public var documents:Vector.<Document> = new Vector.<Document>;

		/**
		 * 用于做数据绑定的文档列表
		 */
		public var documentsVectorList:VectorList = new VectorList(documents);

		/**
		 * currentDocument 属性变化时广播
		 */
		public var onCurrentDocChange:Signal = new Signal();

		/**
		 * 添加文档时广播
		 */
		public var onDocumentAdd:Signal = new Signal(Document);

		/**
		 * 删除文档时广播
		 */
		public var onDocumentRemove:Signal = new Signal(Document);

		/**
		 * 关闭所有时广播
		 */
		public var onDocumentRemoveAll:Signal = new Signal();

		/**
		 * 标记当前是否正在关闭所有文档
		 */
		private var isClosingAll:Boolean = false;

		/**
		 * 添加一个文档到 documents 中<br>
		 * 通常由[新建]，[打开]操作后执行
		 * @param doc
		 *
		 */
		public function addDocument(doc:Document):void
		{
			var index:int = documents.indexOf(doc);

			if (index == -1)
			{
				trace("[DocumentModule] 已添加文档 " + doc.nativePath);
				documentsVectorList.addItem(doc);
			}
			currentDoc = doc;
			onDocumentAdd.dispatch(doc);
		}

		/**
		 * 浏览并添加文档
		 *
		 */
		public function browse():void
		{
			FileUtil.browseFile(settings.getData(settings).lastDocumentPath, [ new FileFilter("txt 文件", "*.txt")], open);
		}

		/**
		 * 检查当前打开文档数目，如果为 0 则添加一个 Dashboard
		 *
		 */
		public function checkAddDashboard():void
		{
			var doc:DashboardDocument = new DashboardDocument();

			if (numDocsOpened == 0)
			{
				documentsVectorList.addItem(doc);
				currentDoc = doc;
			}
		}

		/**
		 * 关闭所有打开了的文档
		 *
		 */
		public function closeAll():void
		{
			if (isClosingAll)
			{
				return;
			}

			// 全部关闭后广播 onDocumentRemoveAll
			if (documents.length == 0)
			{
				onDocumentRemoveAll.dispatch();
				return;
			}
			isClosingAll = true;
			removeDocument(documents[documents.length - 1], function(isSuccess:Boolean):void
			{
				isClosingAll = false;

				// 关闭成功了一个就关闭下一个
				if (isSuccess)
				{
					closeAll();
				}
			});
		}

		/**
		 * 关闭当前打开的文档
		 *
		 */
		public function closeCurrent():void
		{
			var doc:Document = currentDoc;
			removeDocument(currentDoc);
		}

		/**
		* 根据 f 创建一个文档<br>
		* 将会根据内容创建不同类型的文档<br>
		* 同時 Asset 相关的初始化也会在这里进行
		* @param f
		*
		*/
		public function createDocument(f:File):Document
		{
			trace("[DocumentModule] 正在读取 " + f.nativePath);
			var result:Document;

			if (f.isDirectory)
			{
				throw new ArgumentError("参数不能是文件夹");
			}
			result = getDocument(f);

			if (!result)
			{
				var fs:FileStream = new FileStream();
				fs.open(f, FileMode.READ);
				var json:String = fs.readUTFBytes(fs.bytesAvailable);
				fs.close();
				var raw:Object = JSON.parse(json);

				// 场景
				if (raw.hasOwnProperty("charLayerIndex"))
				{
					result = new SceneDocument(f, raw);
				}
				// Avatar
				else if (raw.hasOwnProperty("actions"))
				{
					result = new AvatarDocument(f, raw);
				}
				else
				{
					throw new ArgumentError("文件格式不正确");
				}
				// 执行打开文档操作
				new OpenDocument(result).execute();
			}
			return result;
		}

		/**
		 * 获取 currentDoc 相对于 documents 的索引<br>
		 * 如果 currentDoc 为 null，返回 -1，否则返回 ≥ 0的具体位置
		 * @return
		 *
		 */
		public function get currentDocIndex():int
		{
			if (currentDoc)
			{
				return documents.indexOf(currentDoc);
			}
			return -1;
		}

		private var _currentDoc:Document;

		/**
		 * 设置或获取当前打开的文档
		 * @return
		 *
		 */
		public final function get currentDoc():Document
		{
			return _currentDoc;
		}

		public function set currentDoc(value:Document):void
		{
			// 这种情况我们跳过
			if (value == _currentDoc)
			{
				return;
			}

			// 关闭旧
			if (_currentDoc)
			{
				documentsNav.currentView.doc = null;
				documentsNav.currentView = null;
			}
			_currentDoc = value;

			// 打开新
			if (_currentDoc)
			{
				documentsNav.currentView = documentsNav.getView(value);
				assert(!!documentsNav.currentView, "无法为 " + value + " 创建指定的视图");
				documentsNav.currentView.doc = value;
				tabs.selectedItem = _currentDoc;
			}
			else
			{
				tabs.selectedIndex = -1;
			}
			onCurrentDocChange.dispatch();
		}

		/**
		 * 根据 f 获得打开了的文档，如果没有则返回 null
		 * @param f
		 * @return
		 *
		 */
		public function getDocument(f:File):Document
		{
			for each (var document:Document in documents)
			{
				if (document.file && document.file.nativePath == f.nativePath)
				{
					return document;
				}
			}
			return null;
		}

		/**
		 * 初始化
		 *
		 */
		public function init():void
		{
			// 标签页
			tabs.dataProvider = documentsVectorList;
			tabs.addEventListener(IndexChangeEvent.CHANGE, onChange);
			checkAddDashboard();
			NativeApplication.nativeApplication.openedWindows[0].addEventListener(Event.CLOSING, onClosing);
		}

		/**
		 * 新建场景
		 *
		 */
		public function newDocument():void
		{
			var panel:NewDocumentPanel = NewDocumentPanel.show();
			panel.onCreateScene.addOnce(newSceneDocument);
			panel.onCreateAvatar.addOnce(newAvatarDocument);
		}

		/**
		 * 根据参数新建场景文档
		 * @param id
		 * @param width
		 * @param height
		 *
		 */
		public function newSceneDocument(id:String, width:int, height:int):void
		{
			var template:Object = FileUtil.readJSON(FileUtil.fromApplicationDirectory("templates/empty_scene.txt"));
			template.id = id;
			template.width = width;
			template.height = height;
			var doc:SceneDocument = new SceneDocument(null, template);
			doc.state = DocumentState.NEW;
			new NewDocument(doc).execute();
			addDocument(doc);
		}

		/**
		 * 根据参数创建 AvatarDocument
		 * @param id
		 *
		 */
		public function newAvatarDocument(id:String):void
		{
			var template:Object = FileUtil.readJSON(FileUtil.fromApplicationDirectory("templates/empty_avatar.txt"));
			template.id = id;
			var doc:AvatarDocument = new AvatarDocument(null, template);
			doc.state = DocumentState.NEW;
			new NewDocument(doc).execute();
			addDocument(doc);
		}

		/**
		 * 当前打开的文档数目
		 * @return
		 *
		 */
		public function get numDocsOpened():int
		{
			return documents.length;
		}

		/**
		 * 根据参数打开一个文档
		 * @param f
		 *
		 */
		public function open(f:File):void
		{
			var x:Function = function():void
			{
				var doc:Document = createDocument(f);

				if (doc)
				{
					addDocument(doc);
				}
			};

			if (Capabilities.isDebugger)
			{
				x();
			}
			else
			{
				try
				{
					x();
				}
				catch (error:Error)
				{
					Alert.show(error.message, "错误");
				}
			}
		}

		/**
		 * 根据 avatarID 打开 AvatarDocument
		 * @param avatarID
		 *
		 */
		public function openAvatar(avatarID:String):void
		{
			open(new File(settings.getData(settings).aep).parent.resolvePath("src/avatars/" + avatarID + ".txt"));
		}

		/**
		 * 打开最近的文档
		 *
		 */
		public function openRecent():void
		{
			open(new File(settings.getData(settings).lastDocumentPath));
		}

		/**
		 * 重做
		 *
		 */
		public function redo():void
		{
			if (currentDoc)
			{
				currentDoc.redo();
			}
		}

		/**
		 * 从 documents 中删除一个文档<br>
		 * @param onComplete 一个回调方法<br>
		 * 正确的签名是 function (isClosed:Boolean):void<br>
		 * 当关闭时，isClosed 为 true，否则为 false
		 * @param doc
		 *
		 */
		public function removeDocument(doc:Document, onComplete:Function = null):void
		{
			// doc 不可为 null
			assert(doc is Document);

			if (onComplete == null)
			{
				onComplete = function(isSuccess:Boolean):void
				{
					checkAddDashboard();
				}
			}
			var x:Function = function(isSuccess:Boolean):void
			{
				if (onComplete != null)
				{
					callLater(onComplete, isSuccess);
				}
			}
			var f:Function = function(event:CloseEvent = null):void
			{
				// 点击了取消：什么都不做
				if (event && event.detail == Alert.CANCEL)
				{
					x(false);
					return;
				}

				// 点击了是：保存并关闭
				if (event && event.detail == Alert.YES)
				{
					currentDoc.onSaveComplete.addOnce(f);
					saveCurrent();
					x(true);
					return;
				}
				// 点击了否或通过代码直接调用本方法
				const lastIndex:int = documents.indexOf(doc);
				// lastIndex 不允许为 -1
				assert(lastIndex != -1);
				documentsVectorList.removeItem(doc);
				onDocumentRemove.dispatch(doc);

				// 如果还有文档，就打开前一个
				if (numDocsOpened > 0)
				{
					var newIndex:int = lastIndex - 1 >= 0 ? lastIndex - 1 : 0;
					currentDoc = documents[newIndex];
				}
				else
				{
					currentDoc = null;
				}
				trace("[DocumentModule] 已删除文档 " + doc.name);
				x(true);
			}

			if (doc.isChanged)
			{
				Alert.show(format("已经修改了 {0}。要保存吗？", doc.nativePath), "保存", Alert.YES | Alert.NO | Alert.CANCEL, null, f);
			}
			else
			{
				f();
			}
		}

		/**
		 * 另存为
		 *
		 */
		public function saveAsCurrent():void
		{
			if (currentDoc)
			{
				var file:File = new File(settings.getData(settings).lastDocumentPath).parent.resolvePath(currentDoc.name);
				FileUtil.browseForSave(file.nativePath, function(f:File):void
				{
					settings.getData(settings).lastDocumentPath = f.nativePath;
					currentDoc.file = f;
					currentDoc.save();
				});
			}
		}

		/**
		 * 保存打开了的文档
		 *
		 */
		public function saveCurrent():void
		{
			if (currentDoc)
			{
				// 新建的文档 **必须** 使用另存为
				if (currentDoc.isNew)
				{
					return saveAsCurrent();
				}
				currentDoc.save();
			}
		}

		/**
		 * 切换到下一个窗口
		 *
		 */
		public function showNext():void
		{
			if (currentDocIndex < documents.length - 1)
			{
				currentDoc = documents[currentDocIndex + 1];
			}
			else
			{
				FlashTip.show("已经是最后一个了");
			}
		}

		/**
		 * 切换到上一个窗口
		 *
		 */
		public function showPrev():void
		{
			if (currentDocIndex > 0)
			{
				currentDoc = documents[currentDocIndex - 1];
			}
			else
			{
				FlashTip.show("已经是第一个了");
			}
		}

		/**
		 * 切换 UI 是否显示
		 *
		 */
		public function toggleUIVisible():void
		{
			modules.root.documentsNav.visible = !modules.root.documentsNav.visible;

			if (modules.root.documentsNav.visible)
			{
				FlashTip.show("已显示 UI");
			}
			else
			{
				FlashTip.show("已隐藏 UI");
			}
		}

		/**
		 * 撤销
		 *
		 */
		public function undo():void
		{
			if (currentDoc)
			{
				currentDoc.undo();
			}
		}

		public function preview():void
		{
			if (currentDoc)
			{
				currentDoc.preview();
			}
		}

		public function publish():void
		{
			if (currentDoc)
			{
				currentDoc.publish();
			}
		}

		/**
		 * 获得文档导航器组件
		 * @return
		 *
		 */
		protected final function get documentsNav():DocumentsNav
		{
			return modules.root.documentsNav;
		}

		protected function onChange(event:IndexChangeEvent = null):void
		{
			currentDoc = tabs.selectedItem as Document;
		}

		protected function onClosing(event:Event):void
		{
			// 已经在关闭过程中
			if (!isClosingAll)
			{
				// 侦听一次全关事件
				onDocumentRemoveAll.addOnce(NativeApplication.nativeApplication.exit);
				// 执行全关
				closeAll();
			}
			// 我们将以编程方式关闭程序
			// 无论如何，这里就先停掉默认行为
			event.preventDefault();
		}

		/**
		 * 标签页组件
		 *
		 */
		protected final function get tabs():TabBar
		{
			return modules.root.tabs;
		}
	}
}
