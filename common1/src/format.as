package
{
	import flash.system.ApplicationDomain;
	import flash.utils.getDefinitionByName;

	/**
	 * 字符串格式化，有三种不同的用法<br/>
	 * <code>
	 * e1. format("{0} + {1} = {2}", 1, 2, 3); 得到 "1 + 2 = 3"<br/>
	 * e2. format("{0} + {1} = {2}", [2, 3, 5]); 得到 "2 + 3 = 5"<br/>
	 * e3. format("用户名：{username}, 注册日期：{created}", {username: "张三", created: "2010/9/12"}); 得到 "用户名：张三, 注册日期：2010/9/12"
	 * </code>
	 * @author KK
	 * @param template 模板
	 * @param params 要替换的变量
	 * @return
	 *
	 */
	public function format(template:String, ... params):String
	{
		template = String(template);
		var found:Boolean;
		var templateData:Object = null;
		var numArgs:int = params.length;

		if (numArgs > 0)
		{
			var arg1:* = params[0];

			if (arg1 === null || arg1 === undefined)
			{
				arg1 = {};
			}

			switch (arg1.constructor)
			{
				case String:
				case int:
				case uint:
				case Number:
				case Boolean:
					templateData = params;
					break;
				case Date:
					var templateDataIsDate:Boolean = true;
				default: // Date Object Array
					templateData = arg1;
					break;
			}
		}
		var result:String = template;

		if (templateData == null)
		{
			templateData = {};
		}
		const TEMPLATE_REPLACEMENT:int = 0;
		const VARIABLE:int = 1;
		var match:Array;

		while (match = result.match(/\{([#a-zA-Z0-9_\.\$]+)([+-][0-9]*\.?[0-9]*)?\}/))
		{
			found = false;
			var templateReplacement:String = match[TEMPLATE_REPLACEMENT];
			var varName:String = match[VARIABLE];
			var addition:Number = match[2];
			var varValue:*;

			if (varName in templateData && templateData[varName] != null)
			{
				varValue = templateData[varName];

				if (templateDataIsDate)
				{
					// 日期特殊处理
					if (varName == "month")
					{
						varValue++;
					}
					else if (varName == "minutes")
					{
						if (varValue < 10)
						{
							varValue = "0" + varValue;
						}
					}
				}
				found = true;
			}
			else if (varName.indexOf(".") > 0)
			{
				var path:Array = varName.split(".");
				varName = path.pop();
				var fullName:String = path.join(".");

				if (fullName.indexOf("#") == 0)
				{
					var o:* = formatalias.get(path[0].substring(1));

					if (o)
					{
						varValue = o[varName];
						found = true;
					}
				}
				else if (ApplicationDomain.currentDomain.hasDefinition(fullName))
				{
					varValue = getDefinitionByName(fullName)[varName];
					found = true;
				}
			}

			if (found)
			{
				var numValue:Number = Number(varValue)

				if (!isNaN(numValue) && !isNaN(addition))
				{
					varValue = "" + (numValue + addition);
				}
				result = result.replace(templateReplacement, varValue);
			}
			else
			{
				result = result.replace(templateReplacement, format(TEMPLATE_VALUE_NOT_FOUND, varName));
			}
		}
		return result;
	}
}

const TEMPLATE_VALUE_NOT_FOUND:String = "{{0}==null}";
