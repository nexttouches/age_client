package ageb.modules.avatar.frameInfoClasses
{

	/**
	 * 粒子帧属性面板
	 * @author kk
	 *
	 */
	public class ParticleContent extends VirutalContent
	{
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
	}
}
