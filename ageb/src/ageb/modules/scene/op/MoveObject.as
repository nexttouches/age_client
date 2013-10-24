package ageb.modules.scene.op
{
	import flash.utils.Dictionary;
	import ageb.modules.ae.IParent;
	import ageb.modules.ae.ISelectableInfo;
	import ageb.modules.document.Document;

	/**
	 * 移动 / 复制对象的操作<br>
	 * 这里的对象是指实现了 ISelectableInfo 接口的对象
	 * @author zhanghaocong
	 *
	 */
	public class MoveObject extends SceneOPBase
	{
		/**
		 * 移动量 x
		 */
		public var x:Number;

		/**
		 * 移动量 y
		 */
		public var y:Number;

		/**
		 * 移动量 z
		 */
		public var z:Number;

		/**
		 * 吸附 x
		 */
		public var snapX:Number;

		/**
		 * 吸附 y
		 */
		public var snapY:Number;

		/**
		 * 吸附 z
		 */
		public var snapZ:Number;

		/**
		 * 移动的对象
		 */
		public var selectedObjects:Vector.<ISelectableInfo>;

		/**
		 * 旧 x，以对象做 key
		 */
		public var oldXs:Dictionary;

		/**
		 * 旧 y，以对象做 key
		 */
		public var oldYs:Dictionary;

		/**
		 * 旧 y，以对象做 key
		 */
		public var oldZs:Dictionary;

		/**
		 * 设置或获取当前操作是否为复制
		 */
		public var isDuplicate:Boolean;

		/**
		 * 当 isDuplicate 为 true 时，储存复制的对象<br>
		 * 否则为 null
		 */
		public var newObjects:Vector.<ISelectableInfo>;

		/**
		 * 当 isDuplicate 为 true 时，记录将要复制到哪个 parent 中
		 * 否则为 null
		 */
		public var parents:Vector.<IParent>;

		/**
		 * 是否通过拖拽调用
		 */
		public var isViaDrag:Boolean;

		/**
		 * 创建一个新的移动对象操作
		 * @param doc 文档
		 * @param selectedObjects 要移动的对象
		 * @param x 移动量 x
		 * @param y 移动量 y
		 * @param snapX 吸附 x
		 * @param snapY 吸附 y
		 * @param isDuplicate 是否复制
		 * @param isViaDrag 是否通过拖拽调用
		 *
		 */
		public function MoveObject(doc:Document, selectedObjects:Vector.<ISelectableInfo>, x:Number, y:Number, z:Number, snapX:Number = 1, snapY:Number = 1, snapZ:Number = 1, isDuplicate:Boolean = false, isViaDrag:Boolean = false)
		{
			super(doc);
			this.snapX = snapX;
			this.snapY = snapY;
			this.snapZ = snapZ;
			this.x = x;
			this.y = y;
			this.z = z;
			this.selectedObjects = selectedObjects.concat();
			this.isDuplicate = isDuplicate;
			this.isViaDrag = isViaDrag;
		}

		override public function redo():void
		{
			// 复制
			if (isDuplicate)
			{
				if (isViaDrag)
				{
					redoDragDuplicate();
				}
				else
				{
					redoDuplicate();
				}
			}
			// 移动
			else
			{
				if (isViaDrag)
				{
					redoDragMove();
				}
				else
				{
					redoMove();
				}
			}
		}

		private function redoDuplicate():void
		{
			for (var i:int = 0; i < newObjects.length; i++)
			{
				parents[i].add(newObjects[i]);
			}
			// 设置选择项到复制后的对象
			doc.info.setSelectedObjects(newObjects, this);
		}

		private function redoDragDuplicate():void
		{
			for (var i:int = 0; i < newObjects.length; i++)
			{
				var o:ISelectableInfo = newObjects[i];
				parents[i].add(o);
			}
			// 设置选择项到复制后的对象
			doc.info.setSelectedObjects(newObjects, this);
		}

		private function redoMove():void
		{
			for each (var o:ISelectableInfo in selectedObjects)
			{
				o.moveBy(x, y, z, snapX, snapY, snapZ);
			}
		}

		private function redoDragMove():void
		{
			for each (var o:ISelectableInfo in selectedObjects)
			{
				o.moveBy(x * o.dragRatio.x, y * o.dragRatio.y, z * o.dragRatio.z, snapX, snapY, snapZ);
			}
		}

		override public function undo():void
		{
			// 复制
			if (isDuplicate)
			{
				undoDuplicate();
			}
			// 移动
			else
			{
				undoMove();
			}
		}

		private function undoDuplicate():void
		{
			for (var i:int = 0; i < newObjects.length; i++)
			{
				parents[i].remove(newObjects[i]);
			}
			// 设置选择项到复制前的对象
			doc.info.setSelectedObjects(selectedObjects, this);
		}

		private function undoMove():void
		{
			for each (var o:ISelectableInfo in selectedObjects)
			{
				o.moveTo(oldXs[o], oldYs[o], oldZs[o]);
			}
		}

		override protected function saveOld():void
		{
			// 复制
			if (isDuplicate)
			{
				newObjects = new Vector.<ISelectableInfo>(selectedObjects.length);
				parents = new Vector.<IParent>(selectedObjects.length);

				for (var i:int = 0; i < selectedObjects.length; i++)
				{
					newObjects[i] = selectedObjects[i].clone() as ISelectableInfo;

					if (isDuplicate)
					{
						if (isViaDrag)
						{
							newObjects[i].moveBy(x * newObjects[i].dragRatio.x, y * newObjects[i].dragRatio.y, z * newObjects[i].dragRatio.z, snapX, snapY, snapZ);
						}
						else
						{
							newObjects[i].moveBy(x, y, z, snapX, snapY, snapZ);
						}
					}
					parents[i] = Object(selectedObjects[i]).parent;
				}
			}
			// 移动
			else
			{
				oldXs = new Dictionary();
				oldYs = new Dictionary();
				oldZs = new Dictionary();

				for each (var o:* in selectedObjects)
				{
					oldXs[o] = o.x;
					oldYs[o] = o.y;
					oldZs[o] = o.z;
				}
			}
		}

		override public function get name():String
		{
			if (isDuplicate)
			{
				return format("复制对象 ({x}, {y}, {z})", this);
			}
			return format("移动对象 ({x}, {y}, {z})", this);
		}
	}
}
