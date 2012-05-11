package classes
{
	import classes.Constants;
	
	import events.*;
	
	import flash.events.EventDispatcher;
	
	import mx.controls.Alert;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	[Bindable]
	[Event(name="userLoggedIn", type="events.UserLoggedInEvent")]
	[Event(name="userFailedLogin", type="events.UserFailedLoginEvent")]
	public class User extends EventDispatcher
	{
		public var username:String = "NONE";
		public var password:String;
		public var state:String = "valid";
		public var token:String;
		
		public function User()
		{
		}
		
		public function login(name:String, password:String):void
		{
			this.username = name;
			this.password = password;
			var loginService:HTTPService = new HTTPService();
			loginService.url = Constants.DOMAIN + "client/user/login";
			loginService.method = "POST";
			loginService.resultFormat = "text";
			loginService.addEventListener(ResultEvent.RESULT, resultListener);
			loginService.showBusyCursor = true;
			loginService.send(this);
		}
		
		private function resultListener(event:ResultEvent):void {
			var json:String = String(event.result);
			var obj:Object = JSON.parse(json);
			this.state = obj.state;
			if (this.isLoggedIn) {
				this.token = obj.token;
				var ev:UserLoggedInEvent = new UserLoggedInEvent();
				this.dispatchEvent(new UserLoggedInEvent());
			}
			else {
				var ev2:UserFailedLoginEvent = new UserFailedLoginEvent();
				ev2.error = "invalid username or password";
				this.dispatchEvent(ev2);
			}
		}
		
		public function get isLoggedIn():Boolean
		{
			return (state == "valid");
		}
	}
}