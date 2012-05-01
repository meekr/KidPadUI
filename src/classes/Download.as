package classes
{
	[Bindable]
	public class Download
	{
		public var appName:String;
		public var percentage:Number;
		public var status:DownloadStatus;
		
		public function Download()
		{
			percentage = 0;
			status = DownloadStatus.NOT_STARTED;
		}
	}
	
	public final class DownloadStatus
	{
		public static const NOT_STARTED:String = "NOT_STARTED";
		public static const DOWNLOADING:String = "DOWNLOADING";
		public static const COMPLETED:String = "COMPLETED";
		public static const CANCELLED:String = "CANCELLED";
	}
}