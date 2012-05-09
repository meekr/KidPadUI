package classes
{
	import classes.DownloadStatus;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	[Bindable]
	public class Download
	{
		public var appName:String;
		public var percentage:Number;
		public var status:String;
		public var url:String = "http://livedocs.adobe.com/flash/9.0/main/samples/Flash_ActionScript3.0_samples.zip";
		
		private var loader:URLLoader;
		
		public function Download()
		{
			percentage = 0;
			status = DownloadStatus.NOT_STARTED;
			
			loader = new URLLoader();
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
		}
	}
}