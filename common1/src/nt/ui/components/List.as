package nt.ui.components
{
	import flash.display.DisplayObject;
	import flash.system.Capabilities;
	import nt.lib.reflect.Type;
	import nt.lib.util.DataProvider;
	import nt.ui.components.listitemclasses.LabelListItem;
	import nt.ui.containers.AbstractLayoutContainer;
	import nt.ui.containers.VBox;
	import nt.ui.util.ISelectable;

	public class List extends ScrollPane
	{
		public var content:AbstractLayoutContainer;

		public function List()
		{
			super();
		}

		protected var _dataProvider:DataProvider;

		public function get dataProvider():DataProvider
		{
			return _dataProvider;
		}

		public function set dataProvider(value:DataProvider):void
		{
			if (_dataProvider)
			{
				value.onAdd.remove(dataProvider_onAdd);
				value.onRemove.remove(dataProvider_onRemove);
				value.onCurrentPageChange.remove(dataProvider_onCurrentPageChange);
			}
			_dataProvider = value;

			if (!_itemClass)
			{
				itemClass = LabelListItem;
			}

			if (!_layoutClass)
			{
				layoutClass = VBox;
			}

			if (_dataProvider)
			{
				value.onAdd.add(dataProvider_onAdd);
				value.onRemove.add(dataProvider_onRemove);
				value.onCurrentPageChange.add(dataProvider_onCurrentPageChange);
			}
			isNeedRender = true;
			invalidate();
		}

		protected function dataProvider_onCurrentPageChange(page:int):void
		{
			isNeedRender = true;
			invalidate();
		}

		protected function dataProvider_onRemove(index:int):void
		{
			isNeedRender = true;
			invalidate();
		}

		protected function dataProvider_onAdd(index:int):void
		{
			isNeedRender = true;
			invalidate();
		}

		private var _layoutClass:Class;

		public function get layoutClass():Class
		{
			return _layoutClass;
		}

		public function set layoutClass(value:Class):void
		{
			if (!value)
			{
				throw new ArgumentError("layoutClass 不能为  null");
			}

			if (!Type.of(value).isExtendsClass(AbstractLayoutContainer))
			{
				throw new ArgumentError("layoutClass 必须是 AbstractLayoutContainer 的子类");
			}
			_layoutClass = value;

			if (content)
			{
				removeChild(content);
				content = null;
			}
			content = new value();
			addChild(content);
			isNeedRender = true;
			invalidate();
		}

		private var _itemClass:Class;

		public function get itemClass():Class
		{
			return _itemClass;
		}

		public function set itemClass(value:Class):void
		{
			if (value == null)
			{
				throw new ArgumentError("itemClass 不能是 null");
			}

			if (Capabilities.isDebugger)
			{
				if (!Type.of(value).isImplementsInterface(IDataRenderer))
				{
					throw new ArgumentError("itemClass 必须实现 IDataRenderer");
				}

				if (!Type.of(value).isExtendsClass(DisplayObject))
				{
					throw new ArgumentError("itemClass 必须继承自 DisplayObject");
				}
			}

			if (!items)
			{
				items = new Vector.<DisplayObject>();
			}
			else
			{
				removeAllItems();
			}
			_itemClass = value;
			isNeedRender = true;
			invalidate();
		}

		protected var items:Vector.<DisplayObject>;

		protected var isNeedRender:Boolean;

		override protected function render():void
		{
			super.render();

			if (isNeedRender)
			{
				isNeedRender = false;

				if (items)
				{
					var currentPageContent:* = _dataProvider ? _dataProvider.currentPageContent : empty;
					var n:int;

					if (currentPageContent.length > items.length)
					{
						n = currentPageContent.length;
					}
					else
					{
						n = items.length;
					}

					for (var i:int = 0; i < n; i++)
					{
						if (i in currentPageContent)
						{
							if (!(i in items) || (i in items && items[i] == null))
							{
								items[i] = createItem(i);
							}
							IDataRenderer(items[i]).data = currentPageContent[i];
						}
						else
						{
							removeItem(i);
						}
					}
					items.length = n;
				}
			}
		}

		override public function dispose():Boolean
		{
			removeAllItems();
			return super.dispose();
		}

		protected function removeAllItems():void
		{
			while (items.length)
			{
				removeItem(items.length - 1);
			}
			items.length = 0;
		}

		internal function createItem(index:int):DisplayObject
		{
			return content.addChild(new _itemClass);
		}

		internal function removeItem(index:int):void
		{
			if (items[index] != null)
			{
				ISelectable(items[index]).index = -1;
				content.removeChild(items[index]);
				items[index] = null;
			}
		}
	}
}

/**
 * helper
 */
var empty:Array = [];
