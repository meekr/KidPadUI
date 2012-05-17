package classes
{
	import classes.Constants;
	
	import flash.events.EventDispatcher;
	import flash.external.*;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.controls.Alert;

	public class DataController extends EventDispatcher
	{
		private static var mInstance:DataController;
		
		[Bindable]
		public var itemsDownloading:ArrayCollection;
		[Bindable]
		public var itemsOnDevice:ArrayCollection;
		[Bindable]
		public var itemsOnPc:ArrayCollection;
		[Bindable]
		public var itemsOnStore:ArrayCollection;
		
		[Bindable]
		public var retrievingStoreList:Boolean;
		[Bindable]
		public var retrievingDeviceList:Boolean;
		[Bindable]
		public var retrievingPcList:Boolean;
		
		public function DataController()
		{
			itemsDownloading = new ArrayCollection();
			itemsOnDevice = new ArrayCollection();
			itemsOnPc = new ArrayCollection();
			itemsOnStore = new ArrayCollection();
		}
		
		public static function get instance():DataController
		{
			if (mInstance == null)
			{
				mInstance = new DataController();
			}
			return mInstance;
		}
		
		public function getStoreProductList():void
		{
			this.retrievingStoreList = true;
		
			var service:HTTPService = new HTTPService();
			service.url = Constants.DOMAIN + "client/product/list";
			service.method = "POST";
			service.resultFormat = "text";
			service.addEventListener(ResultEvent.RESULT, storeResultListener);
			service.showBusyCursor = true;
			service.send(this);
		}
		
		private function storeResultListener(event:ResultEvent):void {
			var json:String = String(event.result);
			var obj:Object = JSON.parse(json);
			itemsOnStore.removeAll();
			for (var i:int=0; i<obj.products.length; i++) {
				var item:AppItem = new AppItem();
				item.name = obj.products[i].name;
				item.description = obj.products[i].content;
				item.type = AppItemType.STORE;
				item.iconUrl = "http://t3.gstatic.com/images?q=tbn:ANd9GcRZDfYRwCBKmbeC-_ONcbndgTrNnasQiXcjmyt6I9vOG_PJDdctBw8vBLA";
				itemsOnStore.addItem(item);
			}
			this.retrievingStoreList = false;
		}
		
		public function getDeviceProductList():void
		{
			this.retrievingDeviceList = true;
			var categoryNames:Array = ["aqxg", "jyrz1", "klxe", "qzgs", "slkx", "yeyy", "yyms", "zhwh", "zyyx"];
			CONFIG::ON_PC {
				for (var i:int=0; i<categoryNames.length; i++) {
					var categoryXmlFile:String = "C:\\book\\storyList_" + categoryNames[i] + ".xml";
					ExternalInterface.call("F2C_TRACE", "Xml File::" + categoryXmlFile);
					var xmlContent:String = ExternalInterface.call("F2C_getDeviceFileContent", categoryXmlFile);
					xmlContent = xmlContent.substr(xmlContent.indexOf("?>")+2);
					var xml:XML = new XML(xmlContent);
					for (var j:int=0; j<xml.story.length(); j++) {
						var app:AppItem = new AppItem();
						app.name = xml.story[j].name.toString();
						app.category = categoryNames[i];
						app.type = AppItemType.DEVICE;
						app.iconFile = "C:\\book\\" + xml.story[j].icon.toString().split('/').join('\\');
						app.iconBase64 = ExternalInterface.call("F2C_getDeviceIconBase64", app.iconFile);
						ExternalInterface.call("F2C_TRACE", app.iconFile);
						
						var entry:String = xml.story[j].entry.toString();
						app.folderName = entry.substr(0, entry.indexOf("/"));
						
						itemsOnDevice.addItem(app);
					}
				}
			}
			this.retrievingDeviceList = false;
		}
		
		public function getPcProductList():void
		{
			this.retrievingPcList = true;
			CONFIG::ON_PC {
				var namestr:String = ExternalInterface.call("F2C_getDownloadedAppNames", UIController.instance.downloadDirectory);
				if (namestr.length > 0) {
					var names:Array = namestr.split(",");
					for (var i:int=0; i<names.length; i++) {
						UIController.instance.addPcItem(names[i]);
					}
				}
			}
			this.retrievingPcList = false;
		}
	}
}