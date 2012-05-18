package events
{
	import flash.events.Event;

	public class DeviceConnectionChangeEvent extends Event
	{
		public static var name:String = "deviceConnectionChange";
		public var connected:Boolean;
		
		public function DeviceConnectionChangeEvent()
		{
			super(name);
		}
	}
}