package classes
{
	import classes.UIController;
	
	public class Constants
	{
		private static var DOMAIN:String = "http://223.4.2.218/";
		
		public static var LOGIN_URL:String = DOMAIN + "client/user/login";
		public static var PRODUCT_URL:String = DOMAIN + "client/product/list";
		
		public static function getProductDetailUrl(id:int):String
		{
			return DOMAIN + "product/view/" + id;
		}
		
		public static function getNpkUrl(npkPath:String):String
		{
			return DOMAIN + npkPath + "?token=" + UIController.instance.user.token;
		}
		
		public static function getThumbUrl(thumbPath:String):String
		{
			return DOMAIN + thumbPath;
		}
	}
}