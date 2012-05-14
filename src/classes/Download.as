package classes
{
	import classes.DownloadStatus;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.external.*;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.utils.Base64Encoder;
	
	[Bindable]
	public class Download
	{
		public var appName:String;
		public var percentage:Number;
		public var status:String;
		public var npkUrl:String;
		public var iconUrl:String;
		
		private var npkLoader:URLLoader;
		private var pngLoader:URLLoader;
		
		public function Download()
		{
			percentage = 0;
			status = DownloadStatus.NOT_STARTED;
			
			npkLoader = new URLLoader();
			npkLoader.dataFormat = URLLoaderDataFormat.BINARY;
			npkLoader.addEventListener(Event.OPEN, npkOpenHandler);
			npkLoader.addEventListener(ProgressEvent.PROGRESS, npkProgressHandler);
			npkLoader.addEventListener(Event.COMPLETE, npkCompleteHandler);
			
			pngLoader = new URLLoader();
			pngLoader.dataFormat = URLLoaderDataFormat.BINARY;
			pngLoader.addEventListener(Event.COMPLETE, pngCompleteHandler);
		}
		
		public function startDownload():void
		{
			var request:URLRequest = new URLRequest();
			request.url = npkUrl;
			npkLoader.load(request);
			
			request.url = iconUrl;
			pngLoader.load(request);
		}
		
		public function pauseDownload():void
		{
			
		}
		
		public function resumeDownload():void
		{
			
		}
		
		public function cancelDownload():void
		{
			npkLoader.close();
			status = DownloadStatus.CANCELLED;
			
			CONFIG::ON_PC {
				ExternalInterface.call("F2C_cancelDownload", UIController.instance.downloadDirectory+appName);
			}
		}
		
		private function npkOpenHandler(event:Event):void
		{
			status = DownloadStatus.DOWNLOADING;
		}
		
		private function npkProgressHandler(event:ProgressEvent):void
		{
			status = DownloadStatus.DOWNLOADING;
			percentage = event.bytesLoaded*100 / event.bytesTotal;
			trace(event.bytesLoaded, event.bytesTotal, percentage);
		}
		
		private function npkCompleteHandler(event:Event):void
		{
			status = DownloadStatus.COMPLETED;
			percentage = 100;
			
			var buf:ByteArray = npkLoader.data;
			var base64Enc:Base64Encoder = new Base64Encoder();
			base64Enc.encodeBytes(buf, 0, buf.length);
			var str:String = base64Enc.toString();
			str = str.split("\n").join(""); 
			trace(str.length+": "+str.substr(0, 1000));
			CONFIG::ON_PC {
				ExternalInterface.call("F2C_saveFileFromBase64", UIController.instance.downloadDirectory+appName+".npk,"+str);
			}
			
			UIController.instance.deleteDownload(this);
			UIController.instance.addPcItem(appName);
		}
		
		private function pngCompleteHandler(event:Event):void
		{
			var buf:ByteArray = pngLoader.data;
			var base64Enc:Base64Encoder = new Base64Encoder();
			base64Enc.encodeBytes(buf, 0, buf.length);
			var str:String = base64Enc.toString();
			
			
			str = str.split("\n").join("");
			CONFIG::ON_PC {
				ExternalInterface.call("F2C_saveFileFromBase64", UIController.instance.downloadDirectory+appName+".png,"+str);
			}
			
			UIController.instance.deleteDownload(this);
		}
	}
}