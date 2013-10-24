package age.assets
{

	/**
	 * RegionInfo 表示一个场景区域
	 * @author zhanghaocong
	 *
	 */
	public class RegionInfo extends Box
	{
		/**
		 * 区域 ID
		 */
		public var id:int;

		/**
		 * RegionInfo 所属 SceneInfo
		 */
		public var parent:SceneInfo;

		/**
		 * 创建一个新的 RegionInfo
		 * @param raw
		 *
		 */
		public function RegionInfo(raw:Object = null)
		{
			if (raw)
			{
				id = raw.id;
				setTo(raw.x, 0, 0, raw.width, 0, "depth" in raw ? raw.depth : raw.height);
			}
		}

		public function toString():String
		{
			if (id == 0)
			{
				return "0: 无";
			}
			return id + ": " + x + "-" + (x + width);
		}
	}
}
