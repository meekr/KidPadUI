package classes
{
	import flash.events.EventDispatcher;
	
	import mx.controls.Alert;

	[Bindable]
	public class DeviceDisk extends EventDispatcher
	{
		public var used:int = 15;
		public var total:int = 60;
		public var connected:Boolean = false;
		
		public function DeviceDisk()
		{
		}
		
		public function get volumeStatus():String
		{
			return "已用"+used+"M，还有"+(total-used)+"M可用空间";
		}
				
		public function getVisibleUsageWidth(totalWidth:int):int
		{
			return used * totalWidth / total;
		}
		
		public function get connectStatus():String
		{
			if (connected)
				return "设备已连接";
			else
				return "设备未连接";
		}
	}
}