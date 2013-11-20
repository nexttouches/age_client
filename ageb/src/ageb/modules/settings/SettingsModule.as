package ageb.modules.settings
{
	import flash.desktop.NativeApplication;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.net.SharedObject;
	import flash.utils.Dictionary;
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import age.data.AvatarInfo;
	import age.data.ObjectType;
	import age.data.SceneInfo;
	import ageb.modules.Modules;
	import ageb.utils.FileUtil;
	import nt.assets.AssetConfig;
	import nt.lib.reflect.Type;
	import org.osflash.signals.Signal;

	/**
	 * 设置模块<br>
	 * 还包含一个用户界面
	 * @author zhanghaocong
	 *
	 */
	public class SettingsModule extends SettingsPanel
	{
		/**
		 * 创建一个新的 SettingsModule
		 *
		 */
		public function SettingsModule()
		{
			super();
		}

		private var so:SharedObject;

		/**
		 * 供 List 等组件使用的 ObjectType 列表
		 */
		[Bindable]
		public var objectTypes:ArrayList = new ArrayList();

		/**
		 * 标记当前项目文件是否有效
		 */
		[Bindable]
		public var ageprojectVaild:Boolean;

		/**
		 * 窗口标题变化时广播
		 */
		public var onWindowTitleChange:Signal = new Signal();

		private var _windowTitle:String;

		/**
		 * 设置支持的版本号
		 */
		private static const VAILD_VERSION:String = "1.0";

		/**
		 * 设置或获取窗口标题<br>
		 * 修改后将触发 onWindowTitleChange
		 * @return
		 *
		 */
		public function get windowTitle():String
		{
			return _windowTitle;
		}

		public function set windowTitle(value:String):void
		{
			_windowTitle = value;
			NativeApplication.nativeApplication.openedWindows[0].title = _windowTitle;
			onWindowTitleChange.dispatch();
		}

		/**
		 * 初始化
		 *
		 */
		public function init():void
		{
			so = SharedObject.getLocal("settings");
			setDefaults();
		}

		/**
		 * 设置默认值
		 *
		 */
		private function setDefaults(... ignored):void
		{
			objectTypes.source = constantsToArray(ObjectType);
			checkProjectFile();
			render();
		}

		/**
		 * 检查项目文件
		 *
		 */
		private function checkProjectFile():void
		{
			var lastProjectFolderVaild:Boolean = ageprojectVaild;
			ageprojectVaild = false;
			var ageproject:String = getData(this).ageproject;

			if (ageproject)
			{
				try
				{
					var file:File = new File(ageproject);

					if (file.exists)
					{
						var content:Object = FileUtil.readJSON(file);
						ageprojectVaild = content.version == VAILD_VERSION;

						// 必须重启才可以生效
						if (lastProjectFolderVaild)
						{
							restartTipField.visible = true;
						}
						else
						{
							AssetConfig.init(file.parent.url + content.paths.assets);
							AvatarInfo.init({}, content.paths.avatars);
							SceneInfo.init({}, content.paths.scenes);
						}
					}
				}
				catch (error:Error)
				{
				}
			}

			if (ageprojectVaild)
			{
				render();
			}
			else
			{
				Alert.show("AGE 项目文件不存在，请先设置", "提示", Alert.YES, null, function(event:CloseEvent):void
				{
					browseProjectFile();
				});
			}
		}

		/**
		 * 浏览项目文件
		 *
		 */
		override protected function browseProjectFile():void
		{
			FileUtil.browseFile("", [ new FileFilter("AGE Project file", "*.ageproject")], browseProjectFile_onComplete, null, setDefaults);
		}

		/**
		 * 用户选择了项目文件后调用
		 * @param f
		 *
		 */
		private function browseProjectFile_onComplete(f:File):void
		{
			getData(this).ageproject = f.nativePath;
			setDefaults();
		}

		/**
		 * 更新面板内容
		 *
		 */
		override protected function render():void
		{
			renderWindowTitle();

			if (!parent || !initialized)
			{
				return;
			}
			projectFolderField.text = getData(this).ageproject;
			tpPathField.text = getData(this).tpPath;
			imPathField.text = getData(this).imPath;
		}

		/**
		 * 渲染窗口标题
		 *
		 */
		protected function renderWindowTitle():void
		{
			var desc:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = desc.namespaceDeclarations()[0]; // shit namespace
			windowTitle = format("{2} - {0} {1}", String(desc.child(new QName(ns, "name"))), String(desc.child(new QName(ns, "versionLabel"))), getData(this).ageproject ? getData(this).ageproject : "无项目");
		}

		/**
		 * 打开设置面板
		 *
		 */
		public function open(... ignored):void
		{
			PopUpManager.addPopUp(this, Modules.getInstance().root, true);
			PopUpManager.centerPopUp(this);
		}

		/**
		 * 浏览 TP
		 *
		 */
		override protected function browseTPPath():void
		{
			FileUtil.browseFile("", [ new FileFilter("Executables", "*.exe", "")], browseTPPath_onComplete);
		}

		/**
		 * 用户选择 TP 后调用
		 * @param f
		 *
		 */
		private function browseTPPath_onComplete(f:File):void
		{
			getData(this).tpPath = f.nativePath;
			render();
		}

		/**
		 * 测试 TP
		 *
		 */
		override protected function testTP():void
		{
			if (!getData(this).tpPath)
			{
				Alert.show("请先设置 TP 路径", "错误");
			}
			else
			{
				modules.job.addJob(new ShowTPVersionJob);
			}
		}

		/**
		 * 浏览 im
		 *
		 */
		override protected function browseIMPath():void
		{
			FileUtil.browseFile("", [ new FileFilter("Executables", "convert.exe", "")], browseIMPath_onComplete);
		}

		/**
		* 用户选择 im 后调用
		* @param f
		*
		*/
		private function browseIMPath_onComplete(f:File):void
		{
			getData(this).imPath = f.nativePath;
			render();
		}

		/**
		 * 测试 im
		 *
		 */
		override protected function testIM():void
		{
			if (!getData(this).imPath)
			{
				Alert.show("请先设置 IM 路径", "错误");
			}
			else
			{
				modules.job.addJob(new ShowIMVersionJob);
			}
		}

		/**
		 * 保存设置
		 *
		 */
		public function save():void
		{
			so.flush();
		}

		/**
		 * 使用指定对象作为 key 查询对应的设置<br>
		 * 这个 key 可以是对象或字符串<br>
		 * 如果是对象，将使用该对象的类全名作为实际存取用键<br>
		 * 如果是字符串将使用本身作为 key<br>
		 * 如果为 null 将使用 SettingsModule 实例对象<br>
		 * @param key
		 * @return
		 *
		 */
		public function getData(stringOrObject:* = null):Object
		{
			if (!stringOrObject)
			{
				stringOrObject = this;
			}
			return data[stringOrObject is String ? stringOrObject : Type.of(stringOrObject).fullname] ||= {};
		}

		/**
		 * @private
		 * @return
		 *
		 */
		protected function get data():Object
		{
			return so.data;
		}

		/**
		 * @private
		 * @return
		 *
		 */
		protected function get modules():Modules
		{
			return Modules.getInstance();
		}
	}
}
