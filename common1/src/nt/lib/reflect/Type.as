package nt.lib.reflect
{
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import avmplus.getQualifiedClassName;
	import avmplus.getQualifiedSuperclassName;
	import nt.lib.reflect.returntypes.Void;

	final public class Type extends Description
	{
		/**
		 * 当前描述的类
		 */
		public var factory:Class;

		/**
		 * describeType 得到的 XML
		 */
		public var typeInfo:XML;

		private var _variables:Object;

		/**
		 * 所有变量
		 */
		public function get variables():Object
		{
			if (!_variables)
			{
				_variables = {};
				parseVariables();
			}
			return _variables;
		}

		private var _accessors:Object;

		/**
		 * 所有 getter 和 setter
		 */
		public function get accessors():Object
		{
			if (!_accessors)
			{
				_accessors = {};
				parseAccessors();
			}
			return _accessors;
		}

		private var _properties:Object;

		/**
		 * 所有 variables 和 accessor
		 */
		public function get properties():Object
		{
			if (!_properties)
			{
				_properties = {};
				var list:Object, name:String;
				list = variables;

				for (name in list)
				{
					_properties[name] = list[name];
				}
				list = accessors;

				for (name in list)
				{
					_properties[name] = list[name];
				}
			}
			return _properties;
		}

		private var _writableProperties:Object;

		/**
		 * 所有变量和 setter
		 */
		public function get writableProperties():Object
		{
			if (!_writableProperties)
			{
				_writableProperties = {};
				var list:Object, name:String;
				list = variables;

				for (name in list)
				{
					_writableProperties[name] = list[name];
				}
				list = accessors;

				for (name in list)
				{
					if (Accessor(list[name]).access != "readonly")
					{
						_writableProperties[name] = list[name];
					}
				}
			}
			return _writableProperties;
		}

		private var _methods:Object;

		/**
		 * 所有方法
		 */
		public function get methods():Object
		{
			if (!_methods)
			{
				_methods = {};
				parseMethods();
			}
			return _methods;
		}

		public function Type(factory:Class)
		{
			this.factory = factory;
			parse()
		}

		private function parse():void
		{
			typeInfo = describeType(factory);
			parseMetadata(typeInfo.factory.metadata);
		}

		/**
		 * 获得指定的变量，为了性能考虑，循环中请直接使用 variables[name]
		 * @param name
		 * @return
		 *
		 */
		public function getVariable(name:String):Variable
		{
			return variables[name];
		}

		/**
		 * 获得指定的 Property
		 * @param name
		 * @return
		 *
		 */
		public function getProperty(name:String):Property
		{
			return properties[name];
		}

		private function parseVariables():void
		{
			var list:XMLList = typeInfo.factory.variable;

			for each (var node:XML in list)
			{
				var type:String = node.@type;
				var v:Variable = new Variable(node.@name, type != "*" ? getDefinitionByName(type) as Class : null, node.@uri);
				v.parseMetadata(node.metadata);
				_variables[v.name] = v;
			}
		}

		private function parseAccessors():void
		{
			var list:XMLList = typeInfo.factory.accessor;
			var type:Class;

			for each (var node:XML in list)
			{
				switch (String(node.@type))
				{
					case "void":
					case "*":
					{
						break;
					}
					default:
					{
						type = getDefinitionByName(node.@type) as Class;
						break;
					}
				}
				var a:Accessor = new Accessor(node.@name, type, node.@access, node.@uri);
				a.parseMetadata(node.metadata);
				_accessors[a.name] = a;
			}
		}

		private function parseMethods():void
		{
			var list:XMLList = typeInfo.factory.method;
			var returnType:Class;

			for each (var node:XML in list)
			{
				switch (String(node.@returnType))
				{
					case "void":
					{
						returnType = Void;
						break;
					}
					case "*":
					{
						returnType = Object;
						break;
					}
					default:
					{
						returnType = getDefinitionByName(node.@returnType) as Class;
						break;
					}
				}
				var m:Method = new Method(node.@name, returnType, node.@uri);
				m.parseMetadata(node.metadata);
				_methods[m.name] = m;
			}
		}

		/**
		 * 类型的完整名字
		 * @return
		 *
		 */
		public function get fullname():String
		{
			return typeInfo.@name;
		}

		private var _shortname:String;

		/**
		 * 短名字
		 * @return
		 *
		 */
		public function get shortname():String
		{
			if (!_shortname)
			{
				var name:String = fullname;
				_shortname = name.substr(name.lastIndexOf(":") + 1);
			}
			return _shortname;
		}

		/**
		 * 为当前 Type 创建新实例
		 * @return
		 *
		 */
		public function newInstance(... args):*
		{
			return factory.constructor.apply(null, args);
		}

		private var implementsInterfaces:Dictionary;

		/**
		 * 检查当前类型是否已实现指定接口
		 * @param factory
		 * @return
		 *
		 */
		public function isImplementsInterface(factory:Class):Boolean
		{
			if (!implementsInterfaces)
			{
				implementsInterfaces = new Dictionary(true);
			}

			if (!(factory in implementsInterfaces))
			{
				var fullname:String = getQualifiedClassName(factory);
				implementsInterfaces[factory] = typeInfo..implementsInterface.(@type == fullname).length() > 0;
			}
			return implementsInterfaces[factory];
		}

		private var extendsClasses:Dictionary;

		/**
		 * 检查当前类型是否是继承指定类型
		 * @param factory
		 * @return
		 *
		 */
		public function isExtendsClass(factory:Class):Boolean
		{
			if (!extendsClasses)
			{
				extendsClasses = new Dictionary(true);
			}

			if (!(factory in extendsClasses))
			{
				var fullname:String = getQualifiedClassName(factory);
				extendsClasses[factory] = typeInfo..extendsClass.(@type == fullname).length() > 0;
			}
			return extendsClasses[factory]; // TODO 可改用 in
		}

		/**
		 * 获得父类 Type
		 * @return
		 *
		 */
		public function get superType():Type
		{
			return Type.of(superClass);
		}

		/**
		 * 获得父类 Class
		 * @return
		 *
		 */
		public function get superClass():Class
		{
			return getDefinitionByName(getQualifiedSuperclassName(factory)) as Class;
		}

		/**
		 * 转换 source 的所有可写属性到指定的对象
		 * @param source 指定对象
		 * @param excludes 要排除的字段
		 * @param target 可选，目标对象
		 * @return 转换了的对象
		 *
		 */
		public function toObject(source:Object, excludes:Array = null, target:Object = null):Object
		{
			if (!target)
			{
				target = {};
			}

			for (var p:String in writableProperties)
			{
				if (excludes && excludes.indexOf(p) > -1)
				{
					continue;
				}
				target[p] = source[p];
			}
			return target;
		}

		private static var typeCache:Dictionary = new Dictionary();

		/**
		 * 创建一个新的 Type
		 * @param object
		 * @return
		 *
		 */
		public static function of(object:*):Type
		{
			if (object === null || object === undefined || object === false || object === true)
			{
				throw new Error("不能是 null, undefined, Boolean");
			}
			else
			{
				var factory:Class;

				if (object is Class)
				{
					factory = object;
				}
				else
				{
					factory = object.constructor;
				}
			}
			return typeCache[factory] ||= new Type(factory);
		}
	}
}
