package ageb.modules.scene.propertyPanelClasses
{
	import spark.components.ComboBox;
	import spark.components.NumericStepper;
	import spark.components.TextArea;
	import spark.components.TextInput;
	import age.assets.RegionInfo;
	import ageb.modules.Modules;
	import ageb.modules.ae.ISelectableInfo;
	import ageb.modules.ae.ObjectInfoEditable;
	import ageb.modules.document.SceneDocument;
	import ageb.modules.scene.op.AddRegion;
	import ageb.modules.scene.op.ChangeAvatarID;
	import ageb.modules.scene.op.ChangeObjectProperties;
	import ageb.modules.scene.op.MoveObject;
	import nt.lib.reflect.Property;
	import nt.lib.reflect.Type;

	public class ObjectInfoPropertyPanel extends ObjectInfoPropertyPanelTemplate
	{
		public function ObjectInfoPropertyPanel()
		{
			super();
		}

		override protected function resetAllFields():void
		{
			xField.value = NaN;
			yField.value = NaN;
			zField.value = NaN;
			uniqueIDField.text = "";
			objectIDField.text = "";
			typeField.selectedIndex = -1;
			subtypeField.text = "";
			userDataField.text = "";
			energyLevelField.value = NaN;
			levelField.value = NaN;
			growIDField.value = NaN;
			aiIDField.value = NaN;
			dropIDField.value = NaN;
			avatarIDField.text = "";
			actionsField.dataProvider = null;
			massField.value = 0;
			elasticityField.value = 0;
		}

		override public function set infos(value:Vector.<ISelectableInfo>):void
		{
			if (objectInfo)
			{
				typeField.dataProvider = null;
				regionIDField.dataProvider = null;
				objectInfo.onPositionChange.remove(onPositionChange);
				objectInfo.onPropertiesChange.remove(onPropertiesChange);
				objectInfo.onAvatarIDChange.remove(onAvatarIDChange);
			}
			super.infos = value;

			if (objectInfo)
			{
				typeField.dataProvider = Modules.getInstance().settings.objectTypes;
				regionIDField.dataProvider = SceneDocument(doc).info.regionsVectorList;
				objectInfo.onPositionChange.add(onPositionChange);
				objectInfo.onPropertiesChange.add(onPropertiesChange);
				objectInfo.onAvatarIDChange.add(onAvatarIDChange);
				onPositionChange();
				onPropertiesChange();
				onAvatarIDChange();
			}
		}

		private function onAvatarIDChange():void
		{
			avatarIDField.text = objectInfo.avatarID;
		}

		override protected function regionIDField_labelFunction(r:RegionInfo):String
		{
			return r.toString();
		}

		override protected function saveProperties():void
		{
			var props:Object = {};

			for each (var d:Property in Type.of(objectInfo).writableProperties)
			{
				if (d.hasMetadata("Extended"))
				{
					// 所有输入框都是 Field 结尾的
					props[d.name] = getValue(this[d.name + "Field"]);
				}
			}
			new ChangeObjectProperties(doc, infos, props).execute();
		}

		private function onPropertiesChange(trigger:Object = null):void
		{
			if (trigger == this)
			{
				return;
			}
			uniqueIDField.text = String(objectInfo.uniqueID);
			objectIDField.text = String(objectInfo.objectID);
			regionIDField.selectedItem = SceneDocument(doc).info.getRegionByID(objectInfo.regionID);
			typeField.selectedData = objectInfo.type;
			subtypeField.text = String(objectInfo.subtype);
			restoreUserData();
			energyLevelField.value = objectInfo.energyLevel;
			levelField.value = objectInfo.level;
			growIDField.value = objectInfo.growID;
			aiIDField.value = objectInfo.aiID;
			dropIDField.value = objectInfo.dropID;
		}

		private function getValue(c:*):*
		{
			// 类型判断
			if (c is TextInput)
			{
				return TextInput(c).text;
			}
			else if (c is NumericStepper)
			{
				return NumericStepper(c).value;
			}
			else if (c is AutoCompleteDropdown)
			{
				// 没有选中任何项目，返回 -1，避免报错
				return ComboBox(c).selectedItem ? ComboBox(c).selectedItem.data : -1;
			}
			else if (c is TextArea)
			{
				return TextArea(c).text;
			}

			// 好吧，没办法了，判断个别控件
			if (c == regionIDField)
			{
				// selectedItem 的类型是，RegionInfo
				// 我们实际是返回 RegionInfo.id
				return regionIDField.selectedItem.id;
			}
			// 妥妥的出错
			throw new ArgumentError("无法匹配指定的组件 " + c);
		}

		override protected function restoreUserData():void
		{
			userDataField.text = objectInfo.userData;
		}

		private function onPositionChange():void
		{
			if (!objectInfo)
			{
				return;
			}
			xField.value = objectInfo.position.x;
			yField.value = objectInfo.position.y;
			zField.value = objectInfo.position.z;
		}

		override protected function saveAvatarID():void
		{
			new ChangeAvatarID(doc, infos, avatarIDField.text).execute();
		}

		override protected function savePosition():void
		{
			new MoveObject(doc, infos, xField.value - objectInfo.position.x, yField.value - objectInfo.position.y, zField.value - objectInfo.position.z).execute();
		}

		override protected function addRegion():void
		{
			var op:AddRegion = new AddRegion(doc, objectInfo.position.x);
			op.execute();
			// 执行后可以获得该 OP 添加了的 RegionInfo
			var r:RegionInfo = op.region;
			// 通过代码设置一下
			regionIDField.selectedItem = r;
			saveProperties();
		}

		final protected function get objectInfo():ObjectInfoEditable
		{
			return info as ObjectInfoEditable;
		}

		override protected function openAvatar():void
		{
			Modules.getInstance().document.openAvatar(objectInfo.avatarID);
		}
	}
}
