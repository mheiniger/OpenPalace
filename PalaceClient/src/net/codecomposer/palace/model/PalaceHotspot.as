/*
This file is part of OpenPalace.

OpenPalace is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

OpenPalace is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with OpenPalace.  If not, see <http://www.gnu.org/licenses/>.
*/

package net.codecomposer.palace.model
{
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	
	import net.codecomposer.palace.event.HotspotEvent;
	import net.codecomposer.palace.iptscrae.IptEventHandler;
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	import net.codecomposer.palace.rpc.PalaceClient;
	
	import org.openpalace.iptscrae.IptTokenList;

	[Event(name="stateChanged",type="net.codecomposer.palace.event.HotspotEvent")]
	[Event(name="moved",type="net.codecomposer.palace.event.HotspotEvent")]

	[Bindable]
	public class PalaceHotspot extends EventDispatcher
	{
		
		public var type:int = 0;
		public var dest:int = 0;
		private var _id:int = 0;
		private var _flags:int = 0;
		public var state:int = 0;
		public var numStates:int = 0;
		public var polygon:Array = []; // Array of points
		private var _name:String = null;
		public var location:FlexPoint;
		public var scriptEventMask:int = 0;
		public var nbrScripts:int = 0;
		public var scriptString:String = "";
		public var scriptCursor:int = 0;
		private var ungetFlag:Boolean = false;
		private var gToken:String;
		public var secureInfo:int;
		public var refCon:int;
		public var groupId:int;
		public var scriptRecordOffset:int;
		public var states:ArrayCollection = new ArrayCollection();
		public var eventHandlers:Vector.<IptEventHandler> = new Vector.<IptEventHandler>();
		
		[Bindable('idChanged')]
		public function set id(newValue:int):void {
			if (_id != newValue) {
				_id = newValue;
				dispatchEvent(new Event('idChanged'));
			}
		}
		public function get id():int {
			return _id;
		}
		
		[Bindable('nameChanged')]
		public function set name(newValue:String):void {
			if (_name != newValue) {
				_name = newValue;
				dispatchEvent(new Event('nameChanged'));
			}
		}
		public function get name():String {
			return _name;
		}
		
		[Bindable('flagsChanged')]
		public function set flags(newValue:int):void {
			_flags = newValue;
			dispatchEvent(new Event('flagsChanged'));
		}
		public function get flags():int {
			return _flags;
		}
		
		public function get label():String {
			var string:String = "id " + id.toString() + ": ";
			string += (name) ? name : "(no name)";
//			trace(string);
			return string;
		}
		
		[Bindable('flagsChanged')]
		public function get showName():Boolean {
			return Boolean(flags & FLAG_SHOW_NAME);
		}
		
		[Bindable('flagsChanged')]
		public function get dontMoveHere():Boolean {
			return Boolean(flags & FLAG_DONT_MOVE_HERE);
		}
		
		[Bindable('flagsChanged')]
		public function get draggable():Boolean {
			return Boolean(flags & FLAG_DRAGGABLE);
		}
		
		[Bindable('flagsChanged')]
		public function get drawFrame():Boolean {
			return Boolean(flags & FLAG_DRAW_FRAME);
		}
		
		[Bindable('flagsChanged')]
		public function get shadow():Boolean {
			return Boolean(flags & FLAG_SHADOW);
		}
		
		[Bindable('flagsChanged')]
		public function get fill():Boolean {
			return Boolean(flags & FLAG_FILL);
		}
		
		[Bindable('flagsChanged')]
		public function get invisible():Boolean {
			return Boolean(flags & FLAG_INVISIBLE);
		}
		
		[Bindable('flagsChanged')]
		public function get layerAboveAll():Boolean {
			return draggable;
		}
		
		[Bindable('flagsChanged')]
		public function get layerAboveAvatars():Boolean {
			return invisible;
		}
		
		[Bindable('flagsChanged')]
		public function get layerAboveNameTags():Boolean {
			return fill;
		}
		
		[Bindable('flagsChanged')]
		public function get layerNormal():Boolean {
			return (!draggable && !invisible && !fill);
		}
		
		public static const TYPE_NORMAL:int = 0;
		public static const TYPE_PASSAGE:int = 1;
		public static const TYPE_SHUTABLE_DOOR:int = 2;
		public static const TYPE_LOCKABLE_DOOR:int = 3;
		public static const TYPE_BOLT:int = 4;
		public static const TYPE_NAVAREA:int = 5;
		
		public static const STATE_UNLOCKED:int = 0;
		public static const STATE_LOCKED:int = 1;
		
		public static const FLAG_SHOW_NAME:int = 0x08;
		public static const FLAG_DONT_MOVE_HERE:int = 0x02;
		public static const FLAG_DRAGGABLE:int = 0x01;
		public static const FLAG_INVISIBLE:int = 0x04;
		public static const FLAG_DRAW_FRAME:int = 0x10;
		public static const FLAG_SHADOW:int = 0x20;
		public static const FLAG_FILL:int = 0x40;
		
		
//		PicturesAboveAll        0x00000001        /* was "Draggable" */
//		DontMoveHere            0x00000002
//		PicturesAboveProps        0x00000004        /* was "Invisible" */
//		ShowName                0x00000008
//		ShowFrame                0x00000010
//		Shadow                    0x00000020
//		PicturesAboveNameTags    0x00000040        /* was "Fill" */
//		Forbidden                0x00000080        /* Linux 4.5.1 PServer */
//		Mandatory                0x00000100        /* Linux 4.5.1 PServer */
//		Landingpad                0x00000200        /* Linux 4.5.1 PServer */
		
		// Hotspot records are 48 bytes
		public const size:int = 48;
		
		public function PalaceHotspot()
		{
		}
		
		public function get isDoor():Boolean {
			return Boolean(type == TYPE_PASSAGE ||
						   type == TYPE_LOCKABLE_DOOR ||
						   type == TYPE_SHUTABLE_DOOR);
		}
		
		public function changeState(newState:int):void {
			var previousState:int = state;
			if (newState != state) {
				state = newState;
			}
			var event:HotspotEvent = new HotspotEvent(HotspotEvent.STATE_CHANGED);
			event.state = state;
			event.previousState = previousState;
			dispatchEvent(event);
		}
		
		public function movePicForState(stateId:int, x:int, y:int):void {
			try {
				if (stateId < 0) {
					stateId = this.state;
				}
				var stateObj:PalaceHotspotState = PalaceHotspotState(states.getItemAt(stateId));
				stateObj.x = x;
				stateObj.y = y;
				var event:HotspotEvent = new HotspotEvent(HotspotEvent.MOVED);
				dispatchEvent(event);
			}
			catch (e:Error) {
				// do nothing.
			}
		}
		
		public function movePicTo(x:int, y:int):void {
			movePicForState(this.state, x, y);
		}
		
		public function setStateOpacity(state:int, opacity:Number = 1):void {
			try {
				if (state < 0) {
					state = this.state;
				}
				var stateObj:PalaceHotspotState = PalaceHotspotState(states.getItemAt(state));
				if (stateObj) {
					stateObj.opacity = opacity;
					var event:HotspotEvent = new HotspotEvent(HotspotEvent.OPACITY_CHANGED);
					event.state = state;
					dispatchEvent(event);
				}
			}
			catch (e:Error) {
				// do nothing.
			}
		}
		
		public function moveTo(x:int, y:int):void {
			location.x = x;
			location.y = y;
			var event:HotspotEvent = new HotspotEvent(HotspotEvent.MOVED);
			dispatchEvent(event);
		}

		public function readData(endian:String, roomBytes:Array, offset:int):void {
//			trace("Hotspot offset " + offset);
			location = new FlexPoint();
			
			var ba:ByteArray = new ByteArray();
			for (var j:int=offset; j < offset+size+1; j++) {
				ba.writeByte(roomBytes[j]);
			}
			ba.position = 0;
			ba.endian = endian;
			
			scriptEventMask = ba.readInt();
			flags = ba.readInt();
//			trace("Hotspot Flags: 0x" + flags.toString(16));
			secureInfo = ba.readInt();
			refCon = ba.readInt();
			location.y = ba.readShort();
			location.x = ba.readShort();
//			trace("Location X: " + location.x + " - Location Y: " + location.y);
			id = ba.readShort();
			dest = ba.readShort();
			var numPoints:int = ba.readShort();
//			trace("Number points: " + numPoints);
			var pointsOffset:int = ba.readShort();
//			trace("Points offset: " + pointsOffset);
			type = ba.readShort();
			groupId = ba.readShort();
			nbrScripts = ba.readShort();
			scriptRecordOffset = ba.readShort();
			state = ba.readShort();
			numStates = ba.readShort();
			var stateRecordOffset:int = ba.readShort();
			var nameOffset:int = ba.readShort();
			var scriptTextOffset:int = ba.readShort();
			ba.readShort();
			if (nameOffset > 0) {
				var nameByteArray:ByteArray = new ByteArray();
				var nameLength:int = roomBytes[nameOffset];
				for (var a:int = nameOffset+1; a < nameOffset+nameLength+1; a++) {
					nameByteArray.writeByte(roomBytes[a]);
				}
				nameByteArray.position = 0;
				name = nameByteArray.readMultiByte(nameLength, 'Windows-1252');
			}
			else {
				name = "";
			}

			// Script...
			if (scriptTextOffset > 0) {
				var scriptByteArray:ByteArray = new ByteArray();
				
				var currentByte:int = -1;
				var counter:int = scriptTextOffset;
				var maxLength:int = roomBytes.length;
				var scriptChars:int = 0;
				while (currentByte != 0 && counter < maxLength) {
					scriptByteArray.writeByte(roomBytes[counter++]);
					scriptChars ++;
				}
				scriptByteArray.position = 0;
				scriptString = scriptByteArray.readMultiByte(scriptChars, 'Windows-1252');
			}
//			trace("Script: " + scriptString);
			loadScripts();

			ba = new ByteArray();
			var endPos:int = pointsOffset+(numPoints*4);
			for (j=pointsOffset; j < endPos+1; j++) {
				ba.writeByte(roomBytes[j]);
			}
			ba.position = 0;
			ba.endian = endian;
			
			// Get vertices
			var startX:int = 0;
			var startY:int = 0;
			for (var i:int = 0; i < numPoints; i++) {
				var y:int = ba.readShort();
				var x:int = ba.readShort();
				// trace("----- X: " + x + " (" + uint(x).toString(16) + ")    Y: " + y + "(" + uint(y).toString(16) +")");
				polygon.push(new Point(x, y));
			}
			
			// Get States
			states.removeAll();
			var stateOffset:int = stateRecordOffset;
			for (i=0; i < numStates; i++) {
				var state:PalaceHotspotState = new PalaceHotspotState();
				state.readData(endian, roomBytes, stateOffset);
				stateOffset += PalaceHotspotState.size;
				states.addItem(state);
			}
			
//			trace("Got new hotspot: " + this.id + " - DestID: " + dest + " - name: '" + this.name + "' - PointCount: " + numPoints);
		}
		
		public function hasEventHandler(eventType:int):Boolean {
			return (nbrScripts > 0 && (scriptEventMask & 1 << eventType) != 0);
		}
		
		public function getEventHandler(eventType:int):IptTokenList {
			if(nbrScripts > 0 && (scriptEventMask & 1 << eventType) != 0)
			{
				for(var i:int = 0; i < nbrScripts; i++)
				{
					var eventHandler:IptEventHandler = eventHandlers[i];
					if (eventHandler.eventType == eventType) {
						return eventHandler.tokenList;
					}
				}
				
			}
			return null;
		}

		public function loadScripts():void {
			nbrScripts = 0;
			scriptEventMask = 0;
			if(scriptString)
			{
//				trace("Hotspot " + id + " name: " + name + " script:\n" + scriptString);
				
				var manager:PalaceIptManager = PalaceClient.getInstance().palaceController.scriptManager;
				var foundHandlers:Object = manager.parseEventHandlers(scriptString);
				
				for (var eventName:String in foundHandlers) {
					var handler:IptTokenList = foundHandlers[eventName];
					var eventType:int = IptEventHandler.getEventType(eventName)
					var eventHandler:IptEventHandler =
						new IptEventHandler(eventType, handler.sourceScript, handler);
					eventHandlers.push(eventHandler);
//					trace("Got event handler.  Type: " + eventHandler.eventType + " Script: \n" + eventHandler.script);
					nbrScripts ++;
					scriptEventMask |= (1 << eventType);
				}
			}
		}

	}
}