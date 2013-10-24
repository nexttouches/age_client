package ageb.modules.document
{
	import spark.components.Group;
	import spark.components.Label;
	import spark.layouts.HorizontalAlign;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalAlign;

	public class FormRow extends Group
	{
		private var labelField:Label;

		public function FormRow()
		{
			super();
			var l:HorizontalLayout = new HorizontalLayout();
			l.verticalAlign = VerticalAlign.MIDDLE;
			l.horizontalAlign = HorizontalAlign.LEFT;
			l.gap = 2;
			layout = l;
			percentWidth = 100;
		}

		override protected function createChildren():void
		{
			super.createChildren();
			labelField = new Label();
			labelField.width = _labelWidth;
			labelField.text = _label;
			labelField.setStyle("textAlign", "right");
			labelField.setStyle("paddingRight", 3);
			addElementAt(labelField, 0);
		}

		private var _label:String;

		public function get label():String
		{
			return _label;
		}

		public function set label(value:String):void
		{
			_label = value;

			if (labelField)
			{
				labelField.text = value;
			}
		}

		private var _labelWidth:Number = 30;

		public function get labelWidth():Number
		{
			return _labelWidth;
		}

		public function set labelWidth(value:Number):void
		{
			_labelWidth = value;

			if (labelField)
			{
				labelField.width = value;
			}
		}
	}
}
