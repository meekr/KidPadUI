package classes
{
	[Bindable]
	public class User
	{
		public var name:String;
		public var password:String;
		
		public function User()
		{
		}
		
		public function get isLoggedIn():Boolean
		{
			return (name != "" && password != "");
		}
	}
}