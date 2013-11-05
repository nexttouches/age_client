package ageb.modules.scene.propertyPanelClasses
{
	import spark.components.ComboBox;
	import spark.components.NumericStepper;
	import spark.components.TextArea;
	import spark.components.TextInput;
	import age.assets.AvatarInfo;
	import age.assets.RegionInfo;
	import ageb.modules.Modules;
	import ageb.modules.ae.ISelectableInfo;
	import ageb.modules.ae.ObjectInfoEditable;
	import ageb.modules.document.SceneDocument;
	import ageb.modules.scene.op.AddRegion;
	import ageb.modules.scene.op.ChangeActionName;
	import ageb.modules.scene.op.ChangeAvatarID;
	import ageb.modules.scene.op.ChangeObjectProperties;
	import ageb.modules.scene.op.MoveObject;
	import nt.lib.reflect.Property;
	import nt.lib.reflect.Type;
	import org.apache.flex.collections.VectorList;

	/**
	 * ObjectInfo 属性面板
	 * @author zhanghaocong
	 *
	 */
	public class ObjectInfoPropertyPanel extends ObjectInfoPropertyPanelTemplate
	{
		/**
		 * 动作列表，每次更换 objectInfo 时重设
		 */
		private var actions:VectorList;

		/**
		 * constructor
		 *
		 */
		public function ObjectInfoPropertyPanel()
		{
			super();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function resetAllFields():void
		{
			xField.value = NaN;
			yField.value = NaN;
			zField.value = NaN;
			idField.text = "";
			typeField.selectedIndex = -1;
			userDataField.text = "";
			avatarIDField.text = "";
			actionsField.dataProvider = null;
			massField.value = 0;
			elasticityField.value = 0;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function set infos(value:Vector.<ISelectableInfo>):void
		{
			if (objectInfo)
			{
				actions = null;
				typeField.dataProvider = null;
				regionIDField.dataProvider = null;
				objectInfo.onPositionChange.remove(onPositionChange);
				objectInfo.onPropertiesChange.remove(onPropertiesChange);
				objectInfo.onAvatarIDChange.remove(onAvatarIDChange);
				objectInfo.onActionNameChange.remove(onActionNameChange);
			}
			super.infos = value;

			if (objectInfo)
			{
				initActionsField();
				typeField.dataProvider = Modules.getInstance().settings.objectTypes;
				regionIDField.dataProvider = SceneDocument(doc).info.regionsVectorList;
				objectInfo.onPositionChange.add(onPositionChange);
				objectInfo.onPropertiesChange.add(onPropertiesChange);
				objectInfo.onAvatarIDChange.add(onAvatarIDChange);
				objectInfo.onActionNameChange.add(onActionNameChange);
				onPositionChange();
				onPropertiesChange();
				onAvatarIDChange();
				onActionNameChange();
			}
		}

		/**
		 * 初始化 actionsFieid
		 *
		 */
		private function initActionsField():void
		{
			actions = new VectorList(new Vector.<String>);
			const ai:AvatarInfo = objectInfo.avatarInfo;

			if (ai)
			{
				for (var actionName:String in ai.actions)
				{
					actions.addItem(actionName);
				}
			}
			actionsField.dataProvider = actions;
		}

		/**
		 * @private
		 *
		 */
		private function onActionNameChange():void
		{
			actionsField.selectedItem = objectInfo.actionName
		}

		/**
		 * @private
		 *
		 */
		private function onAvatarIDChange():void
		{
			avatarIDField.text = objectInfo.avatarID;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function regionIDField_labelFunction(r:RegionInfo):String
		{
			return r.toString();
		}

		/**
		 * @inheritDoc
		 *
		 */
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

		/**
		 * @private
		 *
		 */
		private function onPropertiesChange(trigger:Object = null):void
		{
			if (trigger == this)
			{
				return;
			}
			idField.text = objectInfo.id;
			regionIDField.selectedItem = SceneDocument(doc).info.getRegionByID(objectInfo.regionID);
			typeField.selectedData = objectInfo.type;
			restoreUserData();
		}

		/**
		 * @private
		 *
		 */
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

		/**
		 * @inheritDoc
		 *
		 */
		override protected function restoreUserData():void
		{
			userDataField.text = objectInfo.userData;
		}

		/**
		 * @private
		 *
		 */
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

		/**
		 * @inheritDoc
		 *
		 */
		override protected function saveAvatarID():void
		{
			new ChangeAvatarID(doc, infos, avatarIDField.text).execute();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function savePosition():void
		{
			new MoveObject(doc, infos, xField.value - objectInfo.position.x, yField.value - objectInfo.position.y, zField.value - objectInfo.position.z).execute();
		}

		/**
		 * @inheritDoc
		 *
		 */
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

		/**
		 * @private
		 *
		 */
		final protected function get objectInfo():ObjectInfoEditable
		{
			return info as ObjectInfoEditable;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function openAvatar():void
		{
			Modules.getInstance().document.openAvatar(objectInfo.avatarID);
		}

		/**
		 * @private
		 *
		 */
		override protected function saveActionName():void
		{
			new ChangeActionName(doc, infos, actionsField.selectedItem).execute();
		}
	}
}
