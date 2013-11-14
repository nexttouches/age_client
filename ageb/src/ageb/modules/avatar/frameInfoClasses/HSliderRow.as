package ageb.modules.avatar.frameInfoClasses
{
	import mx.binding.utils.BindingUtils;
	import spark.components.HSlider;
	import spark.components.Label;

	/**
	 * 包含一个 HSlider 的表单行
	 * @author zhanghaocong
	 *
	 */
	public class HSliderRow extends ParticleContentFormRow
	{
		/**
		 * constructor
		 *
		 */
		public function HSliderRow()
		{
			super();
		}

		protected var valueLabel:Label;

		protected var slider:HSlider;

		/**
		 * @inheritDoc
		 *
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			slider = new HSlider();
			slider.percentWidth = 100;
			slider.value = _value;
			slider.maximum = max;
			slider.minimum = min;
			slider.stepSize = step;
			addElement(slider);
			valueLabel = new Label();
			valueLabel.width = 40;
			valueLabel.setStyle("textAlign", "right");
			BindingUtils.bindProperty(valueLabel, "text", slider, "value");
			BindingUtils.bindProperty(this, "min", slider, "minimum");
			BindingUtils.bindProperty(this, "max", slider, "maximum");
			BindingUtils.bindProperty(this, "step", slider, "stepSize");
			addElement(valueLabel);
		}

		private var _value:Number = 0;

		/**
		 * 设置或获取当前表单的值
		 * @return
		 *
		 */
		public function get value():Number
		{
			return _value;
		}

		public function set value(value:Number):void
		{
			_value = value;

			if (slider)
			{
				slider.value = value;
			}
		}

		/**
		 * 设置或获取 HSlider 允许输入的最小值，默认为 0
		 */
		[Bindable]
		public var min:Number = 0;

		/**
		 * 设置或获取 HSlider 允许输入的最大值，默认为 10
		 */
		[Bindable]
		public var max:Number = 10;

		/**
		 * 设置或获取 HSlider 的步进，默认值是 1
		 */
		[Bindable]
		public var step:Number = 1;

		/**
		 * @inheritDoc
		 *
		 */
		override public function set id(value:String):void
		{
			super.id = value;
			field = value;
		}
	}
}
