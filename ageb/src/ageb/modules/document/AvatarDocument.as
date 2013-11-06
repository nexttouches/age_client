package ageb.modules.document
{
	import flash.errors.IllegalOperationError;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Vector3D;
	import age.data.ActionInfo;
	import age.data.AvatarInfo;
	import age.data.ObjectType;
	import ageb.modules.ae.AvatarInfoEditable;
	import ageb.modules.ae.BGInfoEditable;
	import ageb.modules.ae.IParent;
	import ageb.modules.ae.LayerInfoEditable;
	import ageb.modules.ae.ObjectInfoEditable;
	import ageb.modules.ae.SceneInfoEditable;
	import ageb.modules.avatar.AvatarDocumentView;
	import ageb.utils.FileUtil;

	/**
	 * Avatar 文档
	 * @author zhanghaocong
	 *
	 */
	public class AvatarDocument extends Document
	{
		/**
		 * 默认的动作名称
		 */
		public static const DEFAULT_ACTION_NAME:String = "idle";

		/**
		 * AvatarInfo
		 */
		public var avatar:AvatarInfoEditable;

		/**
		 * 显示在场景里的 ObjectInfo
		 */
		public var object:ObjectInfoEditable;

		/**
		 * SceneInfo
		 */
		public var scene:SceneInfoEditable;

		/**
		 * 预览用的背景图
		 */
		public var bg:BGInfoEditable;

		/**
		 * 创建一个新的 AvatarDocument
		 * @param file
		 * @param raw
		 *
		 */
		public function AvatarDocument(file:File, raw:Object)
		{
			super(file, raw);

			// 根据文件名设置 id
			if (file)
			{
				raw.id = file.name.split(".")[0];
			}
			// 创建 AvatarInfo
			avatar = new AvatarInfoEditable(raw);
			AvatarInfo.list[avatar.id] = avatar;
			// 创建 SceneInfo
			scene = new SceneInfoEditable(FileUtil.readJSON(File.applicationDirectory.resolvePath("templates/avatar_scene.txt")));
			// 创建 ObjectInfo，并添加到 SceneInfo 中
			object = new ObjectInfoEditable();
			object.position.setTo(scene.width / 2, 0, scene.depth / 2);
			object.avatarID = avatar.id;

			// 默认动作是 idle
			// 但是有些 Avatar 连这个动作可能也没有
			// 这边做个兼容处理
			if (avatar.numActions > 0)
			{
				if (avatar.hasAction(DEFAULT_ACTION_NAME))
				{
					object.actionName = DEFAULT_ACTION_NAME;
				}
				else
				{
					object.actionName = avatar.firstAction.name;
				}
			}
			object.type = ObjectType.AVATAR; // 必须设置为 AVATAR
			object.isAutoPlay = false;
			object.stop();
			// 添加一个 ObjectInfo，其中 objectID 是当前 avatarID
			IParent(scene.charLayer).add(object); // 已知 charLayer 实现了 IParent
			// 创建背景并添加到 SceneInfo 中
			bg = new BGInfoEditable()
			bg.x = 0;
			bg.y = scene.height;
			bg.z = 0;
			bg.isSelectable = false; // 背景只是看看，不需可选
			bg.texture = "avatar_scene.png#avatar_scene";
			LayerInfoEditable(scene.layers[0]).addBG(bg);
			const position:Vector3D = object.position;
			focus.x = position.x;
			focus.y = scene.projectY(position.y, position.z);
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function get name():String
		{
			if (isNew)
			{
				return avatar.id;
			}
			return super.name;
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function get rawString():String
		{
			return JSON.stringify(avatar);
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function get viewClass():Class
		{
			return AvatarDocumentView;
		}

		/**
		 * @inheritDoc
		 */
		override public function save():void
		{
			if (isSaving)
			{
				return;
			}

			if (file == null)
			{
				throw new IllegalOperationError("保存文档时出错，file 不可为 null");
			}
			state = DocumentState.SAVING;
			onSaveStart.dispatch();
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			fs.writeUTFBytes(rawString);
			fs.close();
			state = DocumentState.READY;
			onSaveComplete.dispatch();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function preview():void
		{
			for each (var actionInfo:ActionInfo in avatar.actions)
			{
				modules.job.addJob(new PublishActionJob(actionInfo));
			}
		}
	}
}
