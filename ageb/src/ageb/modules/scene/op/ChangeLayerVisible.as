package ageb.modules.scene.op
{
	import ageb.modules.document.Document;

	public class ChangeLayerVisible extends SceneOPBase
	{
		public var layerIndex:int;

		public var isVisible:Boolean;

		public var oldIsVisible:Boolean;

		public function ChangeLayerVisible(doc:Document, layerIndex:int, isVisible:Boolean)
		{
			super(doc);
			this.layerIndex = layerIndex;
			this.isVisible = isVisible;
		}

		override public function redo():void
		{
			doc.info.layers[layerIndex].isVisible = isVisible;
		}

		override protected function saveOld():void
		{
			oldIsVisible = doc.info.layers[layerIndex].isVisible;
		}

		override public function undo():void
		{
			doc.info.layers[layerIndex].isVisible = oldIsVisible;
		}

		override public function get name():String
		{
			return format("修改可见度 ({isVisible})", this);
		}
	}
}
