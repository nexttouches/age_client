package ageb.modules.avatar.frameInfoClasses
{
	import spark.layouts.HorizontalLayout;
	import age.data.Particle3DConfig;
	import ageb.modules.document.FormRow;

	/**
	 * 粒子图层属性面板里使用的 FormRow
	 * @author zhanghaocong
	 *
	 */
	public class ParticleContentFormRow extends FormRow
	{
		/**
		 * constructor
		 *
		 */
		public function ParticleContentFormRow()
		{
			super();
			percentWidth = 100;
			isLabelAutoSize = true;
		}

		private var _field:String;

		/**
		 * 设置或获取当前设置的 ParticleConfig 字段
		 * @return
		 *
		 */
		public function get field():String
		{
			return _field;
		}

		public function set field(value:String):void
		{
			_field = value;
			label = Particle3DConfig.T(value);
		}
	}
}
