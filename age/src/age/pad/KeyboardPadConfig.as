package age.pad
{
	import flash.ui.Keyboard;

	/**
	 * KeybardPad 的配置类
	 * @author zhanghaocong
	 *
	 */
	public class KeyboardPadConfig
	{
		// 移动相关
		/**
		 * 向左移动 (A)
		 */
		public var left:uint = Keyboard.A

		/**
		 * 向右移动 (D)
		 */
		public var right:uint = Keyboard.D;

		/**
		 * 向远（上）移动（W）
		 */
		public var back:uint = Keyboard.W;

		/**
		 * 向近（下）移动（S）
		 */
		public var front:uint = Keyboard.S;

		// 动作相关
		/**
		 * 跳跃（K）
		 */
		public var jump:uint = Keyboard.K;

		/**
		 * 普通攻击（J）
		 */
		public var attack:uint = Keyboard.J;

		/**
		 * 后跳
		 */
		public var backstep:uint = Keyboard.L;

		/**
		 * 连续按 2 次左右键进入冲刺状态时的超时（毫秒）
		 */
		public var runTimeout:uint = 200;

		/**
		 * constructor
		 *
		 */
		public function KeyboardPadConfig(raw:Object = null)
		{
			if (raw)
			{
				fromJSON(raw);
			}
		}

		/**
		 * 重设到默认值
		 *
		 */
		public function reset():void
		{
			fromJSON(JSON.stringify(new KeyboardPadConfig));
		}

		/**
		 * 从 JSON 反序列化
		 * @param s
		 *
		 */
		public function fromJSON(s:*):void
		{
			for (var key:String in s)
			{
				if (this.hasOwnProperty(key))
				{
					this[key] = s;
				}
			}
		}

		/**
		 * 克隆一份新的
		 *
		 */
		public function clone():KeyboardPadConfig
		{
			return new KeyboardPadConfig(JSON.parse(JSON.stringify(this)));
		}
	}
}
