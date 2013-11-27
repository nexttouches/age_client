package nt.ui.util
{
	import flash.display.Stage;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;

	/**
	 * 快捷键工具
	 * @author zhanghaocong
	 *
	 */
	public class ShortcutUtil
	{
		/**
		 * 全部都是静态方法，不需要构造函数
		 *
		 */
		public function ShortcutUtil()
		{
			throw new IllegalOperationError("不能实例化 ShortcutUtil");
		}

		/**
		 * 存 stage 引用
		 */
		private static var nativeStage:Stage;

		/**
		 * 按键间隔。记录相同的键 2 次按下间隔（毫秒）
		 */
		private static var keyDownIntervals:Vector.<int> = new Vector.<int>(128);

		/**
		 * 以 keyCode 为索引记录最后一次松开时间（通过 getTimer 实现）
		 */
		private static var keyUpTime:Vector.<int> = new Vector.<int>(128);

		/**
		 * 以 keyCode 为索引记录最后一次按下时间（通过 getTimer 实现）
		 */
		private static var keyDownTime:Vector.<int> = new Vector.<int>(128);

		/**
		 * 以 keyCode 为索引记录键按下列表。记录按下 (true) 与否
		 */
		private static var keyDownList:Vector.<Boolean> = new Vector.<Boolean>(128);

		/**
		 * 检查左键是否已按下<br>
		 * 有些快捷键会用到
		 */
		public static var isLeftDown:Boolean;

		/**
		 * 检查右键是否已按下<br>
		 * 有些快捷键会用到
		 */
		public static var isRightDown:Boolean;

		/**
		 * 检查中键是否已按下<br>
		 * 有些快捷键会用到
		 */
		public static var isMiddleDown:Boolean;

		/**
		 * 当聚焦在这些对象时，将不会激活快捷键，除非强制指定
		 */
		public static var excludeClasses:Vector.<Class>;

		/**
		 * 初始化快捷键小工具
		 * @param stage 用于侦听 keyDown 和 keyUp 的 stage
		 * @param excludes 全局设置不会激活快捷键的类
		 */
		public static function init(nativeStage:Stage, excludes:Vector.<Class>):void
		{
			ShortcutUtil.nativeStage = nativeStage;
			ShortcutUtil.excludeClasses = excludes || new Vector.<Class>;
			nativeStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			nativeStage.addEventListener(KeyboardEvent.KEY_UP, onkeyUp);
			nativeStage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMiddleMouseDown, false, int.MAX_VALUE);
			nativeStage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMiddleMouseUp, false, int.MAX_VALUE);
			nativeStage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown, false, int.MAX_VALUE);
			nativeStage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onRightMouseUp, false, int.MAX_VALUE);
			nativeStage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, int.MAX_VALUE);
			nativeStage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, int.MAX_VALUE);
			nativeStage.addEventListener(Event.DEACTIVATE, onDeactive, false, int.MAX_VALUE);
			nativeStage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave, false, int.MAX_VALUE);
		}

		protected static function onMouseLeave(event:Event):void
		{
			isMiddleDown = false;
			isLeftDown = false;
			isRightDown = false;
		}

		protected static function onDeactive(event:Event):void
		{
			keyUpTime.length = 0;
			keyUpTime.length = 256;
			keyDownList.length = 0;
			keyDownList.length = 256;
		}

		protected static function onMiddleMouseDown(event:MouseEvent):void
		{
			isMiddleDown = true;
		}

		protected static function onMiddleMouseUp(event:MouseEvent):void
		{
			isMiddleDown = false;
		}

		protected static function onRightMouseDown(event:MouseEvent):void
		{
			isRightDown = true;
		}

		protected static function onRightMouseUp(event:MouseEvent):void
		{
			isRightDown = false;
		}

		protected static function onMouseUp(event:MouseEvent):void
		{
			isLeftDown = false;
		}

		protected static function onMouseDown(event:MouseEvent):void
		{
			isLeftDown = true;
		}

		/**
		 * UP
		 * @param event
		 *
		 */
		protected static function onkeyUp(event:KeyboardEvent):void
		{
			const now:int = getTimer();

			if (event.ctrlKey)
			{
				keyUpTime[Keyboard.CONTROL] = now;
				keyDownList[Keyboard.CONTROL] = false;
			}

			if (event.shiftKey)
			{
				keyUpTime[Keyboard.SHIFT] = now;
				keyDownList[Keyboard.SHIFT] = false;
			}
			keyUpTime[event.keyCode] = now;
			keyDownList[event.keyCode] = false;
		}

		/**
		 * DOWN
		 * @param event
		 *
		 */
		protected static function onKeyDown(event:KeyboardEvent):void
		{
			const now:int = getTimer();

			// 更新键按下列表
			if (event.ctrlKey)
			{
				if (!keyDownList[Keyboard.CONTROL])
				{
					keyDownIntervals[Keyboard.CONTROL] = now - keyUpTime[Keyboard.CONTROL]
				}
				keyDownList[Keyboard.CONTROL] = true;
				keyDownTime[Keyboard.CONTROL] = now;
			}

			if (event.shiftKey)
			{
				if (!keyDownList[Keyboard.SHIFT])
				{
					keyDownIntervals[Keyboard.SHIFT] = now - keyUpTime[Keyboard.SHIFT]
				}
				keyDownList[Keyboard.SHIFT] = true;
				keyDownTime[Keyboard.SHIFT] = now;
			}

			if (!keyDownList[event.keyCode])
			{
				keyDownIntervals[event.keyCode] = now - keyUpTime[event.keyCode]
			}
			keyDownList[event.keyCode] = true;
			keyDownTime[event.keyCode] = now;

			// 检查组合键
			for (var i:int = 0, n:int = shortcuts.length; i < n; i++)
			{
				if (isDown2(shortcuts[i].keys) && shortcuts[i].isInScope(nativeStage.focus))
				{
					// 调用回调
					shortcuts[i].callback();
					// 避免其他人也收到事件
					//event.preventDefault();
					//event.stopImmediatePropagation();
					// 把当前按下的键主动弹起
					onkeyUp(event);
					// 执行后只生效一个，所以 break 掉
					break;
				}
			}
		}

		/**
		 * 注册了的组合键列表<br>
		 * 手动更改该列表也可以进行快捷键注册和删除操作
		 */
		public static var shortcuts:Vector.<Shortcut> = new Vector.<Shortcut>;

		/**
		 * 注册一个组合键<br>
		 * 尽管一个组合键可以注册多个 callback，但为每次只有一个组合键生效，并且无法保证顺序<br>
		 * <listing>ShortcutUtil.register([ Keyboard.CONTROL, Keyboard.Z ], undo);</listing>
		 *
		 * @param combo 组合键数组，不区分顺序
		 * @param callback 回调方法
		 * @param scopes 设定作用域，当按键触发时，将根据顺序逐个与 stage.focus 比较（== 或 is），然后调用 callback。
		 *
		 */
		public static function register(combo:Array, callback:Function, scopes:Array = null):void
		{
			shortcuts.push(new Shortcut(combo, callback, scopes));
			shortcuts = shortcuts.sort(sortShortcut);
		}

		private static function sortShortcut(a:Shortcut, b:Shortcut):int
		{
			if (a.keys.length < b.keys.length)
			{
				return 1;
			}
			else
				(a.keys.length > b.keys.length)
			{
				return -1;
			}
			return 0;
		}

		/**
		 * 取消注册一个组合键<br>
		 * 内部会跑一个循环逐个检查数组，如有多个相同的组合键则将一起被取消掉
		 * @param combo
		 *
		 */
		public static function unregister(combo:Array):void
		{
			// 检查组合键
			for (var i:int = shortcuts.length - 1; i >= 0; i--)
			{
				if (compare(shortcuts[i].keys, combo))
				{
					delete shortcuts.splice(i, 1);
				}
			}
		}

		/**
		 * 和 register 一样的功能，但是 combo 参数可以是字符串
		 * <listing>ShortcutUtil.register2("CONTROL+Z", function():void
* {
* 	trace("你按了 CONTROL+Z");
* });</listing>
* @param combo 组合键，以 “+” 分割
* @param callback 回调方法
* @param scopes 设定作用域，当按键触发时，将根据顺序逐个与 stage.focus 比较
*
*/
		public static function register2(combo:String, callback:Function, scopes:Array = null):void
		{
			return register(str2array(combo), callback, scopes);
		}

		/**
		 * 和 unregister 一样的功能，但是 combo 可以是字符串
		 * @param combo
		 *
		 */
		public static function unregister2(combo:String):void
		{
			return unregister(str2array(combo));
		}

		/**
		 * 字符串的键码转数组
		 * @param combo
		 * @return
		 *
		 */
		public static function str2array(combo:String):Array
		{
			var result:Array = combo.split("+");

			for (var i:int = 0, n:int = result.length; i < n; i++)
			{
				result[i] = Keyboard[result[i]];
			}
			return result;
		}

		/**
		 * 比较 2 组快捷键是否相同
		 * @param a
		 * @param b
		 * @return
		 *
		 */
		public static function compare(a:Array, b:Array):Boolean
		{
			if (a.length == b.length)
			{
				var isMatch:Boolean = true;

				for (var i:int = 0, n:int = b.length; i < n; i++)
				{
					// 有任意键没有就表示不一样
					if (a.indexOf(b[i]) == -1)
					{
						isMatch = false;
						break;
					}
				}
				return isMatch;
			}
			return false;
		}

		/**
		 * 获得指定键与上次松开的时间间隔
		 * @param keyCode
		 * @return
		 *
		 */
		[Inline]
		public static function getInterval(keyCode:uint):int
		{
			return keyDownIntervals[keyCode];
		}

		/**
		 * 获得指定键上次松开的时间
		 * @param keyCode
		 * @return
		 *
		 */
		[Inline]
		public static function getKeyUpTime(keyCode:uint):int
		{
			return keyUpTime[keyCode];
		}

		/**
		 * 获得指定键上次按下的时间
		 * @param keyCode
		 * @return
		 *
		 */
		[Inline]
		public static function getKeyDownTime(keyCode:uint):int
		{
			return keyDownTime[keyCode];
		}

		/**
		 * 检查指定键是否已按下
		 * @param keys
		 * @return
		 *
		 */
		[Inline]
		public static function isDown(keyCode:uint):Boolean
		{
			return keyDownList[keyCode];
		}

		/**
		 * 检查一组键是否已按下
		 * @param combo
		 * @return
		 *
		 */
		public static function isDown2(combo:Array):Boolean
		{
			for (var i:int = 0, n:int = combo.length; i < n; i++)
			{
				if (!keyDownList[combo[i]])
				{
					return false;
				}
			}
			return true;
		}
	}
}
