package events
{
	import flash.events.Event;
	
	public class ChannelChangeEvent extends Event
	{
		public var oldChannelIndex:int = -1;
		public var newChannelIndex:int = -1;
		
		public function ChannelChangeEvent()
		{
			super("channelChange");
		}
	}
}