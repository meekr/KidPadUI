package events
{
	import flash.events.Event;
	
	
	public class UserLoggedInEvent extends Event
	{
		public function UserLoggedInEvent()
		{
			super("userLoggedIn");
		}
	}
}