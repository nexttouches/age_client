package age.extensions
{
	import flash.errors.IllegalOperationError;
	import flash.geom.Point;
	import age.AGE;
	import age.assets.TextureAsset;
	import age.renderers.SceneRenender;
	import starling.animation.IAnimatable;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;

	public class DamageFx
	{
		public function DamageFx()
		{
			// 没用的构造函数
		}

		private static const DEFAULT_TEXTURE_PATH:String = "assets/textures/damage_effect";

		private static var container:Sprite;

		/**
		 * 贴图的用户，用于维持引用
		 */
		private static var user:DummyUser = new DummyUser();

		private static var ta:TextureAsset;

		/**
		 * 删除所有的伤害数字，解除 container 引用<br>
		 * 此后可以通过调用 init 重新进行初始化
		 *
		 */
		public static function dispose():void
		{
			if (!container)
			{
				throw new IllegalOperationError("[DamageNumber] 调用 dispose失败，因为尚未初始化");
			}
			removeAll();
			user.asset = null;
			ta = null;
			container = null;
		}

		/**
		 * 删除所有的伤害数字
		 *
		 */
		public static function removeAll():void
		{
			if (!container)
			{
				throw new IllegalOperationError("[DamageNumber] 调用 removeAll 失败，因为尚未初始化");
			}

			for (var i:int = container.numChildren - 1; i >= 0; i--)
			{
				if (container.getChildAt(i) is Helper)
				{
					container.getChildAt(i).removeFromParent(true);
				}
			}
		}

		/**
		 * 初始化伤害数字<br>
		 * <del>在正式使用前，请确保<br>
		 * ImagePool 和 TextFieldPool 已正确初始化</del><br>
		 * @param container 设置伤害数字出现在哪个容器中
		 * @param texturePath 贴图文件路径
		 */
		public static function init(container:Sprite, texturePath:String = DEFAULT_TEXTURE_PATH):void
		{
			if (!container)
			{
				throw new IllegalOperationError("[DamageNumber] 调用 init 失败，因为已初始化");
			}
			DamageFx.container = container;
			ta = TextureAsset.get(texturePath);
			ta.useThumb = false;
			user.asset = ta;
			ta.load();
		}

		/**
		 * 显示伤害数字
		 * @param number
		 * @param x
		 * @param y
		 *
		 */
		public static function showNumber(number:int, isCrictial:Boolean, x:Number, y:Number):void
		{
			if (!container)
			{
				throw new IllegalOperationError("[DamageNumber] 调用 showNumber 失败，因为尚未初始化");
			}
			var s:String = String(number);
			var prefix:String = isCrictial ? "crictial_number/" : "normal_number/";
			const charWidth:int = 24;
			const anchor:int = s.length * charWidth * 0.5;

			for (var i:int = 0, n:int = s.length; i < n; i++)
			{
				var mc:MovieClip = createMC(prefix + s.charAt(i), 48, x - anchor + i * charWidth, y);
			}
		}

		/**
		 * 显示暴击
		 * @param x
		 * @param y
		 *
		 */
		public static function showCrictial(x:Number, y:Number):void
		{
			if (!container)
			{
				throw new IllegalOperationError("[DamageNumber] 调用 showNumber 失败，因为尚未初始化");
			}
			var mc:MovieClip = createMC("crictial/", 48, x, y);
		}

		/**
		 * 显示打击特效
		 * @param x
		 * @param y
		 * @param id 要显示的造型
		 * @param isFlipX 是否要水平反转
		 */
		public static function showHitEffect(x:Number, y:Number, id:int = -1, isFlipX:Boolean = false):void
		{
			if (!container)
			{
				throw new IllegalOperationError("[DamageNumber] 调用 showNumber 失败，因为尚未初始化");
			}

			if (id == -1)
			{
				const n:int = 3 + 1;
				id = Math.random() * n;
			}
			var mc:MovieClip = createMC("hit_effect/" + id, 30, x, y);
			mc.pivotX = mc.pivotY = mc.texture.frame.width * 0.5;

			// 水平映射
			if (isFlipX)
			{
				mc.scaleX = -1;
			}
		}

		private static function removeMC(event:Event):void
		{
			MovieClip(event.currentTarget).removeFromParent(true);
			AGE.s.juggler.remove(IAnimatable(event.currentTarget));
		}

		private static function createMC(prefix:String, fps:int, x:Number, y:Number):MovieClip
		{
			var mc:MovieClip = new Helper(ta.getTextures(prefix), fps);
			mc.loop = false;
			mc.addEventListener(Event.COMPLETE, removeMC);
			container.addChild(mc);
			AGE.s.juggler.add(mc);
			var globalPoint:Point = SceneRenender(AGE.s.root).charLayer.localToGlobal(new Point(x, y));
			mc.x = globalPoint.x;
			mc.y = globalPoint.y;
			return mc;
		}
	}
}
import starling.display.MovieClip;
import starling.textures.Texture;

class Helper extends MovieClip
{
	public function Helper(textures:Vector.<Texture>, fps:Number = 12)
	{
		super(textures, fps);
	}
}
