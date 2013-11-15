package age.pad
{
	import age.data.ObjectInfo;

	/**
	 * 手柄基类
	 * @author zhanghaocong
	 *
	 */
	public class Pad
	{
		/**
		 * constructor
		 *
		 */
		public function Pad()
		{
		}

		/**
		 * 当前手柄操作的对象（数组）
		 */
		public var objectInfos:Vector.<ObjectInfo> = new Vector.<ObjectInfo>;

		/**
		 * 添加一个被操作对象
		 *
		 */
		public function addObject(o:ObjectInfo):void
		{
			objectInfos.push(o);
		}

		/**
		 * 删除一个操作对象
		 * @param o
		 *
		 */
		public function removeObject(o:ObjectInfo):void
		{
			objectInfos.splice(objectInfos.indexOf(o), 1);
		}

		/**
		 * 删除所有操作对象
		 *
		 */
		public function removeAllObject():void
		{
			while (objectInfos.length)
			{
				removeObject(objectInfos[0]);
			}
		}

		/**
		 * 回收资源
		 *
		 */
		public function dispose():void
		{
			removeAllObject();
			objectInfos = null;
		}
	}
}
