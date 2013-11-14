package ageb.modules.avatar.frameInfoClasses
{
	import mx.collections.ArrayList;
	import spark.components.DropDownList;
	import age.data.EmitterType;

	/**
	 * 粒子帧属性面板
	 * @author kk
	 *
	 */
	public class ParticleContent extends VirutalContent
	{

		[SkinPart(required="true")]
		public var emitterType:DropDownList;

		/**
		 * constructor
		 *
		 */
		public function ParticleContent()
		{
			super();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function get skinClass():Class
		{
			return ParticleContentSkin;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			emitterType.dataProvider = new ArrayList(constantsToArray(EmitterType));
		}
	}
}
