package classes
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import flashx.textLayout.formats.Float;
	
	import mx.controls.Alert;

	[Bindable]
	public class DeviceDisk extends EventDispatcher
	{
		public var used:int = 15;
		public var total:int = 60;
		private var _connected:Boolean = false;
		
		public function DeviceDisk()
		{
		}
		
		public function get volumeStatus():String
		{
			return "已用"+used+"M，还有"+(total-used)+"M可用空间";
		}
		
		public function get usage():Number
		{
			return used*100/total;
		}
				
		public function getVisibleUsageWidth(totalWidth:int):int
		{
			return used * totalWidth / total;
		}
		
		public function get connected():Boolean{ return _connected; }
		public function set connected(value:Boolean):void
		{
			if (_connected != value)
			{
				_connected = value;
				dispatchEvent(new Event("connectStatusChanged"));
			}
		}
		
		[Bindable("connectStatusChanged")]
		public function get connectStatus():String
		{
			if (connected)
				return "设备已连接";
			else
				return "设备未连接";
		}
	}
}