package classes
{
	import events.AppItemDeleteEvent;
	import events.AppItemSyncEvent;
	
	import flash.events.EventDispatcher;
	import flash.utils.*;
	import flash.utils.ByteArray;
	
	import mx.controls.Image;
	import mx.utils.Base64Decoder;

	[Bindable]
	public class AppItem extends EventDispatcher
	{
		public var id:String;
		public var name:String;
		public var folderName:String;
		public var description:String;
		public var category:String;
		public var selected:Boolean;
		public var type:String;
		
		public var npkUrl:String;
		public var iconUrl:String;
		
		// Base64 encoded
		public var iconBase64:String;
		public var iconFile:String;
		
		public var storeItemText:String = "购买";
		public var storeItemEnabled:Boolean = true;
		
		public var localItemText:String = "同步";
		public var localItemEnabled:Boolean = true;
		
		public var deviceItemText:String = "从设备移除";
		public var deviceItemEnabled:Boolean = true;
		
		public function AppItem()
		{
			addEventListener(AppItemDeleteEvent.name, appItemDeleteHandler);
			addEventListener(AppItemSyncEvent.name, appItemSyncHandler);
		}
		
		public function dispose():void
		{
			name = "";
			category = "";
			iconBase64 = "";
		}
		
		public function get iconByteArray():ByteArray
		{
			if (iconBase64)
			{
				var base64Dec:Base64Decoder = new Base64Decoder();
				base64Dec.decode(iconBase64);
				return base64Dec.toByteArray();
			}
			return null;
		}
		
		public function isDeviceType():Boolean
		{
			return type == AppItemType.DEVICE;
		}
		
		public function isPcType():Boolean
		{
			return type == AppItemType.PC;
		}
		
		public function isStoreType():Boolean
		{
			return type == AppItemType.STORE;
		}
		
		
		protected function appItemDeleteHandler(event:AppItemDeleteEvent):void
		{
			deviceItemText = "正在删除中...";
			deviceItemEnabled = false;
			setTimeout(UIController.instance.deleteAppFromDevice, 100, this);
		}
		
		protected function appItemSyncHandler(event:AppItemSyncEvent):void
		{
			classes.Utils.log2c("sync "+this.name);
			localItemText = "正在同步中...";
			localItemEnabled = false;
			setTimeout(UIController.instance.installApp, 100, this);
		}
		
		public function clone4DeviceItem():AppItem
		{
			var app:AppItem = new AppItem();
			app.name = this.name;
			app.category = this.category;
			app.type = AppItemType.DEVICE;
			app.folderName = this.name;
			return app;
		}
	}
}