package classes
{
	import events.DeviceConnectionChangeEvent;
	
	import flash.events.Event;
	import flash.external.*;
	import flash.events.EventDispatcher;
	
	import flashx.textLayout.formats.Float;
	
	import mx.controls.Alert;

	[Bindable]
	public class DeviceDisk extends EventDispatcher
	{
		private var _total:int = 60;
		private var _used:int = 0;
		private var _connected:Boolean = false;
		
		public function DeviceDisk()
		{
		}
		
		[Bindable("volumeStatusChanged")]
		public function get volumeStatus():String
		{
			if (_connected)
				return "已用"+used+"M，还有"+(total-used)+"M可用空间";
			else
				return "您的设备未连接，可用空间未知";
		}
		
		[Bindable("volumeStatusChanged")]
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
				dispatchEvent(new Event("volumeStatusChanged"));
				
				var evt:DeviceConnectionChangeEvent = new DeviceConnectionChangeEvent();
				evt.connected = _connected;
				UIController.instance.dispatchEvent(evt);
			}
		}
		
		public function get used():int{ return _used; }
		public function set used(value:int):void
		{
			if (_used != value)
			{
				_used = value;
				dispatchEvent(new Event("volumeStatusChanged"));
			}
		}
		
		public function get total():int{ return _total; }
		public function set total(value:int):void
		{
			if (_total != value)
			{
				_total = value;
				dispatchEvent(new Event("volumeStatusChanged"));
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