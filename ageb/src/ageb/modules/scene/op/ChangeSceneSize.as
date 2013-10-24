package ageb.modules.scene.op
{
	import ageb.modules.document.Document;

	/**
	 * ChangeSceneSize 是修改场景大小操作
	 * @author zhanghaocong
	 *
	 */
	public class ChangeSceneSize extends SceneOPBase
	{
		public var width:Number;

		public var height:Number;

		public var oldWidth:Number;

		public var oldHeight:Number;

		/**
		 * 创建一个新的 ChangeSceneSize
		 * @param doc
		 * @param width
		 * @param height
		 *
		 */
		public function ChangeSceneSize(doc:Document, width:Number, height:Number)
		{
			super(doc);
			this.width = width;
			this.height = height;
		}

		override protected function saveOld():void
		{
			oldWidth = doc.info.width;
			oldHeight = doc.info.height;
		}

		override public function redo():void
		{
			doc.info.setSize(width, height);
		}

		override public function undo():void
		{
			doc.info.setSize(oldWidth, oldHeight);
		}

		override public function get name():String
		{
			return format("修改场景大小 ({width}×{height})", this);
		}
	}
}
