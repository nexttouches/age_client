package ageb.modules.scene.op
{
	import flash.geom.Vector3D;
	import ageb.modules.document.Document;

	/**
	 * 修改网格分辨率
	 * @author zhanghaocong
	 *
	 */
	public class ChangeSceneGridResolution extends SceneOPBase
	{
		/**
		 * 旧分辨率
		 */
		public var oldResolution:Vector3D;

		/**
		 * 旧网格数据
		 */
		public var oldGrids:Array;

		/**
		 * 新分辨率
		 */
		public var resolution:Vector3D;

		/**
		 * constructor
		 *
		 */
		public function ChangeSceneGridResolution(doc:Document, resolution:Vector3D)
		{
			super(doc);
			this.resolution = resolution;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function saveOld():void
		{
			oldGrids = doc.info.grids;
			oldResolution = doc.info.gridResolution.clone();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function redo():void
		{
			doc.info.setGridResolution(resolution);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function undo():void
		{
			doc.info.setGridResolution(oldResolution, oldGrids);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function get name():String
		{
			return format("修改网格分辨率 ({x}×{z})", resolution);
		}
	}
}
