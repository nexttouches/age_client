package age.assets
{

	/**
	 * 对象类型<br>
	 * @see ObjectInfo#type
	 * @author zhanghaocong
	 *
	 */
	public class ObjectType
	{

		[Translation(zh_CN="NPC")]
		public static const NPC:int = 0;

		[Translation(zh_CN="g 怪物")]
		public static const MONSTER:int = 1;

		[Translation(zh_CN="z 装饰")]
		public static const DECORATION:int = 2;

		[Translation(zh_CN="c 出生点")]
		public static const STARTING_POINT:int = 3;

		[Translation(zh_CN="w 无类型")]
		public static const NONE:int = -1;

		public static const AVATAR:int = -2;

		public static const AXIS:int = -3;

		public function ObjectType()
		{
		}
	}
}
