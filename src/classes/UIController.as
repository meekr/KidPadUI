package classes
{
	import components.DevicePage;
	
	import events.DeviceConnectionChangeEvent;
	
	import flash.events.EventDispatcher;
	import flash.external.*;
	import flash.utils.*;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.http.HTTPService;
	
	import spark.components.List;
	
	[Event(name="deviceConnectionChange", type="events.DeviceConnectionChangeEvent")]
	public class UIController extends EventDispatcher
	{
		private static var mInstance:UIController;
		
		public var downloadDirectory:String;
		
		private var mDriveProgramName:String;
		
		[Bindable]
		public var user:User;
		[Bindable]
		public var deviceDisk:DeviceDisk;
		[Bindable]
		public var firmwareVersion:String = "0.9";
		
		public function UIController()
		{
			// setup communicate pipe
			CONFIG::ON_PC {
				ExternalInterface.addCallback("FL_setDownloadDirectory", FL_setDownloadDirectory);
				ExternalInterface.addCallback("FL_findNRDGameStoryAndAppRoot", FL_findNRDGameStoryAndAppRoot);
				ExternalInterface.addCallback("FL_setDeviceConnection", FL_setDeviceConnection);
				ExternalInterface.addCallback("FL_setDiskVolumnStatus", FL_setDiskVolumnStatus);
				
				firmwareVersion = ExternalInterface.call("F2C_getFirmwareVersion", "");
			}
			
			user = new User();
			deviceDisk = new DeviceDisk();
		}
		
		public static function get instance():UIController
		{
			if (mInstance == null)
				mInstance = new UIController();
			return mInstance;
		}
		
		public function get driveProgramName():String
		{
			return mDriveProgramName;
		}
		
		public function externalAddCallback(functionName:String, callback:Function):void
		{
			CONFIG::ON_PC {
				ExternalInterface.addCallback(functionName, callback);
			}
		}
		
		// methods invoke UI
		private function FL_setDownloadDirectory(args:String):void
		{
			downloadDirectory = args;
		}
		
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
		
		private function FL_setDeviceConnection(args:String):void
		{
			deviceDisk.connected = (args == "1");
			if (deviceDisk.connected)
				firmwareVersion = ExternalInterface.call("F2C_getFirmwareVersion", "");
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
			
			// sync status with device
			if (DataController.instance.itemsOnDeviceHash[app.name]) {
				app.localItemText = "已安装";
				app.localItemEnabled = false;
			}
		}
		
		public function removeAppOnPc(app:AppItem):void
		{
			var idx:int = DataController.instance.itemsOnPc.getItemIndex(app);
			if (idx > -1) {
				DataController.instance.itemsOnPc.removeItemAt(idx);
				CONFIG::ON_PC {
					ExternalInterface.call("F2C_deleteAppOnPc", app.name);
				}
			}
		}
		
		public function installApp(app:AppItem):void
		{
			CONFIG::ON_PC {
				var arg:String = this.downloadDirectory + app.name + ".npk";
				var ret:String = ExternalInterface.call("F2C_installApp", arg);
				if (ret.length > 0) {
					app.localItemText = "已安装";
					app.localItemEnabled = false;
					
					// insert item on device
					if (DataController.instance.itemsOnDevice.length > 0) {
						var ai:AppItem = app.clone4DeviceItem();
						ai.iconFile = UIController.instance.driveProgramName+"\\book\\"+app.folderName+"\\75_75.png";
						ai.iconBase64 = ExternalInterface.call("F2C_getDeviceIconBase64", ai.iconFile);
						ai.category = ret;
						
						DataController.instance.itemsOnDevice.addItemAt(ai, 0);
						DataController.instance.itemsOnDevice.refresh();
					}
				}
				else {
					app.localItemText = "同步";
					app.localItemEnabled = true;
				}
			}
		}
		
		public function addAppToDownload(app:AppItem):Boolean
		{
			for each(var d:Download in DataController.instance.itemsDownloading) {
				if (d.appName == app.name)
					return false;
			}
			
			var item:Download = new Download();
			item.appName = app.name;
			item.npkUrl = app.npkUrl;
			item.iconUrl = app.iconUrl;
			DataController.instance.itemsDownloading.addItem(item);
			//setTimeout(item.startDownload, 100);
			item.startDownload();
			return true;
		}
		
		public function deleteAppFromDevice(app:AppItem):Boolean
		{
			// appDirectoryPaths: appName,appDirectoryPath,appCategoryXmlFilePath
			CONFIG::ON_PC {
				// appDirectoryPaths: appName,appDirectoryPath,appCategoryXmlFilePath
				var xmlFile:String = mDriveProgramName+"\\book\\storyList_"+app.category+".xml";
				var path:String = mDriveProgramName+"\\book\\"+app.folderName.split("/").join("\\");
				var arg:String = app.name+","+path+","+xmlFile;
				Utils.log2c(arg);
				var ret:String = ExternalInterface.call("F2C_deleteAppOnDevice", arg);
				if (ret == "1") {
					var idx:int = DataController.instance.itemsOnDevice.getItemIndex(app);
					DataController.instance.itemsOnDevice.removeItemAt(idx);
					
					// sync items on PC
					for (var i:int=0; i<DataController.instance.itemsOnPc.length; i++) {
						var ai:AppItem = DataController.instance.itemsOnPc[i];
						if (ai.name == app.name) {
							ai.localItemText = "同步";
							ai.localItemEnabled = true;
							break;
						}
					}
				}
				else {
					app.deviceItemText = "从设备移除";
					app.deviceItemEnabled = true;
				}
			}
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
		
		public function completeDownload(item:Download):Boolean
		{
			var index:int = DataController.instance.itemsDownloading.getItemIndex(item);
			if (index > -1)
			{
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