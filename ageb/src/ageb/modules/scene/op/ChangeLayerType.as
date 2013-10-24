package ageb.modules.scene.op
{
	import ageb.modules.document.Document;

	/**
	 * 修改图层 scrollRatio 操作
	 * @author zhanghaocong
	 *
	 */
	public class ChangeLayerType extends SceneOPBase
	{
		public var layerIndex:int;

		public var type:int;

		public var oldType:int;

		public function ChangeLayerType(doc:Document, layerIndex:int, type:int)
		{
			super(doc);
			this.layerIndex = layerIndex;
			this.type = type;
		}

		override public function redo():void
		{
			doc.info.layers[layerIndex].type = type;
		}

		override protected function saveOld():void
		{
			oldType = doc.info.layers[layerIndex].type;
		}

		override public function undo():void
		{
			doc.info.layers[layerIndex].type = oldType;
		}

		override public function get name():String
		{
			return format("修改图层类型 ({type})", this);
		}
	}
}
