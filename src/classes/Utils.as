package classes
{
	import flash.external.*;
	
	public class Utils
	{
		public static function log2c(message:String):void
		{
			CONFIG::ON_PC {
				ExternalInterface.call("F2C_TRACE", message);
			}
		}
	}
}