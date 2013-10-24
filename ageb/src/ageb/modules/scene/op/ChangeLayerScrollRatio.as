package ageb.modules.scene.op
{
	import ageb.modules.ae.LayerInfoEditable;
	import ageb.modules.document.Document;

	/**
	 * 修改图层 scrollRatio 操作
	 * @author zhanghaocong
	 *
	 */
	public class ChangeLayerScrollRatio extends SceneOPBase
	{
		public var layerIndex:int;

		public var scrollRatio:Number;

		public var oldScrollRatio:Number;

		public function ChangeLayerScrollRatio(doc:Document, layerIndex:int, scrollRatio:Number)
		{
			super(doc);
			this.layerIndex = layerIndex;
			this.scrollRatio = scrollRatio;
		}

		override public function redo():void
		{
			LayerInfoEditable(doc.info.layers[layerIndex]).setScrollRatio(scrollRatio);
		}

		override protected function saveOld():void
		{
			oldScrollRatio = doc.info.layers[layerIndex].scrollRatio;
		}

		override public function undo():void
		{
			LayerInfoEditable(doc.info.layers[layerIndex]).setScrollRatio(oldScrollRatio);
		}

		override public function get name():String
		{
			return format("修改卷动速率 ({scrollRatio})", this);
		}
	}
}
