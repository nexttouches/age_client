package ageb.modules.scene.op
{
	import flash.utils.Dictionary;
	import ageb.modules.ae.ISelectableInfo;
	import ageb.modules.ae.ObjectInfoEditable;
	import ageb.modules.document.Document;

	public class ChangeObjectProperties extends SceneOPBase
	{
		private var oldPropsList:Dictionary;

		private var props:Object;

		private var selectedObjects:Vector.<ISelectableInfo>;

		public function ChangeObjectProperties(doc:Document, selectedObjects:Vector.<ISelectableInfo>, props:Object)
		{
			super(doc);
			this.selectedObjects = selectedObjects;
			this.props = props;
		}

		override public function redo():void
		{
			for each (var o:ISelectableInfo in selectedObjects)
			{
				for (var key:String in props)
				{
					o[key] = props[key];
				}
				ObjectInfoEditable(o).onPropertiesChange.dispatch(this);
			}
		}

		override protected function saveOld():void
		{
			oldPropsList = new Dictionary();

			for each (var o:ISelectableInfo in selectedObjects)
			{
				var oldProp:Object = {};
				oldPropsList[o] = oldProp;

				for (var key:String in props)
				{
					oldProp[key] = o[key];
				}
			}
		}

		override public function undo():void
		{
			for each (var o:ISelectableInfo in selectedObjects)
			{
				var oldProps:Object = oldPropsList[o];

				for (var key:String in oldProps)
				{
					o[key] = oldProps[key];
				}
				ObjectInfoEditable(o).onPropertiesChange.dispatch(this);
			}
		}

		override public function get name():String
		{
			return "修改属性";
		}
	}
}
