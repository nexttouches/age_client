package nt.ui.util
{
	import avmplus.getQualifiedClassName;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import nt.lib.reflect.Type;
	import nt.lib.reflect.Variable;
	import nt.ui.core.ISkinnable;

	public class SkinParser
	{
		public static function parse(target:ISkinnable, skin:*):void
		{
			if (skin)
			{
				if (skin is Class)
				{
					skin = new skin();
				}
				else if (skin is DisplayObject)
				{
					// do nothing
				}
				else
				{
					throw new Error("skin 必须是 DisplayObject 或其子类");
				}
				target.x = skin.x;
				target.y = skin.y;
				var type:Type = Type.of(target);

				for each (var variable:Variable in type.variables)
				{
					parseSkinPart(target, skin, variable);
				}
				target.setSkin(skin as DisplayObject);
				skin.x = 0;
				skin.y = 0;
			}
		}

		private static function parseSkinPart(target:ISkinnable, skin:DisplayObject, variable:Variable):void
		{
			if (variable.getMetadata("Skin"))
			{
				if (variable.name in skin)
				{
					assignVariable(target, skin[variable.name], variable);
				}
				else if (!variable.getMetadata("Skin").getArg("optional"))
				{
					throw new Error(format("分析皮肤失败：在 {1} 中找不到 {0} 的定义", variable.name, getQualifiedClassName(skin)));
				}
			}
		}

		private static function assignVariable(target:ISkinnable, part:DisplayObject, variable:Variable):void
		{
			if (Type.of(variable.type).isImplementsInterface(ISkinnable))
			{
				var parent:DisplayObjectContainer = part.parent;
				var index:int = parent.getChildIndex(part);
				var comp:DisplayObject = new (variable.type)(part);
				comp.name = variable.name;
				comp.width = part.width;
				comp.height = part.height;
				parent.addChildAt(comp, index);
				target[variable.name] = comp;
			}
			else
			{
				target[variable.name] = part;
			}
		}
	}
}
