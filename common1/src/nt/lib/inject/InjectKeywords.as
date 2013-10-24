package nt.lib.inject
{
	public class InjectKeywords
	{
		public function InjectKeywords()
		{
		}
		
		/**
		 * Metadata 专用标签
		 */
		public static const Inject:String = "Inject";
		/**
		 * 为属性设置一个默认值，可以是具体值或 "auto"<br/>
		 * 设置为 "auto" 时将会自动识别属性的类型并创建对应的对象
		 * <listing>
		 * [Inject(defaultValue="Helloworld")]
		 * public var helloworld:String; // helloworld 将会自动赋值 “Helloworld”
		 * 
		 * [Inject(defaultValue="auto")]
		 * public var background:Sprite; // 一个新的 Sprite 将会被自动创建并赋给 background
		 * </listing>
		 * 
		 */
		public static const DefaultValue:String = "defaultValue";
		/**
		 * 设置一个事件名称，属性变化后将自动触发事件（必须实现 IInjectable & 调用 updateFrom 或 setValue 时才会正确触发）
		 */
		public static const Event:String = "event";
		/**
		 * 设置一个别名，用于自动关联远程无类型对象和本地对象的属性
		 */
		public static const Alias:String = "alias";
		
		/**
		 * 设置该对象的默认属性，通常是对象的 ID,CollectionInjectable.fill 时会自动赋值
		 */
		public static const DefaultProperty:String = "defaultProperty";
		
		/**
		 * @private
		 */
		public static const Auto:String = "auto";
	}
}