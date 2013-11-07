package
{

	/**
	 * 导出 from 对象中指定字段的值到 to 对象中，通过设置 condition 可以避免特定的值被导出
	 * <pre>
	 * var src = {fieldA: <span style="color: red;">null</span>, fieldB: "b"}
	 * var dest = {};
	 * export(src, dest, "fieldA", <span style="color: red;">null</span>);
	 * export(src, dest, "fieldB", null);
	 * // dest 的值是 {fieldB: "b"}，因为 fieldA 为 null
	 * </pre>
	 */
	[Inline]
	public function export(from:Object, to:Object, key:String, condition:*):void
	{
		if (from[key] != condition)
		{
			to[key] = from[key];
		}
	}
}
