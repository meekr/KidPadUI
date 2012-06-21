package classes
{
	import classes.Constants;
	import classes.Utils;
	
	import components.StorePage;
	
	import flash.events.EventDispatcher;
	import flash.external.*;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

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
		
		public var itemsOnDeviceHash:Object;
		
		private var _currentCategoryFilter:String;
		
		public function DataController()
		{
			itemsDownloading = new ArrayCollection();
			itemsOnDevice = new ArrayCollection();
			itemsOnPc = new ArrayCollection();
			itemsOnStore = new ArrayCollection();
			
			itemsOnDeviceHash = new Object();
		}
		
		public static function get instance():DataController
		{
			if (mInstance == null)
			{
				mInstance = new DataController();
			}
			return mInstance;
		}
		
		public function getStoreProductList(categoryId:int, page:int, sort:String, slug:String):void
		{
			this.retrievingStoreList = true;
		
			var params:Array = new Array();
			if (slug) {
				params.push("slug="+encodeURIComponent(slug));
			}
			else {
				if (categoryId)
					params.push("cid="+categoryId);
				if (sort)
					params.push("tab="+sort);
			}
			
			if (page)
				params.push("page="+page);
			var url:String = Constants.PRODUCT_URL + "?" + params.join("&");
			trace("STORE LIST URL: "+url);
			
			var service:HTTPService = new HTTPService();
			service.url = url;
			service.method = "POST";
			service.resultFormat = "text";
			service.addEventListener(ResultEvent.RESULT, storeResultListener);
			service.showBusyCursor = true;
			service.send(this);
		}
		
		private function storeResultListener(event:ResultEvent):void {
			var json:String = String(event.result);
			var obj:Object = JSON.parse(json);
			
			StorePage.totalPageCount = parseInt(obj.pagination.total);
			
			itemsOnStore.removeAll();
			for (var i:int=0; i<obj.products.length; i++) {
				var item:AppItem = new AppItem();
				item.id = obj.products[i].id;
				item.name = obj.products[i].name;
				item.description = obj.products[i].plain + "\n\n适合年龄：" + obj.products[i].age;
				item.type = AppItemType.STORE;
				item.npkUrl = Constants.getNpkUrl(obj.products[i].download_link);
				item.iconUrl = Constants.getThumbUrl(obj.products[i].thumbs.s);
				itemsOnStore.addItem(item);
				
				// sync status with device
				if (itemsOnDeviceHash[item.name])
					item.storeItemText = "已购买";
			}
			this.retrievingStoreList = false;
		}
		
		public function getDeviceProductListAll():void
		{
			if (!UIController.instance.deviceDisk.connected)
				return;
			
			itemsOnDeviceHash = new Object();
			
			this.retrievingDeviceList = true;
			
			var categoryNames:Array = ["jyrz1", "qzgs", "aqxg", "zhwh", "slkx", "yyms", "zyyx", "yeyy"];
			CONFIG::ON_PC {
				for (var i:int=0; i<categoryNames.length; i++) {
					var categoryXmlFile:String = UIController.instance.driveProgramName+"\\book\\storyList_"+categoryNames[i]+".xml";
					var xmlContent:String = ExternalInterface.call("F2C_getDeviceFileContent", categoryXmlFile);
					xmlContent = xmlContent.substr(xmlContent.indexOf("?>")+2);
					var xml:XML = new XML(xmlContent);
					Utils.log2c("Xml File:" + categoryXmlFile + " - has " + xml.story.length() + " stories");
					for (var j:int=0; j<xml.story.length(); j++) {
						var app:AppItem = new AppItem();
						app.name = xml.story[j].name.toString();
						app.category = categoryNames[i];
						app.type = AppItemType.DEVICE;
						app.iconFile = UIController.instance.driveProgramName+"\\book\\"+xml.story[j].icon.toString().split('/').join('\\');
						app.iconBase64 = ExternalInterface.call("F2C_getDeviceIconBase64", app.iconFile);
						
						var entry:String = xml.story[j].icon.toString();
						app.folderName = entry.substr(0, entry.lastIndexOf("/"));
						
						itemsOnDevice.addItem(app);
						
						itemsOnDeviceHash[app.name] = app;
					}
				}
			}
			this.retrievingDeviceList = false;
			itemsOnDevice.filterFunction = filterMyArrayCollection;
			itemsOnDevice.refresh();
			
			syncStoreAndLocalStatusWithDevice();
		}
		
		public function syncStoreAndLocalStatusWithDevice():void
		{
			var i:int;
			var app:AppItem;
			for (i=0; i<itemsOnStore.length; i++) {
				app = itemsOnStore[i] as AppItem;
				if (itemsOnDeviceHash[app.name])
					app.storeItemText = "已购买";
			}
			
			for (i=0; i<itemsOnPc.length; i++) {
				app = itemsOnPc[i] as AppItem;
				if (itemsOnDeviceHash[app.name]) {
					app.localItemText = "已安装";
					app.localItemEnabled = false;
				}
			}
		}
		
		private function filterMyArrayCollection(item:Object):Boolean
		{
			if (_currentCategoryFilter)
				return item.category == _currentCategoryFilter;
			return true;
		}
		
		public function getDeviceProductList(category:String):void
		{
			_currentCategoryFilter = category;
			itemsOnDevice.refresh();
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