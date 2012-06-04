package events
{
	import flash.events.Event;

	public class AppItemDeleteEvent extends Event
	{
		public static var name:String = "appItemDeleteEvent";
		
		public function AppItemDeleteEvent()
		{
			super(name);
		}
	}
}