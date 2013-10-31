package ageb.modules.tools
{
	import mx.events.FlexEvent;
	import spark.components.NavigatorContent;
	import spark.layouts.VerticalLayout;
	import ageb.modules.Modules;
	import ageb.modules.ae.SceneRendererEditable;
	import ageb.modules.document.AvatarDocument;
	import ageb.modules.document.Document;
	import ageb.modules.document.SceneDocument;
	import nt.lib.reflect.Type;

	/**
	 * ToolBase 是所有工具的抽象基类<br>
	 * 工具类本身是一个 NavigatorContent，可以被添加到 ViewStack 中，并且和 ButtonBar 或 TabBar 绑定
	 * @author zhanghaocong
	 *
	 */
	public class ToolBase extends NavigatorContent
	{
		/**
		 * 快捷键
		 */
		public var shortcut:String;

		/**
		 * 当前工具在哪些文档类型中可用<br>
		 * 为 null 表示都可以使用<br>
		 * 不为 null 时，将检查数组中的元素
		 */
		public var availableDocs:Vector.<Class>;

		/**
		 * 创建一个新的 ToolBase
		 * @param name 工具名称
		 * @param shortcut 快捷键
		 * @param icon 图标
		 * @param availableDocuments 设置该工具在哪些文档类型中可用，详见 availableDocuments 字段说明
		 *
		 */
		public function ToolBase(name:String = "未命名工具", shortcut:String = null, icon:Class = null, availableDocs:Vector.<Class> = null)
		{
			super();
			this.name = name;
			this.shortcut = shortcut;
			this.icon = icon || DEFAULT_TOOL_ICON_CLASS;
			this.availableDocs = availableDocs;
			percentWidth = 100;
			percentHeight = 100;
			addEventListener(FlexEvent.SHOW, onShow);
			var l:VerticalLayout = new VerticalLayout();
			l.paddingBottom = l.paddingLeft = l.paddingRight = l.paddingTop = 2;
			layout = l;
			loadSettings();
		}

		/**
		 * 选择工具时调用
		 * @param event
		 *
		 */
		protected function onShow(event:FlexEvent):void
		{
		}

		/**
		 * 按照设计，tooltip 是不能修改的<br>
		 * 这里增加空 setter 方法<br>
		 * 可以避免出现无法绑定 XXX 的警告
		 */
		[Bindable("tooltipChange")]
		public function set tooltip(value:String):void
		{
		}

		/**
		 * Tooltip
		 * @return
		 *
		 */
		public function get tooltip():String
		{
			return name + " (" + (shortcut ? shortcut : "快捷键未设置") + ")";
		}

		/**
		 * @private
		 * @return
		 *
		 */
		public override function toString():String
		{
			return Type.of(this).shortname + " (" + name + ")";
		}

		private var _isSelected:Boolean;

		/**
		 * 设置或获取当前工具是否已被选中
		 * @return
		 *
		 */
		public function get isSelected():Boolean
		{
			return _isSelected;
		}

		public function set isSelected(value:Boolean):void
		{
			_isSelected = value;
		}

		private var _doc:Document;

		/**
		 * 设置或获取当前工具关联的文档对象
		 * @return
		 *
		 */
		public function get doc():Document
		{
			return _doc;
		}

		public function set doc(value:Document):void
		{
			trace("[" + name + "] doc change: old=", _doc, "new=", value);
			_doc = value;
		}

		/**
		 * 关联的 SceneDocument
		 * @return
		 *
		 */
		public function get sceneDoc():SceneDocument
		{
			return _doc as SceneDocument;
		}

		/**
		 * 关联的 AvatarDocument
		 * @return
		 *
		 */
		public function get avatarDoc():AvatarDocument
		{
			return _doc as AvatarDocument;
		}

		/**
		 * 获得唯一的 SceneRendererEditable
		 * @return
		 *
		 */
		protected function get sceneRenderer():SceneRendererEditable
		{
			return Modules.getInstance().ae.sceneRenderer;
		}

		/**
		 * 获得设置数据
		 * @return
		 *
		 */
		protected function get settings():Object
		{
			return Modules.getInstance().settings.getData(this);
		}

		/**
		 * 从 settings 加载必要的数据
		 *
		 */
		protected function loadSettings():void
		{
		}

		/**
		 * 保存设置
		 *
		 */
		protected function saveSettings():void
		{
			Modules.getInstance().settings.save();
		}

		/**
		 * 默认图标
		 */
		[Embed(source="../assets/icons/tools.png")]
		public static var DEFAULT_TOOL_ICON_CLASS:Class;
	}
}
