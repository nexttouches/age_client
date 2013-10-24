package ageb.modules.scene.op
{
	import ageb.modules.ae.LayerInfoEditable;
	import ageb.modules.ae.ObjectInfoEditable;
	import ageb.modules.document.Document;

	public class AddObject extends SceneOPBase
	{
		public var x:Number;

		public var z:Number;

		public var parent:LayerInfoEditable;

		public var info:ObjectInfoEditable;

		public function AddObject(doc:Document, parent:LayerInfoEditable, x:Number, z:Number)
		{
			super(doc);
			this.x = x;
			this.z = z;
			this.parent = parent;
		}

		override public function get name():String
		{
			return format("添加对象于 (图层 {0}, {1}, {2})", parent.index, x, z);
		}

		override public function redo():void
		{
			parent.add(info);
		}

		override protected function saveOld():void
		{
			info = new ObjectInfoEditable();
			info.position.setTo(x, 0, z);
		}

		override public function undo():void
		{
			parent.remove(info);
		}
	}
}
