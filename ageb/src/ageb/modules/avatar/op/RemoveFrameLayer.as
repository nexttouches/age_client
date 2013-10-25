package ageb.modules.avatar.op
{
	import age.assets.FrameLayerInfo;
	import ageb.modules.document.Document;

	/**
	 * 删除帧图层
	 * @author zhanghaocong
	 *
	 */
	public class RemoveFrameLayer extends AvatarOPBase
	{
		/**
		 * 本次要删除的图层索引
		 */
		private var indices:Vector.<int>;

		/**
		 * 删除前图层列表
		 */
		private var oldLayers:Vector.<FrameLayerInfo>;

		/**
		 * 删除后图层列表
		 */
		private var layers:Vector.<FrameLayerInfo>;

		/**
		 * constructor
		 * @param doc
		 * @param toRemoves 要删除的图层列表
		 *
		 */
		public function RemoveFrameLayer(doc:Document, indices:Vector.<int>)
		{
			super(doc);
			this.indices = indices;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function redo():void
		{
			action.setLayers(layers);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function saveOld():void
		{
			oldLayers = action.layers.concat();
			layers = oldLayers.concat();
			const sorted:Vector.<int> = indices.sort(function(a:int, b:int):int
			{
				return b - a;
			});

			for (var i:int = 0; i < sorted.length; i++)
			{
				layers.splice(sorted[i], 1);
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function undo():void
		{
			action.setLayers(oldLayers);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function get name():String
		{
			return "删除图层";
		}
	}
}
