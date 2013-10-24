package
{
	import nt.lib.reflect.Type;

	/**
	 * 转换类中的所有常量到指定数组<br>
	 * 该方法将会自动识别 "Translation" 元标签<br>
	 * 返回值是 [{label: "Translation 字段设置值", data: "字段名称"}]
	 */
	public function constantsToArray(o:Class, metadata:String = "Translation", locale:String = "zh_CN"):Array
	{
		var result:Array = [];

		for each (var field:XML in Type.of(o).typeInfo..constant)
		{
			var key:String = String(field.@name);
			var m:XMLList = (field.metadata.(@name == metadata));

			if (m.length() > 0)
			{
				var translation:String = m.arg.(@key == locale).@value;
				result.push({ label: translation, data: o[key]});
			}
		}
		return result;
	}
}
