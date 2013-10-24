package ageb.modules.scene.op
{
	import ageb.modules.ae.BGInfoEditable;
	import ageb.modules.ae.ISelectableInfo;
	import ageb.modules.ae.LayerInfoEditable;
	import ageb.modules.document.Document;

	public class AddBG extends SceneOPBase
	{
		public var textures:Vector.<String>;

		public var parent:LayerInfoEditable;

		public var x:Number;

		public var y:Number;

		public var infos:Vector.<BGInfoEditable>;

		public var isAutoPosition:Boolean;

		public var oldSelections:Vector.<ISelectableInfo>;

		public function AddBG(doc:Document, textures:Vector.<String>, parent:LayerInfoEditable, x:Number = NaN, y:Number = NaN, isAutoPosition:Boolean = false)
		{
			super(doc);
			this.textures = textures;
			this.parent = parent;
			this.x = x;
			this.y = y;
			this.isAutoPosition = isAutoPosition;
		}

		override public function redo():void
		{
			for each (var info:BGInfoEditable in infos)
			{
				parent.add(info);
			}
			// 主动选中新增的对象
			doc.info.setSelectedObjects(infos);
		}

		override protected function saveOld():void
		{
			oldSelections = doc.info.selectedObjects.concat();
			infos = new Vector.<BGInfoEditable>();

			for each (var texture:String in textures)
			{
				var info:BGInfoEditable = new BGInfoEditable();
				info.texture = texture;

				if (isAutoPosition)
				{
					var position:Array = info.textureName.split("_");
					info.x = position[0] * 512;
					info.y = parent.parent.uiToY(position[1] * 512);
				}
				else
				{
					info.x = x;
					info.y = y;
				}
				infos.push(info);
			}
		}

		override public function undo():void
		{
			doc.info.setSelectedObjects(oldSelections);

			for each (var info:BGInfoEditable in infos)
			{
				parent.remove(info);
			}
		}

		override public function get name():String
		{
			return format("添加背景于 (图层 {0}, {1}, {2})", parent.index, x, y);
		}
	}
}
