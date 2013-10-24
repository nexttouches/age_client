package nt.lib.util
{
	import flash.utils.ByteArray;

	/**
	 * 克隆，利用该方法可以将一个对象克隆成另外一个对象<br/>
	 * （要求两者有相同的序列化/反序列化过程才能正确克隆，否则无法保证跨类型克隆结果）
	 * @param object 要克隆的对象
	 * @param asFactory 克隆出来的对象类型，默认值是 object 的类型，可选
	 */
	public function clone(object:*, asFactory:Class = null):*
	{
		if (object is Boolean || object == null || object == undefined || object is String || object is int || object is Number || object is uint)
		{
			return object;
		}
		ClassUtil.register(object.constructor); //源数据类型
		if (object is Array || object.constructor == Object)
		{
			for each (var element:* in object)
			{
				if (element != null && element != undefined)
				{
					ClassUtil.register(element.constructor);
				}
			}
		}
		var bytes:ByteArray = new ByteArray();
		bytes.writeObject(object);
		bytes.position = 0;
		ClassUtil.register(object.constructor, asFactory); //目标类型
		return bytes.readObject();
	}
}
