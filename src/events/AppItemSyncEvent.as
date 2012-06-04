package events
{
	import flash.events.Event;

	public class AppItemSyncEvent extends Event
	{
		public static var name:String = "appItemSyncEvent";
		
		public function AppItemSyncEvent()
		{
			super(name);
		}
	}
}