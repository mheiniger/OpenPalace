package net.codecomposer.palace.model
{
	[Bindable]
	public class PalaceConfig
	{
		public function PalaceConfig()
		{
		}

		public static var webServiceURL:String = "http://www.openpalace.net/webservice";
		public static var directoryURL:String = "http://www.openpalace.net/webservice";
		public static var numberPropsToCacheInRAM:int = 1000; 
		public static var URIEncodeImageNames:Boolean = false;
		public static var fadeBackgroundImages:Boolean = true;
		public static var highlightHotspotsOnMouseover:Boolean = false;
	}
}