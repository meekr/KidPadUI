package classes
{
	import classes.Constants;
	
	import mx.controls.Alert;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	[Bindable]
	public class User
	{
		public var username:String = "NONE";
		public var password:String;
		public var token:String;
		
		public var loggedIn:Boolean;
		
		public function User()
		{
		}
		
		public function login(name:String, password:String):void
		{
			this.username = name;
			this.password = password;
			var loginService:HTTPService = new HTTPService();
			loginService.url = Constants.LOGIN_URL;
			loginService.method = "POST";
			loginService.resultFormat = "text";
			loginService.addEventListener(ResultEvent.RESULT, resultListener);
			loginService.showBusyCursor = true;
			loginService.send(this);
		}
		
		private function resultListener(event:ResultEvent):void {
			var json:String = String(event.result);
			var obj:Object = JSON.parse(json);
			if (obj.state == "valid") {
				this.loggedIn = true;
				this.token = obj.data.token;
			}
			else {
				this.loggedIn = false;
			}
		}
	}
}