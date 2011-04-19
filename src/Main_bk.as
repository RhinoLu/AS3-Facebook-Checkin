package 
{
	import com.bit101.components.PushButton;
	import com.adobe.serialization.json.JSON;
	import com.facebook.graph.controls.Distractor;
	import com.facebook.graph.Facebook;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.LocalConnection;
	import flash.system.Capabilities;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Rhino Lu
	 */
	public class Main extends Sprite 
	{
		private const APP_ID:String = "212187482143493";
		private var clear_btn:PushButton;
		private var connect_btn:PushButton;
		private var checkin_btn:PushButton;
		private var fb_loading:Distractor;
		private var info_txt:TextField;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.HIGH;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			info_txt = new TextField();
			//info_txt.mouseEnabled = false;
			info_txt.multiline = true;
			info_txt.width = 800;
			info_txt.height = 600;
			addChild(info_txt);
			
			clear_btn = new PushButton(this, stage.stageWidth - 110, 10, "Clear", clearInfo);
			
			if (!((new LocalConnection().domain == "localhost") || Capabilities.playerType == "Desktop")) {
				info_txt.appendText("Facebook.init\n");
				Facebook.init(APP_ID, onInit);
			}
			addFBLoading();
		}
		
		private function onInit(result:Object, fail:Object):void
		{
			info_txt.appendText("onInit\n");
			if (result) {
				info_txt.appendText(t.obj(result));
				getUserData();
			} else {
				removeFBLoading();
				connect_btn = new PushButton(this, stage.stageWidth * 0.5, stage.stageHeight * 0.5, "Connect", popup);
			}
		}
		
		private function clearInfo(e:MouseEvent):void 
		{
			info_txt.text = "";
		}
		
		private function popup(e:MouseEvent):void 
		{
			connect_btn.mouseEnabled = false;
			
			//var opts:Object = { perms:"email" };
			var opts:Object = { perms:"user_checkins,publish_checkins" };
			Facebook.login(onLogin,opts);
			addFBLoading();
		}
		
		private function onLogin(result:Object, fail:Object):void
		{
			info_txt.appendText("onLogin\n");
			if (result) {
				info_txt.appendText(t.obj(result));
				removeChild(connect_btn);
				connect_btn = null;
				getUserData();
			} else {
				removeFBLoading();
				connect_btn.mouseEnabled = true;
			}
		}
		
		private function getUserData():void
		{
			info_txt.appendText("getUserData\n");
			Facebook.fqlQuery("SELECT uid,name,pic_big FROM user WHERE uid = me() ", onDataComplete);
			//Facebook.fqlQuery("SELECT coords,tagged_uids,author_uid,page_id,app_id,post_id,timestamp,message FROM checkin WHERE checkin_id = xxxxx ", onDataComplete);
		}
		
		private function onDataComplete(result:Object, fail:Object):void
		{
			removeFBLoading();
			
			if (result) {
				trace("========= onDataComplete ==========");
				//t.obj(result);
				info_txt.appendText(t.obj(result));
				trace("=========      end       ==========");
				//trace(result[0].uid);
				//trace(result[0].name);
				//trace(result[0].pic_big);
				//trace(result[0].email);
				//trace(result[0].likes);
				//_txt.text = result[0].uid + "," + result[0].name + "," + result[0].pic_big + "," + result[0].likes;
				//t.obj(result[0].likes);
				//fb_session = result[0] as FacebookSession;
				//t.obj(fb_session);
				//fb_uid = result[0].uid;
				//upload_btn = new PushButton(this, 200, 100, "upload", uploadPhoto);
				
				getUserCheckins();
				
				checkin_btn = new PushButton(this, stage.stageWidth * 0.5, stage.stageHeight * 0.5, "Check in", checkin);
			}
			if (fail) {
				//t.obj(fail);
				//_txt.text = "fail";
			}
		}
		
		private function getUserCheckins():void
		{
			info_txt.appendText("getUserCheckins\n");
			Facebook.api("me/checkins", onCheckinDataComplete);
			
			addFBLoading();
		}
		
		private function onCheckinDataComplete(result:Object, fail:Object):void
		{
			info_txt.appendText("onCheckinDataComplete\n");
			if (result) {
				trace("===== onCheckinDataComplete =======");
				//t.obj(result);
				info_txt.appendText(t.obj(result));
				trace("=========      end       ==========");
			}
			if (fail) {
				t.obj(fail);
			}
			
			removeFBLoading();
		}
		
		private function checkin(e:MouseEvent):void
		{
			checkin_btn.mouseEnabled = false;
			
			info_txt.appendText("checkin\n");
			var obj:Object = { };
			//obj.message = "測試";
			obj.place = "217291341621335"; // 
			obj.coordinates = JSON.encode({ "latitude":"25.014932", "longitude":"121.534498" }); // 經緯度
			//obj.tags = [uid1,uid2]; // 誰也在這裡
			info_txt.appendText(t.obj(obj));
			Facebook.api("me/checkins", onCheckinComplete, obj, "POST");
			
			addFBLoading();
		}
		
		private function onCheckinComplete(result:Object, fail:Object):void
		{
			info_txt.appendText("onCheckinComplete\n");
			checkin_btn.mouseEnabled = true;
			if (result) {
				trace("======= onCheckinComplete =========");
				//t.obj(result);
				info_txt.appendText(t.obj(result));
				trace("=========      end       ==========");
				getUserCheckins();
			}
			if (fail) {
				//t.obj(fail);
				info_txt.appendText(t.obj(fail));
			}
			
			removeFBLoading();
		}
		
		private function addFBLoading():void 
		{
			fb_loading = new Distractor();
			fb_loading.x = stage.stageWidth * 0.5;
			fb_loading.y = stage.stageHeight * 0.5 - 100;
			fb_loading.text = "connecting ...";
			addChild(fb_loading);
		}
		
		private function removeFBLoading():void 
		{
			if (fb_loading) {
				removeChild(fb_loading);
				fb_loading = null;
			}
		}
	}
	
}