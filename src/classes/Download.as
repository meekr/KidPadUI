package classes
{
	import classes.DownloadStatus;
	
	[Bindable]
	public class Download
	{
		public var appName:String;
		public var percentage:Number;
		public var status:String;
		
		public function Download()
		{
			percentage = 0;
			status = DownloadStatus.NOT_STARTED;
		}
	}
}