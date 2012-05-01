package events
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class DeviceSyncEvent extends Event
	{
		public var appItems:ArrayCollection;
		
		public function DeviceSyncEvent()
		{
			super("deviceSync");
		}
	}
}