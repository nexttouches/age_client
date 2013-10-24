package nt.ui.components
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import nt.assets.IAsset;
	import nt.assets.IAssetUser;
	import nt.assets.extensions.ImageAsset;
	import nt.ui.core.Component;

	public class Image extends Component implements IAssetUser
	{
		private var content:DisplayObject;

		public function Image()
		{
			super();
		}

		private var _source:*;

		public function get source():*
		{
			return _source;
		}

		/**
		 * 可以是 Class 或 URL 或 ImageAsset
		 * @param value
		 *
		 */
		public function set source(value:*):void
		{
			if (!(value is Class || value is String || value is ImageAsset || value == null))
			{
				throw new ArgumentError("source 只能是 Class 或 String");
			}

			if (_source != value)
			{
				_source = value;

				if (_source)
				{
					invalidate();
				}
				else
				{
					if (content is Loader)
					{
						Loader(content).unloadAndStop();
					}

					if (content)
					{
						removeChild(content);
						content = null
					}
				}
			}
		}

		override protected function render():void
		{
			if (isDisposed)
			{
				throw new Error("似乎是代码出问题了");
			}

			if (_source is Class)
			{
				loadClass(_source as Class);
			}
			else if (_source is String)
			{
				loadURL(_source as String);
			}
			else if (_source is ImageAsset)
			{
				loadImageAsset(_source as ImageAsset);
			}
			super.render();
		}

		private function loadImageAsset(asset:ImageAsset):void
		{
			asset.addUser(this);
		}

		private function loadURL(url:String):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, adjustSize);
			loader.load(new URLRequest(url), new LoaderContext(false, new ApplicationDomain(ApplicationDomain.currentDomain)));
			addChild(content = loader);
		}

		private function adjustSize(event:Event = null):void
		{
			if (_width == 0)
			{
				_width = content.width;
			}
			else
			{
				content.width = width;
			}

			if (_height == 0)
			{
				_height = content.height;
			}
			else
			{
				content.height = height;
			}
			fireOnResize();
		}

		private function loadClass(factory:Class):void
		{
			addChild(content = new factory());
			adjustSize();
		}

		override public function dispose():Boolean
		{
			source = null;
			return super.dispose();
		}

		public function onAssetDispose(asset:IAsset):void
		{
			removeChild(content);
			content = null;
			adjustSize();
		}

		public function onAssetLoadComplete(asset:IAsset):void
		{
			addChild(content = new Bitmap(ImageAsset(asset).result));
			adjustSize();
		}

		public function onAssetLoadError(asset:IAsset):void
		{
			// TODO Auto Generated method stub
		}

		public function onAssetLoadProgress(asset:IAsset, bytesLoaded:uint, bytesTotal:uint):void
		{
			// TODO Auto Generated method stub
		}
	}
}
