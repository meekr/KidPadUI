package classes
{
	import classes.UIController;
	
	public class Constants
	{
		private static var DOMAIN:String = "http://www.tongban1.com/";
		
		public static var LOGIN_URL:String = DOMAIN + "client/user/login";
		public static var PRODUCT_URL:String = DOMAIN + "client/product/list";
		public static var SIGNUP_URL:String = DOMAIN + "signup";
		public static var CHECK_UI_URL:String = DOMAIN + "client/ui.xml";
		public static var BUILT_INT_ZIP_URL:String = DOMAIN + "client/builtIn.zip";
		
		public static function getProductDetailUrl(id:int):String
		{
			return DOMAIN + "product/view/" + id;
		}
		
		public static function getNpkUrl(npkPath:String):String
		{
			return DOMAIN + npkPath + "?token=" + UIController.instance.user.token;
		}
		
		public static function getRealNpkLink(link:String):String
		{
			return DOMAIN + link;
		}
		
		public static function getThumbUrl(thumbPath:String):String
		{
			return DOMAIN + thumbPath;
		}
	}
}