package nt.lang
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;

	/**
	 * _L 表示语言包，通过调用 setEntries 可以更换语言包<br/>
	 * @author zhanghaocong
	 *
	 */
	dynamic internal class _L extends Proxy
	{
		private var _entries:Object;

		private var _locked:Boolean;

		public function get locked():Boolean
		{
			return _locked;
		}

		public function setEntries(value:Object):void
		{
			if (!_locked)
			{
				_entries = value;
				_locked = true;
			}
			else
			{
				throw new Error("当前语言包已锁定");
			}
		}

		final public function localize(s:String):String
		{
			// 同时含有 {}视作可以进行语言包替换，否则直接输出
			if (s && s.indexOf("{") > -1 && s.indexOf("}") > -1)
			{
				return format(s, this);
			}

			if (!(s is String))
			{
				s = "";
			}
			return s;
		}

		public function _L()
		{
			super();
			formatalias.register("L", this);
		}

		flash_proxy override function getProperty(name:*):*
		{
			if (!_entries)
			{
				_entries = {};
			}

			if (!_entries[name])
			{
				_entries[name] = name + "==null";
			}
			return _entries[name];
		}

		flash_proxy override function setProperty(name:*, value:*):void
		{
			throw new IllegalOperationError("L 是只读的");
		}

		override flash_proxy function hasProperty(name:*):Boolean
		{
			return name in _entries;
		}
	}
}
