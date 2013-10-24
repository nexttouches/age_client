package nt.lib.util
{
	import avmplus.getQualifiedClassName;

	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	import flash.utils.getDefinitionByName;

	/**
	 * 工厂类让一个类可以被序列化
	 * @author zhanghaocong
	 *
	 */
	[Serializable(alias = "Factory")]
	public class Factory implements IExternalizable
	{
		/**
		 * 类的完整名字
		 */
		public var fullName:String;

		private var _factory:Class;

		/**
		 * 设置和获取对应的 factory
		 * @return
		 *
		 */
		public function get factory():Class
		{
			if (!_factory && fullName)
			{
				_factory = getDefinitionByName(fullName) as Class;
			}
			return _factory;
		}

		public function set factory(value:Class):void
		{
			_factory = value;
			if (value)
			{
				fullName = getQualifiedClassName(value);
			}
		}

		/**
		 * 创建一个新的 Factory
		 * @param classOrFullName Class 或 String
		 *
		 */
		public function Factory(classOrFullName:* = null)
		{
			if (classOrFullName)
			{
				if (classOrFullName is Class)
				{
					factory = classOrFullName as Class;
				}
				else if (classOrFullName is String)
				{
					fullName = classOrFullName as String;
				}
				else
				{
					throw new ArgumentError("参数必须是 Class 或 String");
				}
			}
		}

		/**
		 * 得到当前工厂的实例
		 * @return
		 *
		 */
		public function createInstance():*
		{
			return new factory();
		}

		/**
		 * @private
		 * @param output
		 *
		 */
		public function writeExternal(output:IDataOutput):void
		{
			ClassUtil.register(factory);
			output.writeUTF(fullName);
		}

		/**
		 * @private
		 * @param input
		 *
		 */
		public function readExternal(input:IDataInput):void
		{
			ClassUtil.register(factory);
			fullName = input.readUTF();
		}

		public function toString():String
		{
			return format("[object Factory(fullName={fullName})]", this);
		}
	}
}
