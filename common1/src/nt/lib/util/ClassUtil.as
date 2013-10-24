package nt.lib.util
{
	import flash.net.registerClassAlias;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import nt.lib.reflect.Metadata;
	import nt.lib.reflect.Type;

	/**
	 * 类相关辅助工具
	 * @author zhanghaocong
	 *
	 */
	public class ClassUtil
	{
		/**
		 * 使用 registerClassAlias 注册一个类<br/>
		 * 以下例子实现了 byteArray 中数据是 A，但可以当作 B 来反序列化的情况
 * <listing>
* class A
* {
* 	public var a:int;
* }
* class B extends A
* {
* 	public var b:int;
* }
* ClassUtil.register(A, B);
* var b:B = byteArray.readObject(); // byteArray 中实际内容是 A，也就是只有 a:int 的属性
* </listing>
* @param alias amf 中注册的类名
* @param target 本次 readObject 使用的类
*
   */
		public static function register(alias:*, target:Class = null):void
		{
			if (alias is Factory)
			{
				alias = alias.factory;
			}
			if (!target)
			{
				target = alias;
			}
			switch (alias)
			{
				case null:
				case undefined:
				{
					return;
				}
			}
			registerClassAlias(getSerializeAlias(alias), target);
			// traceex("ClassUtil/register({0}, {1})", arguments);
		}

		/**
		 * 一口气注册多个类，但不能指定目标类
		 * @param aliases
		 *
		 */
		public static function registerList(... aliases):void
		{
			for each (var alias:* in aliases)
			{
				register(alias);
			}
		}

		/**
		 * @private
		 */
		private static var classNameCache:Dictionary = new Dictionary();

		/**
		 * 获得类名
		 * @param factory
		 * @return
		 *
		 */
		public static function getClassName(factory:Class):String
		{
			if (!classNameCache[factory])
			{
				var fullName:String = getQualifiedClassName(factory);
				classNameCache[factory] = fullName.substring(fullName.lastIndexOf("::") + 2, fullName.length);
			}
			return classNameCache[factory];
		}

		/**
		 * 获得序列化时使用的别名<br/>
		 * 要自定义别名，请使用 Serializable 元标签，否则将使用类的 QualifiedClassName<br/>
		 * 下例展示了如何使用 Serializable 元标签
* <listing>
* [Serializable(alias="Atom")]
* class AtomClass
* {
* }
* </listing>
 * @param factory
	   * @return
			*
		 */
		public static function getSerializeAlias(factory:Class):String
		{
			var metadata:Metadata = Type.of(factory).metadatas["Serializable"];
			if (metadata)
			{
				return metadata.getArg("alias");
			}
			else
			{
				return getQualifiedClassName(factory);
			}
		}
	}
}
