package classes
{
	import flash.utils.ByteArray;
	
	import mx.controls.Image;
	import mx.utils.Base64Decoder;

	[Bindable]
	public class AppItem
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
		
		public function AppItem()
		{
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
	}
}