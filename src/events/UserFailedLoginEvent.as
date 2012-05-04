package events
{
	import flash.events.Event;

	public class UserFailedLoginEvent extends Event
	{
		public var error:String;
		
		public function UserFailedLoginEvent()
		{
			super("userFailedLogin");
		}
	}
}