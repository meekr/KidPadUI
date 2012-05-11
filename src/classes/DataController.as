package classes
{
	import classes.Constants;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	public class DataController
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
	}
}