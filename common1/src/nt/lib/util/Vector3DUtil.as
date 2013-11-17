package nt.lib.util
{
	import flash.geom.Vector3D;

	/**
	 * Vector3D 工具类
	 * @author zhanghaocong
	 *
	 */
	public class Vector3DUtil
	{
		/**
		 * 都是静态方法，构造函数无用
		 *
		 */
		public function Vector3DUtil()
		{
		}

		/**
		 * 从数组创建 Vector3D
		 * @param a 源数据数组，储存形式是 [x, y, z, w]
		 * @param isIncludeFour 设置是否要导入第四个属性 w
		 * @return 创建了的 Vector3D
		 *
		 */
		public static function fromArray(a:Array, isIncludeFour:Boolean = false):Vector3D
		{
			if (isIncludeFour)
			{
				return new Vector3D(a[0], a[1], a[2], a[3]);
			}
			return new Vector3D(a[0], a[1], a[2]);
		}

		/**
		 * 从对象创建 Vector3D
		 * @param a 源数据数组，储存形式是 [x, y, z, w]
		 * @param isIncludeFour 设置是否要导入第四个属性 w
		 * @return 创建了的 Vector3D
		 *
		 */
		public static function fromObject(a:Object, isIncludeFour:Boolean = false):Vector3D
		{
			if (isIncludeFour)
			{
				return new Vector3D(a.x, a.y, a.z, a.w);
			}
			return new Vector3D(a.x, a.y, a.z);
		}

		/**
		 * 导出 Vector3D 到 Array
		 * @param v 源 Vectory3D
		 * @param isIncludeFour 设置是否要导出第四个属性 w
		 * @return 导出的数组
		 *
		 */
		public static function toArray(v:Vector3D, isIncludeFour:Boolean = false):Array
		{
			if (isIncludeFour)
			{
				return [ v.x, v.y, v.z, v.w ];
			}
			return [ v.x, v.y, v.z ];
		}

		/**
		 * 导出 Vector3D 到 Vector.&lt;Number&gt;
		 * @param v 源 Vectory3D
		 * @param isIncludeFour 设置是否要导出第四个属性 w
		 * @return 导出的数组
		 *
		 */
		public static function toVector(v:Vector3D, isIncludeFour:Boolean = false):Vector.<Number>
		{
			if (isIncludeFour)
			{
				return new <Number>[ v.x, v.y, v.z, v.w ];
			}
			return new <Number>[ v.x, v.y, v.z ];
		}
	}
}
