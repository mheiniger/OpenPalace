package net.codecomposer.palace.rpc.webservice
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	
	import net.codecomposer.palace.model.PalaceConfig;
	import net.codecomposer.palace.model.PalaceProp;
	import net.codecomposer.palace.rpc.PalaceClient;
	
	// OPWS = Open Palace Web Service
	public class OPWSGetProps extends EventDispatcher
	{
		private var _loader:URLLoader;
		
		private var _props:Array;
		
		private var client:PalaceClient = PalaceClient.getInstance();
		
		public function send(props:Array):void {
			var requestDefs:Array = [];
			for each (var prop:PalaceProp in props) {
				var requestDef:Object = {};
				if (prop.asset.guid) {
					requestDef['id'] = prop.asset.guid;
				}
				else {
					requestDef['id'] = prop.asset.id;
					/*requestDef['legacy_identifier'] = {
						id: prop.asset.id,
						crc: prop.asset.crc,
						originating_palace: client.host + ":" + client.port
					}*/
				}
				requestDefs.push(requestDef);
			}
			var request:URLRequest = new URLRequest(client.mediaServer.replace(/\/$/, "") + "/webservice/props/get/");
			request.contentType = 'application/json';
			request.method = URLRequestMethod.POST;
			request.requestHeaders = [
				new URLRequestHeader('Accept', 'application/json'),
				new URLRequestHeader('Content-Encoding', 'deflate')
			];
				
			var compressedData:ByteArray = new ByteArray();
			compressedData.writeUTFBytes(
				JSON.encode({
					api_version: 1,
					//api_key: OPWSParameters.API_KEY,
					props: requestDefs
				})
			);
			compressedData.compress(CompressionAlgorithm.ZLIB);
			
			request.data = compressedData;

			_loader = new URLLoader();
			_loader.dataFormat = URLLoaderDataFormat.TEXT;
			_loader.addEventListener(Event.COMPLETE, handleComplete);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSecurityError);
			_loader.load(request);
		}
		
		private function handleIOError(event:IOErrorEvent):void {
			dispatchEvent(new OPWSEvent(OPWSEvent.FAULT_EVENT));			
		}
		
		private function handleSecurityError(event:SecurityErrorEvent):void {
			dispatchEvent(new OPWSEvent(OPWSEvent.FAULT_EVENT));			
		}
		
		private function handleComplete(event:Event):void {
			var e:OPWSEvent = new OPWSEvent(OPWSEvent.RESULT_EVENT);
			try {
				e.result = JSON.decode(String(_loader.data));
			}
			catch(error:Error) {
				throw new Error("Unable to decode JSON response: " + error.name + ":\n" + error.message);
			}
			dispatchEvent(e);
		}
	}
}