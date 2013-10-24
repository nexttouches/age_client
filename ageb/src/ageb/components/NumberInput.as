package ageb.components
{
	import spark.components.NumericStepper;

	/**
	 * 数字输入器，可以输入小数<br>
	 * 如果输入 "<code>---</code>" （不含引号），则识别为 NaN<br>
	 * 同样的，如果设置的 value 会 <code>NaN</code>，则显示为 "<code>---</code>"<br>
	 * 此外，该组件默认的 minimum 和 maximum 是 -10000~10000
	 * 如果要输入整数，请使用 <code>IntInput</code>
	 * @see IntInput
	 * @author zhanghaocong
	 *
	 */
	public class NumberInput extends NumericStepper
	{
		/**
		 * 创建一个新的 NumberInput
		 *
		 */
		public function NumberInput()
		{
			super();
			const RANGE:Number = 10000;
			minimum = -RANGE;
			maximum = RANGE;
			valueFormatFunction = toText;
			valueParseFunction = parseText;
		}

		/**
		 * @private
		 * @param s
		 * @return
		 *
		 */
		private function parseText(s:String):Number
		{
			if (s == "---")
			{
				return NaN;
			}
			return Number(s);
		}

		/**
		 * @private
		 * @param s
		 * @return
		 *
		 */
		private function toText(n:Number):String
		{
			if (isNaN(n))
			{
				return "---";
			}
			return n.toString();
		}
	}
}
