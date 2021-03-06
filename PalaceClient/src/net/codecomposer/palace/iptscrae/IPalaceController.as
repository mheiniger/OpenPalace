package net.codecomposer.palace.iptscrae
{
	import net.codecomposer.palace.model.PalaceHotspot;
	
	import org.openpalace.iptscrae.IptTokenList;

	public interface IPalaceController
	{
		function logError(message:String):void;
		function gotoURL(url:String):void;
		function launchApp(app:String):void;
		function getWhoChat():int;
		function midiLoop(loopNbr:int, name:String):void;
		function midiPlay(name:String):void;
		function selectHotSpot(spotId:int):void;
		function getNumDoors():int;
		function isGuest():Boolean;
		function dimRoom(dimLevel:int):void;
		function getSelfPosY():int;
		function getSelfPosX():int;
		function isWizard():Boolean;
		function moveUserAbs(x:int, y:int):void;
		function getTopProp():int;
		function dropProp(x:int, y:int):void;
		function doffProp():void;
		function doffPropById(propId:int):void;
		function doffPropByName(propName:String):void;
		function naked():void;
		function getUserProp(index:int):int;
		function getMouseX():int;
		function getMouseY():int;
		function moveUserRel(xBy:int, yBy:int):void;
		function getSpotState(spotId:int):int;
		function chat(text:String):void;
		function clearAlarms():void;
		function getDoorIdByIndex(index:int):int;
		function setSpotStateLocal(spotId:int, state:int):void;
		function getWhoTarget():int;
		function beep():void;
		function getSpotDest(spotId:int):int;
		function doMacro(macro:int):void;
		function changeColor(colorNumber:int):void;
		function getSpotName(spotId:int):String;
		function getUserName(userId:int):String;
		function getSelfUserName():String;
		function getNumRoomUsers():int;
		function getSelfUserId():int;
		function lock(spotId:int):void;
		function midiStop():void;
		function gotoRoom(roomId:int):void;
		function inSpot(spotId:int):Boolean;
		function sendGlobalMessage(message:String):void;
		function sendRoomMessage(message:String):void;
		function sendSusrMessage(message:String):void;
		function sendLocalMsg(message:String):void;
		function donPropById(propId:int):void;
		function donPropByName(propName:String):void;
		function setProps(propIds:Array):void;
		function hasPropById(propId:int):Boolean;
		function hasPropByName(propName:String):Boolean;
		function getRoomName():String;
		function getServerName():String;
		function isLocked(spotId:int):Boolean;
		function setSpotState(spotId:int, state:int):void;
		function isGod():Boolean;
		function getNumUserProps():int;
		function statusMessage(message:String):void;
		function playSound(soundName:String):void;
		function getPosX(userId:int):int;
		function getPosY(userId:int):int;
		function setPicOffset(spotId:int, x:int, y:int):void;
		function killUser(userId:int):void;
		function getSpotIdByIndex(spotIndex:int):int;
		function setChatString(message:String):void;
		function getNumSpots():int;
		function unlock(spotId:int):void;
		function setFace(faceId:int):void;
		function logMessage(message:String):void;
		function sendPrivateMessage(message:String, userId:int):void;
		function getPropIdByName(propName:String):int;
		function addLooseProp(propId:int, x:int, y:int):void;
		function removeLooseProp(propIndex:int):void;
		function showLooseProps():void;
		function getUserByName(userName:String):int;
		function getRoomId():int;
		function setScriptAlarm(tokenList:IptTokenList, spotId:int, futureTime:int):void;
		function moveSpot(spotId:int, xBy:int, yBy:int):void;
		function getRoomUserIdByIndex(userIndex:int):int;
		function getChatString():String;
		function setSpotAlarm(spotId:int, futureTime:int):void;
		function triggerHotspotEvent(hotspot:PalaceHotspot, eventType:int):Boolean;
	}
}