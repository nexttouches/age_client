package nt.ui.components
{
	import flash.display.DisplayObject;
	import flash.events.TextEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	import nt.lang.L;
	import nt.ui.configs.DefaultStyle;
	import nt.ui.core.SkinnableComponent;

	[Event(name="textInput", type="flash.events.TextEvent")]
	/**
	 * InputText 定义了输入文本
	 * @author zhanghaocong
	 *
	 */
	public class InputText extends SkinnableComponent
	{

		[Skin]
		public var bg:Scale9Image;

		[Skin]
		public var tf:TextField;

		public function InputText(skin:* = null)
		{
			super(skin || DefaultStyle.InputTextSkin);
		}

		override public function setSkin(value:DisplayObject):void
		{
			super.setSkin(value);

			if (tf.type != TextFieldType.INPUT)
			{
				throw new Error("文本框必须是输入类型");
			}
			tf.text = "";
		}

		public function get restrict():String
		{
			return tf.restrict;
		}

		public function set restrict(value:String):void
		{
			tf.restrict = value;
		}

		override public function set height(value:Number):void
		{
			tf.height = value;
			bg.height = value;
			super.height = value;
		}

		override public function set width(value:Number):void
		{
			tf.width = value;
			bg.width = value;
			super.width = value;
		}

		public function set stringValue(value:String):void
		{
			value = L.localize(value);
			tf.text = value;
		}

		public function get stringValue():String
		{
			return tf.text;
		}

		public function get arrayValue():Array
		{
			return tf.text.split(",");
		}

		public function set arrayValue(value:Array):void
		{
			tf.text = value.join(",");
		}

		public function set intValue(value:int):void
		{
			tf.text = String(value);
		}

		public function get intValue():int
		{
			return int(tf.text);
		}

		public function set uintValue(value:uint):void
		{
			tf.text = String(value);
		}

		public function get uintValue():uint
		{
			return uint(tf.text);
		}

		public function set numberValue(value:Number):void
		{
			tf.text = String(value);
		}

		public function get numberValue():Number
		{
			return Number(tf.text);
		}

		private var _isEditable:Boolean;

		public function get isEditable():Boolean
		{
			return _isEditable;
		}

		public function set isEditable(value:Boolean):void
		{
			_isEditable = value;

			if (value)
			{
				tf.removeEventListener(TextEvent.TEXT_INPUT, preventInput);
				tf.filters = null;
			}
			else
			{
				tf.addEventListener(TextEvent.TEXT_INPUT, preventInput);
				tf.filters = [ new DropShadowFilter(1, 45, tf.textColor, 1, 1, 1, 2.0, BitmapFilterQuality.LOW, false, true)];
			}
		}

		protected function preventInput(event:TextEvent):void
		{
			event.preventDefault();
			event.stopImmediatePropagation();
			event.stopPropagation();
		}
	}
}
