package nt.ui.util
{
	import flash.display.InteractiveObject;
	import flash.display.Stage;

	/**
	 * 表示一组快捷键
	 * @author zhanghaocong
	 *
	 */
	public class Shortcut
	{
		public var keys:Array;

		public var callback:Function;

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
			// 不指定作用域表示永远生效
			if (!scopes)
			{
				return true;
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
	}
}
