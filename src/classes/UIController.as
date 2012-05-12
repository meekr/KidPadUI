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
		
		public var localPcPath:String = "D:\\KidPadDirectory";
		
		private var mDriveProgramName:String;
		private var mCategoryXmlPaths:Dictionary = new Dictionary();
		
		[Bindable]
		public var user:User;
		
		[Bindable]
		public var deviceDisk:DeviceDisk;
		
		[Bindable]
		public var appsOnDevice:ArrayCollection;
		[Bindable]
		public var appsOnPc:ArrayCollection;
		
		[Bindable]
		public var itemsOnDevice:ArrayCollection;
		[Bindable]
		public var itemsOnPc:ArrayCollection;
		
		public function UIController()
		{
			// setup communicate pipe
			CONFIG::ON_PC {
				ExternalInterface.addCallback("FL_findNRDGameStoryAndAppRoot", FL_findNRDGameStoryAndAppRoot);
				ExternalInterface.addCallback("FL_setDiskVolumnStatus", FL_setDiskVolumnStatus);
			}
			
			user = new User();
			deviceDisk = new DeviceDisk();
			
			itemsOnDevice = new ArrayCollection();
			itemsOnPc = new ArrayCollection();
			
			for (var i:int=0; i<20; i++) {
				var app:AppItem = new AppItem();
				app.name = "三只小猪-"+(i+1);
				app.description = "撒旦法为二位为切尔去玩儿阿斯顿法师打发玩儿去玩儿";
				app.type = AppItemType.PC;
				app.iconUrl = "http://t3.gstatic.com/images?q=tbn:ANd9GcRZDfYRwCBKmbeC-_ONcbndgTrNnasQiXcjmyt6I9vOG_PJDdctBw8vBLA";
				itemsOnPc.addItem(app);
			}
			
			for (i=40; i<70; i++) {
				app = new AppItem();
				app.name = "我的应用-"+(i+1);
				app.description = "撒旦法为二位为切尔dffs sdsds\nsdsssssseee eee\n去玩儿阿斯顿法师打发玩儿去玩儿";
				app.type = AppItemType.DEVICE;
				app.iconUrl = "http://t3.gstatic.com/images?q=tbn:ANd9GcRZDfYRwCBKmbeC-_ONcbndgTrNnasQiXcjmyt6I9vOG_PJDdctBw8vBLA";
				itemsOnDevice.addItem(app);
			}
		}
		
		public static function get instance():UIController
		{
			if (mInstance == null)
			{
				mInstance = new UIController();
			}
			return mInstance;
		}
		
		// methods invoke UI
		private function FL_findNRDGameStoryAndAppRoot(args:String):void
		{
			mDriveProgramName = args;
			mCategoryXmlPaths["game"] = mDriveProgramName + "\\game\\gameList.xml";
			mCategoryXmlPaths["story"] = mDriveProgramName + "\\story\\storyList.xml";
			mCategoryXmlPaths["app"] = mDriveProgramName + "\\installed\\appList.xml";
		}
		
		private function FL_setDiskVolumnStatus(args:String):void
		{
			var free:int = int(args.split(",")[0]);
			var total:int = int(args.split(",")[1]);
			UIController.instance.deviceDisk.used = total - free;
			UIController.instance.deviceDisk.total = total;
		}
		
		public function updateAppListOnPc():void
		{
			appsOnPc = new ArrayCollection();
			CONFIG::ON_PC {
				var pngstr:String = ExternalInterface.call("F2C_getLocalFileNames", UIController.instance.localPcPath);
				var pngs:Array = pngstr.split(",");
				for (var i:int=0; i<pngs.length; i++) {
					var app:AppItem = new AppItem();
					app.name = pngs[i];
					app.iconFile = UIController.instance.localPcPath + "\\" + pngs[i] + ".png";
					app.iconBase64 = ExternalInterface.call("F2C_getLocalIconBase64", app.iconFile);
					appsOnPc.addItem(app);
				}
			}
		}
		
		public function updateAppListOnDevice():void
		{
			appsOnDevice = new ArrayCollection();
			CONFIG::ON_PC {
				for (var category:String in mCategoryXmlPaths) {
					var xmlContent:String = ExternalInterface.call("F2C_getDeviceFileContent", mCategoryXmlPaths[category]);
					var xml:XML = new XML(xmlContent.substr(xmlContent.indexOf("<")));
					for (var i:int=0; i<xml[category].length(); i++) {
						var app:AppItem = new AppItem();
						app.name = xml[category][i].name.toString();
						app.category = category;
						app.iconFile = mDriveProgramName + "\\" + xml[category][i].deployType + "\\" + xml[category][i].icon.toString().replace('/', "\\");
						app.iconBase64 = ExternalInterface.call("F2C_getDeviceIconBase64", app.iconFile);
						appsOnDevice.addItem(app);
					}
				}
			}
		}
		
		public function removeAppOnDevice(app:AppItem):void
		{
			CONFIG::ON_PC {
				// appDirectoryPaths: appName,appDirectoryPath,appCategoryXmlFilePath
				var xmlFile:String = mCategoryXmlPaths[app.category];
				var path:String = xmlFile.substr(0, xmlFile.lastIndexOf("\\")+1) + app.name;
				var arg:String = app.name+","+path+","+xmlFile;
				var ret:String = ExternalInterface.call("F2C_deleteAppOnDevice", arg);
				if (ret == "1")
					appsOnDevice.removeItemAt(appsOnDevice.getItemIndex(app));
			}
		}
		
		public function removeAppOnPc(app:AppItem):void
		{
			appsOnPc.removeItemAt(appsOnPc.getItemIndex(app));
		}
		
		public function installApp(app:AppItem):void
		{
			CONFIG::ON_PC {
				var arg:String = UIController.instance.localPcPath + "\\" + app.name + ".npk";
				var ret:String = ExternalInterface.call("F2C_installApp", arg);
				if (ret == "1") {
					// TODO: update category, iconFile, etc.
					appsOnDevice.addItemAt(app, 0);
				}
			}
		}
		
		public function addAppToDownload(app:AppItem):Boolean
		{
			for each(var d:Download in DataController.instance.itemsDownloading) {
				if (d.appName == app.name)
					return false;
			}
			
			var urls:Array = ["http://livedocs.adobe.com/flash/9.0/main/samples/Flash_Lite_1x.zip",
				"http://download.macromedia.com/pub/developer/flash/Flash_Lite_4.zip"];
			var item:Download = new Download();
			item.appName = app.name;
			item.url = urls[int(Math.random()*urls.length)];
			trace(item.url);
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