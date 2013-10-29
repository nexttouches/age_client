package ageb.utils
{
	import flash.events.Event;
	import flash.events.FileListEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	/**
	 * 文件工具类
	 * @author zhanghaocong
	 *
	 */
	public class FileUtil
	{
		public function FileUtil()
		{
		}

		/**
		 * 获得相对于 File.applicationDirectory 的文件
		 * @param path 相对路径
		 * @return
		 *
		 */
		public static function fromApplicationDirectory(path:String):File
		{
			return File.applicationDirectory.resolvePath(path);
		}

		/**
		 * 根据路径获得一个 File，如出现任何错误，将返回 ifFail
		 * @param nativePath 完整路径
		 * @param ifFail 可选，失败时返回的 File
		 * @return
		 *
		 */
		public static function getFile(nativePath:String, ifFail:File = null):File
		{
			try
			{
				var result:File = new File(nativePath);
			}
			catch (error:Error)
			{
				result = ifFail || File.desktopDirectory;
			}
			return result;
		}

		/**
		 * 浏览文件夹打开
		 * @param nativePath 完整路径
		 * @param onComplete
		 * @param ifFail
		 * @param onCancel
		 *
		 */
		public static function browseDir(nativePath:String, onComplete:Function, ifFail:File = null, onCancel:Function = null):void
		{
			var f:File = FileUtil.getFile(nativePath, ifFail);
			var onSelect:Function = function(e:Event):void
			{
				if (onCancel1 != null)
				{
					f.removeEventListener(Event.CANCEL, onCancel1);
				}
				onComplete(e.currentTarget);
			};

			if (onCancel != null)
			{
				var onCancel1:Function = function(e:Event):void
				{
					onCancel(e.currentTarget);
				};
			}
			f.addEventListener(Event.SELECT, onSelect);

			if (onCancel1 != null)
			{
				f.addEventListener(Event.CANCEL, onCancel1);
			}

			try
			{
				f.browseForDirectory("选择文件夹");
			}
			catch (error:Error)
			{
				f.removeEventListener(Event.SELECT, onSelect);

				if (onCancel != null)
				{
					f.removeEventListener(Event.CANCEL, onCancel1);
				}
			}
		}

		/**
		 * 浏览单个文件打开
		 * @param nativePath 初始目录，如不存在将使用 ifFail 目录
		 * @param filters 文件类型过滤器
		 * @param onComplete 完成时的回调。正确的签名是 <code>function (file:File):void;</code>，其中参数 <code>file</code> 是指选中的文件
		 * @param ifFail 可选，初始目录不存在时使用的目录，默认是桌面
		 * @param onCancel 可选，用户点击取消时的回调。正确的签名是 <code>function (file:File):void</code>，其中参数 <code>file</code> 是指初始目录
		 *
		 */
		public static function browseFile(nativePath:String, filters:Array, onComplete:Function, ifFail:File = null, onCancel:Function = null):void
		{
			var f:File = FileUtil.getFile(nativePath, ifFail);
			var onSelect:Function = function(e:Event):void
			{
				if (onCancel1 != null)
				{
					f.removeEventListener(Event.CANCEL, onCancel1);
				}
				onComplete(e.currentTarget);
			};

			if (onCancel != null)
			{
				const onCancel1:Function = function(e:Event):void
				{
					onCancel(e.currentTarget);
				}
			}
			f.addEventListener(Event.SELECT, onSelect);

			if (onCancel1 != null)
			{
				f.addEventListener(Event.CANCEL, onCancel1);
			}

			try
			{
				f.browseForOpen("选择文件", filters);
			}
			catch (error:Error)
			{
				f.removeEventListener(Event.SELECT, onSelect);

				if (onCancel1 != null)
				{
					f.removeEventListener(Event.CANCEL, onCancel1);
				}
			}
		}

		/**
		 * 浏览多个文件打开
		 * @param nativePath 初始目录，如不存在将使用 ifFail 目录
		 * @param filters 文件类型过滤器
		 * @param onComplete 完成时的回调。正确的签名是 <code>function (files:Vector.<File>):void;</code>，其中参数 <code>files</code> 是指选中的文件列表
		 * @param ifFail 可选，初始目录不存在时使用的目录，默认是桌面
		 * @param onCancel 可选，用户点击取消时的回调。正确的签名是 <code>function (file:File):void</code>，其中参数 <code>file</code> 是指初始目录
		 *
		 */
		public static function browseFileMultiple(nativePath:String, filters:Array, onComplete:Function, ifFail:File = null, onCancel:Function = null):void
		{
			var f:File = FileUtil.getFile(nativePath, ifFail);
			var onSelect:Function = function(e:FileListEvent):void
			{
				if (onCancel1 != null)
				{
					f.removeEventListener(Event.CANCEL, onCancel1);
				}
				onComplete(Vector.<File>(e.files));
			};

			if (onCancel != null)
			{
				const onCancel1:Function = function(e:Event):void
				{
					onCancel(e.currentTarget);
				}
			}
			f.addEventListener(FileListEvent.SELECT_MULTIPLE, onSelect);

			if (onCancel1 != null)
			{
				f.addEventListener(Event.CANCEL, onCancel1);
			}

			try
			{
				f.browseForOpenMultiple("选择多个文件", filters);
			}
			catch (error:Error)
			{
				f.removeEventListener(Event.SELECT, onSelect);

				if (onCancel1 != null)
				{
					f.removeEventListener(Event.CANCEL, onCancel1);
				}
			}
		}

		/**
		 * 浏览文件并保存
		 * @param nativePath 初始目录，如不存在将使用 ifFail 目录
		 * @param onComplete 完成时的回调。正确的签名是 <code>function (file:File):void;</code>，其中参数 <code>file</code> 是指选中的文件
		 * @param ifFail 可选，初始目录不存在时使用的目录，默认是桌面
		 *
		 */
		public static function browseForSave(nativePath:String, onComplete:Function, ifFail:File = null):void
		{
			var f:File = FileUtil.getFile(nativePath, ifFail);
			var onSelect:Function = function(e:Event):void
			{
				onComplete(e.currentTarget);
			}
			f.addEventListener(Event.SELECT, onSelect);

			try
			{
				f.browseForSave("选择文件");
			}
			catch (error:Error)
			{
				f.removeEventListener(Event.SELECT, onSelect);
			}
		}

		/**
		 * 读取 XML
		 * @param fileOrPath 要读取的路径，可以是实际路径的字符串或 File 对象
		 * @return 读取失败返回 null，否则返回实际内容
		 *
		 */
		public static function readXML(fileOrPath:*):XML
		{
			const result:String = readString(fileOrPath);

			if (result)
			{
				return XML(result);
			}
			return null;
		}

		/**
		 * 读取 JSON
		 * @param fileOrPath 要读取的路径，可以是实际路径的字符串或 File 对象
		 * @return 读取失败返回 null，否则返回实际内容
		 *
		 */
		public static function readJSON(fileOrPath:*):Object
		{
			const result:String = readString(fileOrPath);

			if (result)
			{
				return JSON.parse(readString(fileOrPath));
			}
			return null;
		}

		/**
		 * 以 UTF-8 编码读取字符串
		 * @param fileOrPath 要读取的路径，可以是实际路径的字符串或 File 对象
		 * @return 读取失败返回 "" （空字符串），否则返回实际的内容
		 *
		 */
		public static function readString(fileOrPath:*):String
		{
			if (!(fileOrPath is File))
			{
				fileOrPath = new File(fileOrPath);
			}

			if (!fileOrPath.exists)
			{
				return "";
			}
			var fs:FileStream = new FileStream();
			fs.open(fileOrPath, FileMode.READ);
			var content:String = fs.readUTFBytes(fs.bytesAvailable);
			fs.close();
			return content;
		}

		/**
		 * 根据文件名中的数字进行排序的方法，将产生以下结果
		 * <ul>
		 * 	<li>["0_1.jpg", "0_2.jpg", "0.jpg"] -> ["0.jpg", "0_1.jpg", "0_2.jpg"]</li>
		 * 	<li>["1.jpg", "2.jpg", "0.jpg"] -> ["0.jpg", "1.jpg", "2.jpg"]</li>
		 * </ul>
		 * @param a A 文件
		 * @param b B 文件
		 * @return
		 *
		 */
		public static function sortByNumber(a:File, b:File):int
		{
			while (true)
			{
				const aMatch:Array = a.name.match(/(\d+)/g);
				const bMatch:Array = b.name.match(/(\d+)/g);

				if (aMatch.length == 0 && bMatch.length == 0)
				{
					break;
				}
				const aInt:int = int(aMatch);
				const bInt:int = int(bMatch);

				if (aInt > bInt)
				{
					return 1;
				}
				else if (aInt < bInt)
				{
					return -1;
				}
			}
			return 0;
		}
	}
}
