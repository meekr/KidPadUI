package classes
{
	import flash.external.*;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.http.HTTPService;
	
	import spark.components.List;
	
	
	public class UIController
	{
		private static var mInstance:UIController;
		
		public var downloadDirectory:String = "C:\\KidPadDirectory\\";
		
		private var mDriveProgramName:String;
		
		[Bindable]
		public var user:User;
		[Bindable]
		public var deviceDisk:DeviceDisk;
		
		public function UIController()
		{
			// setup communicate pipe
			CONFIG::ON_PC {
				ExternalInterface.addCallback("FL_findNRDGameStoryAndAppRoot", FL_findNRDGameStoryAndAppRoot);
				ExternalInterface.addCallback("FL_setDiskVolumnStatus", FL_setDiskVolumnStatus);
			}
			
			user = new User();
			deviceDisk = new DeviceDisk();
			
			for (var i:int=40; i<70; i++) {
				var app:AppItem = new AppItem();
				app.name = "我的应用-"+(i+1);
				app.description = "撒旦法为二位为切尔dffs sdsds\nsdsssssseee eee\n去玩儿阿斯顿法师打发玩儿去玩儿";
				app.type = AppItemType.DEVICE;
				app.iconUrl = "http://t3.gstatic.com/images?q=tbn:ANd9GcRZDfYRwCBKmbeC-_ONcbndgTrNnasQiXcjmyt6I9vOG_PJDdctBw8vBLA";
				//itemsOnDevice.addItem(app);
			}
		}
		
		public static function get instance():UIController
		{
			if (mInstance == null)
				mInstance = new UIController();
			return mInstance;
		}
		
		public function externalAddCallback(functionName:String, callback:Function):void
		{
			CONFIG::ON_PC {
				ExternalInterface.addCallback(functionName, callback);
			}
		}
		
		// methods invoke UI
		private function FL_findNRDGameStoryAndAppRoot(args:String):void
		{
			mDriveProgramName = args;
		}
		
		private function FL_setDiskVolumnStatus(args:String):void
		{
			var free:int = int(args.split(",")[0]);
			var total:int = int(args.split(",")[1]);
			UIController.instance.deviceDisk.used = total - free;
			UIController.instance.deviceDisk.total = total;
		}
		
		public function addPcItem(appName:String):void
		{
			for each(var item:AppItem in DataController.instance.itemsOnPc) {
				if (item.name == appName)
					return;
			}
			
			var app:AppItem = new AppItem();
			app.name = appName;
			app.type = AppItemType.PC;
			app.iconUrl = this.downloadDirectory + appName + ".png";
			DataController.instance.itemsOnPc.addItem(app);
		}
		
		public function removeAppOnDevice(app:AppItem):void
		{
			CONFIG::ON_PC {
				// appDirectoryPaths: appName,appDirectoryPath,appCategoryXmlFilePath
				var xmlFile:String = "C:\\book\\storyList_" + app.category + ".xml";
				var path:String = "C:\\book\\" + app.folderName;
				var arg:String = app.name+","+path+","+xmlFile;
				var ret:String = ExternalInterface.call("F2C_deleteAppOnDevice", arg);
				if (ret == "1")
					DataController.instance.itemsOnDevice.removeItemAt(DataController.instance.itemsOnDevice.getItemIndex(app));
			}
		}
		
		public function removeAppOnPc(app:AppItem):void
		{
			DataController.instance.itemsOnPc.removeItemAt(DataController.instance.itemsOnPc.getItemIndex(app));
		}
		
		public function installApp(app:AppItem):void
		{
			CONFIG::ON_PC {
				var arg:String = this.downloadDirectory + app.name + ".npk";
				var ret:String = ExternalInterface.call("F2C_installApp", arg);
				if (ret == "1") {
					// TODO: update category, iconFile, etc.
					DataController.instance.itemsOnDevice.addItemAt(app, 0);
				}
			}
		}
		
		public function addAppToDownload(app:AppItem):Boolean
		{
			for each(var d:Download in DataController.instance.itemsDownloading) {
				if (d.appName == app.name)
					return false;
			}
			
			//var urls:Array = ["http://livedocs.adobe.com/flash/9.0/main/samples/Flash_Lite_1x.zip",
			//	"http://download.macromedia.com/pub/developer/flash/Flash_Lite_4.zip"];
			var urls:Array = ["004_motionTweenBMP", "007_shapeTween", "dragDrop", "FileBrowser", "stamper", "tellMeYourWishes", "wouldTheyLoveALion"];
			var url:String = urls[int(Math.random()*urls.length)];
			var item:Download = new Download();
			item.appName = app.name;
			item.npkUrl = "http://192.168.1.4/kidpad/npk/" + url + ".npk";
			item.iconUrl = "http://192.168.1.4/kidpad/npk/" + url + ".png";
			trace(item.npkUrl);
			DataController.instance.itemsDownloading.addItem(item);
			item.startDownload();
			return true;
		}
		
		public function deleteAppFromDevice(app:AppItem):Boolean
		{
			return true;
		}
		
		public function deleteDownload(item:Download):Boolean
		{
			var index:int = DataController.instance.itemsDownloading.getItemIndex(item);
			if (index > -1)
			{
				item.cancelDownload();
				DataController.instance.itemsDownloading.removeItemAt(index);
				return true;
			}
			return false;
		}
		
		public function pauseDownload(item:Download):void
		{
			var index:int = DataController.instance.itemsDownloading.getItemIndex(item);
			if (index > -1)
			{
				item.pauseDownload();
			}
		}
		
		public function resumeDownload(item:Download):void
		{
			var index:int = DataController.instance.itemsDownloading.getItemIndex(item);
			if (index > -1)
			{
				item.resumeDownload();
			}
		}
	}
}