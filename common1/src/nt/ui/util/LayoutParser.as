package nt.ui.util
{
	import flash.display.DisplayObjectContainer;
	import flash.utils.getDefinitionByName;
	import nt.lib.reflect.Type;
	import nt.ui.core.Component;
	import org.osflash.signals.ISignal;

	public class LayoutParser
	{
		private static var aliases:Object = {};

		public static function register(classRef:Class, alias:String = null):void
		{
			if (!alias)
			{
				alias = Type.of(classRef).shortname;
			}

			if (!aliases[classRef])
			{
				aliases[alias] = classRef;
			}
			else
			{
				throw new Error(format("注册失败，已有 {0}，不能重复注册", alias));
			}
		}

		public static function parse(layout:XML, signalHandlers:Object = null, root:Component = null):Component
		{
			var result:Component;
			var specialProps:Object = {};
			var classRef:Class = aliases[layout.name()];

			if (!classRef)
			{
				classRef = getDefinitionByName("game.ui.components." + layout.name()) as Class;
			}
			result = new classRef();

			if (!signalHandlers)
			{
				signalHandlers = result;
			}

			if (!root)
			{
				root = result;
			}
			// id is special case, maps to name as well.
			var id:String = layout.@id;

			if (id != "")
			{
				result.name = id;
			}

			// every other attribute handled essentially the same
			for each (var attrib:XML in layout.attributes())
			{
				var prop:String = attrib.name().toString();

				// if the property exists on the component, assign it.
				if (prop in result)
				{
					// special handling to correctly parse booleans
					if (result[prop] is Boolean)
					{
						result[prop] = attrib == "true";
					}
					// special handling - these values should be set last.
					else if (prop == "value" || prop == "lowValue" || prop == "highValue" || prop == "choice")
					{
						specialProps[prop] = attrib;
					}
					else if (Type.of(result).getProperty(prop).type == Class) // 处理类类型的属性
					{
						if (attrib in aliases)
						{
							result[prop] = aliases[attrib];
						}
						else
						{
							result[prop] = getDefinitionByName(attrib);
						}
					}
					else if (signalHandlers && Type.of(result).getProperty(prop).type == ISignal) //ISignal 的特殊处理
					{
						if (!(attrib in signalHandlers))
						{
							throw new ArgumentError(result.name + " 上配置了 " + prop + "，但在 " + signalHandlers + " 上找不到回调方法 " + attrib);
						}
						ISignal(result[prop]).add(signalHandlers[attrib]); // 取 parent 的属性
					}
					else
					{
						result[prop] = String(attrib);
					}
				}
			}

			// now handle special props
			for (prop in specialProps)
			{
				result[prop] = specialProps[prop];
			}

			// child nodes will be added as children to the instance just created.
			for each (var childNode:XML in layout.children())
			{
				var child:Component = parse(childNode, signalHandlers, root);

				if (child != null)
				{
					if (child.name in root)
					{
						root[child.name] = child;
					}
					result.addChild(child);
				}
			}
			return result;
		}
	}
}
import nt.ui.components.ComboBox;
import nt.ui.components.FramePanel;
import nt.ui.components.HScrollBar;
import nt.ui.components.HSlider;
import nt.ui.components.Image;
import nt.ui.components.InputText;
import nt.ui.components.Label;
import nt.ui.components.List;
import nt.ui.components.Panel;
import nt.ui.components.PushButton;
import nt.ui.components.RichText;
import nt.ui.components.RichTextArea;
import nt.ui.components.Scale9Image;
import nt.ui.components.ScrollPane;
import nt.ui.components.SelectableList;
import nt.ui.components.ToggleButton;
import nt.ui.components.VScrollBar;
import nt.ui.components.VSlider;
import nt.ui.containers.Canvas;
import nt.ui.containers.HBox;
import nt.ui.containers.UIContainer;
import nt.ui.containers.VBox;
import nt.ui.core.Component;
import nt.ui.util.LayoutParser;
LayoutParser.register(Component);
LayoutParser.register(VBox);
LayoutParser.register(HBox);
LayoutParser.register(Label);
LayoutParser.register(RichText);
LayoutParser.register(Scale9Image);
LayoutParser.register(PushButton);
LayoutParser.register(InputText);
LayoutParser.register(Panel);
LayoutParser.register(RichTextArea);
LayoutParser.register(ScrollPane);
LayoutParser.register(Canvas);
LayoutParser.register(VSlider);
LayoutParser.register(VScrollBar);
LayoutParser.register(HSlider);
LayoutParser.register(HScrollBar);
LayoutParser.register(FramePanel);
LayoutParser.register(Image);
LayoutParser.register(UIContainer);
LayoutParser.register(ToggleButton);
LayoutParser.register(List);
LayoutParser.register(SelectableList);
LayoutParser.register(ComboBox);
