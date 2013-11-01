package ageb.modules.scene.op
{
	import flash.filesystem.File;
	import ageb.modules.ae.BGInfoEditable;
	import ageb.modules.ae.ISelectableInfo;
	import ageb.modules.ae.LayerInfoEditable;
	import ageb.modules.document.Document;

	/**
	 * 添加一个背景图的操作
	 * @author zhanghaocong
	 *
	 */
	public class AddBG extends SceneOPBase
	{
		/**
		 * 目标图层
		 */
		public var parent:LayerInfoEditable;

		/**
		 * 目标坐标 x
		 */
		public var x:Number;

		/**
		 * 目标坐标 y
		 */
		public var y:Number;

		/**
		 * 本次添加的 BGInfo
		 */
		public var infos:Vector.<BGInfoEditable>;

		/**
		 * 操作执行前的 OP
		 */
		public var oldSelections:Vector.<ISelectableInfo>;

		/**
		 * 贴图文件
		 */
		public var f:File;

		/**
		 * 添加一个背景图
		 * @param doc
		 * @param textures
		 * @param parent
		 * @param x
		 * @param y
		 * @param isAutoPosition
		 *
		 */
		public function AddBG(doc:Document, f:File, parent:LayerInfoEditable, x:Number = NaN, y:Number = NaN)
		{
			super(doc);
			this.f = f;
			this.parent = parent;
			this.x = x;
			this.y = y;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function redo():void
		{
			for each (var info:BGInfoEditable in infos)
			{
				parent.add(info);
			}
			// 主动选中新增的对象
			doc.info.setSelectedObjects(infos);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function saveOld():void
		{
			oldSelections = doc.info.selectedObjects.concat();
			infos = new Vector.<BGInfoEditable>();
		/*	for each (var texture:String in textures)
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
			}*/
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function undo():void
		{
			doc.info.setSelectedObjects(oldSelections);

			for each (var info:BGInfoEditable in infos)
			{
				parent.remove(info);
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function get name():String
		{
			return format("添加背景于 (图层 {0}, {1}, {2})", parent.index, x, y);
		}
	}
}
