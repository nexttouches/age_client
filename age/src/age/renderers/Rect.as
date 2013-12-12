package age.renderers
{

	/**
	 * 矩形
	 * @author zhanghaocong
	 *
	 */
	public class Rect extends Quad3D
	{
		/**
		 * constructor
		 *
		 */
		public function Rect(width:Number = 1, height:Number = 1, color:uint = 0xffffff, premultipliedAlpha:Boolean = true)
		{
			super(width, height, color, premultipliedAlpha);
		}

		/**
		 * 重设 Rect 到指定大小（使用 UI 坐标系）
		 * @param width
		 * @param height
		 *
		 */
		public function setTo(width:Number, height:Number):void
		{
			mVertexData.setPosition(0, 0.0, 0.0);
			mVertexData.setPosition(1, width, 0.0);
			mVertexData.setPosition(2, 0.0, height);
			mVertexData.setPosition(3, width, height);
			onVertexDataChanged();
		}
	}
}
