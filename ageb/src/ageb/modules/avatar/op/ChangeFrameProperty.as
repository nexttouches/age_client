package ageb.modules.avatar.op
{
	import flash.utils.Dictionary;
	import ageb.modules.ae.FrameInfoEditable;
	import ageb.modules.document.Document;

	/**
	 * 只是简单修改帧的某一个属性时，可以继承该类
	 * @author zhanghaocong
	 *
	 */
	public class ChangeFrameProperty extends FrameOpBase
	{
		/**
		 * 使用 = （赋值） 形式修改时的属性
		 */
		public var property:String;

		/**
		 * 使用方法调用修改时使用的名字
		 */
		public var setter:String;

		/**
		 * 新值
		 */
		public var value:*;

		/**
		 * 旧值（以 FrameInfoEditable 为 key 储存）
		 */
		public var oldValues:Dictionary;

		/**
		 * 创建一个新的 ChangeFrameProperty
		 * @param doc 目标文档
		 * @param frames 要修改的帧
		 * @param key 要修改的属性
		 * @param value 要修改的值
		 *
		 */
		public function ChangeFrameProperty(doc:Document, frames:Vector.<FrameInfoEditable>, value:*, key:String)
		{
			super(doc, frames);
			this.property = key;
			this.setter = "set" + property.charAt(0).toUpperCase() + property.substring(1);
			this.value = value;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function redo():void
		{
			for (var i:int = 0, n:int = frames.length; i < n; i++)
			{
				const info:FrameInfoEditable = frames[i];
				doChange(info, value);
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function saveOld():void
		{
			// 记录所有旧值到 oldValues 中
			oldValues = new Dictionary;

			for (var i:int = 0, n:int = frames.length; i < n; i++)
			{
				const info:FrameInfoEditable = frames[i];
				oldValues[info] = info[property];
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function undo():void
		{
			for (var i:int = 0, n:int = frames.length; i < n; i++)
			{
				const info:FrameInfoEditable = frames[i];
				doChange(info, oldValues[info]);
			}
		}

		/**
		 * 修改帧对象到指定值
		 * @param info
		 * @param value
		 *
		 */
		protected function doChange(info:FrameInfoEditable, newValue:*):void
		{
			if (info.hasOwnProperty(setter) && info[setter] is Function)
			{
				info[setter](newValue);
			}
			else
			{
				info[property] = newValue;
			}
		}

		override public function get name():String
		{
			return format("修改 {property} 为 {value}", this);
		}
	}
}
