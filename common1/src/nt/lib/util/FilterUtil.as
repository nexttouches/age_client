package nt.lib.util
{
	import flash.display.DisplayObject;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.utils.Dictionary;

	public class FilterUtil
	{
		public static var BlackFilter:ColorMatrixFilter = new ColorMatrixFilter(
			[0.3086,	0.6094, 0.0820,	0,	0,
			 0.3086,	0.6094, 0.0820,	0,	0,
			 0.3086,	0.6094, 0.0820,	0,	0,
			 0,			0,		0,		1,	0]);

		public static var BlackFilterAppliedList:Dictionary = new Dictionary;

		public static function applyBlack(target:DisplayObject):void
		{
			BlackFilterAppliedList[target] = true;
			if (!target.filters)
			{
				target.filters = [ BlackFilter ];
			}
			target.filters = target.filters;
		}

		public static function clearBlack(target:DisplayObject):void
		{
			if (BlackFilterAppliedList[target])
			{
				if (target.filters.length == 1)
				{
					target.filters = null;
				}
				else
				{
					target.filters.splice(target.filters.indexOf(BlackFilter), 1);
				}
				delete BlackFilterAppliedList[target];
				target.filters = target.filters;
			}
		}
	}
}
