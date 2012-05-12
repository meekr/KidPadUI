package classes
{
	import classes.DownloadStatus;
	
	import flash.external.*;
	import flash.events.Event;
	import flash.events.ProgressEvent;
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
		public var url:String;
		
		private var loader:URLLoader;
		
		public function Download()
		{
			percentage = 0;
			status = DownloadStatus.NOT_STARTED;
			
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.OPEN, openHandler);
			loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			loader.addEventListener(Event.COMPLETE, completeHandler);
		}
		
		public function startDownload():void
		{
			var request:URLRequest = new URLRequest();
			request.url = url;
			loader.load(request);
		}
		
		public function pauseDownload():void
		{
			
		}
		
		public function resumeDownload():void
		{
			
		}
		
		public function cancelDownload():void
		{
			loader.close();
			status = DownloadStatus.CANCELLED;
		}
		
		private function openHandler(event:Event):void
		{
			status = DownloadStatus.DOWNLOADING;
		}
		
		private function progressHandler(event:ProgressEvent):void
		{
			status = DownloadStatus.DOWNLOADING;
			percentage = event.bytesLoaded*100 / event.bytesTotal;
			trace(event.bytesLoaded, event.bytesTotal, percentage);
		}
		
		private function completeHandler(event:Event):void
		{
			status = DownloadStatus.COMPLETED;
			percentage = 100;
			
			var buf:ByteArray = loader.data;
			var base64Enc:Base64Encoder = new Base64Encoder();
			base64Enc.encodeBytes(loader.data, 0, buf.length);
			var str:String = base64Enc.toString();
			CONFIG::ON_PC {
				ExternalInterface.call("F2C_saveNpkFromBase64", appName+","+str);
			}
			
			UIController.instance.deleteDownload(this);
		}
	}
}