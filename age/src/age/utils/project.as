package age.utils
{
	import flash.geom.Point;
	import flash.geom.Vector3D;

	/**
	 * 将 3D 坐标投影到 2D 坐标<br>
	 *
	 */
	[Inline]
	public function project(source:Vector3D, result:Point = null):Point
	{
		if (!result)
		{
			result = new Point();
		}
		result.x = source.x;
		result.y = -source.y - source.z * 0.5;
		return result;
	}
}
