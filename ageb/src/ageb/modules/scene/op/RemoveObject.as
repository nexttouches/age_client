package ageb.modules.scene.op
{
	import flash.utils.Dictionary;
	import ageb.modules.ae.IChild;
	import ageb.modules.ae.IParent;
	import ageb.modules.ae.ISelectableInfo;
	import ageb.modules.document.Document;

	/**
	 * 删除对象操作
	 * @author zhanghaocong
	 *
	 */
	public class RemoveObject extends SceneOPBase
	{
		public var objects:Vector.<ISelectableInfo>;

		public var parents:Dictionary;

		public function RemoveObject(doc:Document, objects:Vector.<ISelectableInfo>)
		{
			super(doc);
			this.objects = objects;
		}

		override protected function saveOld():void
		{
			// 记录 parents
			parents = new Dictionary;

			for each (var o:Object in objects)
			{
				parents[o] = o.parent;
			}
		}

		override public function redo():void
		{
			// 删除后这些对象将不被选中
			doc.info.setSelectedObjects(null, this);

			for each (var o:IChild in objects)
			{
				getParent(o).remove(o);
			}
		}

		override public function undo():void
		{
			for each (var o:IChild in objects)
			{
				getParent(o).add(o);
			}
			// 设置选择项到复制前的对象
			doc.info.setSelectedObjects(objects, this);
		}

		final private function getParent(child:IChild):IParent
		{
			return parents[child] as IParent;
		}

		override public function get name():String
		{
			return "删除对象";
		}
	}
}
