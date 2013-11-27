package nt.ui.util
{
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.text.TextField;

	/**
	 * 表示一组快捷键
	 * @author zhanghaocong
	 *
	 */
	public class Shortcut
	{
		/**
		 * 按键组合
		 */
		public var keys:Array;

		/**
		 * 快捷键按下后的回调
		 */
		public var callback:Function;

		/**
		 * 有效返回，该数组内全部是 InteractiveObject 的子类
		 */
		public var scopes:Array;

		/**
		 * 创建一个新的快捷键
		 * @param keys
		 * @param callback
		 * @param scopes
		 *
		 */
		public function Shortcut(keys:Array, callback:Function, scopes:Array = null)
		{
			this.keys = keys;
			this.callback = callback;
			this.scopes = scopes;
		}

		public function isInScope(focus:InteractiveObject):Boolean
		{
			// 使用默认的全局作用域时，需增加 excludes 的判断
			if (!scopes)
			{
				return !isInExcludes(focus);
			}

			for (var i:int = 0, n:int = scopes.length; i < n; i++)
			{
				// 若为 Stage，总是生效
				if (scopes[i] is Stage || scopes[i] == Stage)
				{
					return true;
				}

				// 若等于指定的焦点对象，也生效
				if (scopes[i] == focus || scopes[i] == focus["constructor"])
				{
					return true;
				}
			}
			return false;
		}

		/**
		 * 判断指定的对象是否不在排出列表中
		 * @param focus
		 * @return
		 *
		 */
		[Inline]
		final public function isInExcludes(focus:InteractiveObject):Boolean
		{
			for (var i:int = 0; i < ShortcutUtil.excludeClasses.length; i++)
			{
				if (focus is ShortcutUtil.excludeClasses[i])
				{
					return true;
				}
			}
			return false;
		}
	}
}
