package 
{
	import com.adobe.serialization.json.JSON;
	import com.bit101.components.PushButton;
	import com.bit101.components.Style;
	import com.facebook.graph.controls.Distractor;
	import com.facebook.graph.data.FacebookAuthResponse;
	import com.facebook.graph.Facebook;
	import com.google.maps.controls.ZoomControl;
	import com.google.maps.interfaces.IControl;
	import com.google.maps.LatLng;
	import com.google.maps.Map;
	import com.google.maps.MapEvent;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.MapMoveEvent;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.MarkerOptions;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.LocalConnection;
	import flash.system.Capabilities;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class Main extends Sprite 
	{
		private const APP_ID:String = "212187482143493"; // your Facebook APP ID
		private const MAP_KEY:String = "ABQIAAAAqMSM8xFmOPGb-4dBPY1IJhRjSOXmjpaW1w5P4B34l-76fx9uexTdhVHfpZZnA8IsDDIIlNuwvSEvYQ"; // Google Map Key
		private var default_lat:Number = 25.014932;
		private var default_lng:Number = 121.534498;
		private var clear_btn:PushButton;
		private var connect_btn:PushButton;
		private var fb_loading:Distractor;
		private var info_txt:TextField;
		private var map:Map;
		private var _lat:Number;
		private var _lng:Number;
		private var checkin_obj:Object;
		
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
			stage.stageFocusRect = false;
			
			info_txt = new TextField();
			info_txt.multiline = true;
			info_txt.width = stage.stageWidth;
			info_txt.height = 100;
			info_txt.background = true;
			addChild(info_txt);
			
			Style.fontSize = 12;
			Style.embedFonts = false;
			Style.fontName = "Arial";
			
			clear_btn    = new PushButton(this, stage.stageWidth - 110, 10, "Clear", clearInfo);
			
			if (!((new LocalConnection().domain == "localhost") || Capabilities.playerType == "Desktop")) {
				info_txt.appendText("Facebook.init\n");
				Facebook.init(APP_ID, onInit);
			}
			addFBLoading();
			
			checkin_obj = { };
		}
		
		private function onInit(result:Object, fail:Object):void
		{
			info_txt.appendText("onInit\n");
			if (result) {
				info_txt.appendText(t.obj(result));
				var far:FacebookAuthResponse = result as FacebookAuthResponse;
				if (far == null || far.uid == null) {
					// not login yet
				}else {
					// already login
					initMap();
					return;
				}
			}
			removeFBLoading();
			connect_btn = new PushButton(this, stage.stageWidth * 0.5, stage.stageHeight * 0.5, "Connect", popup);
		}
		
		private function clearInfo(e:MouseEvent):void 
		{
			info_txt.text = "";
		}
		
		private function popup(e:MouseEvent):void 
		{
			connect_btn.mouseEnabled = false;
			
			var opts:Object = { scope:"user_checkins,publish_checkins" };
			Facebook.login(onLogin,opts);
			addFBLoading();
		}
		
		private function onLogin(result:Object, fail:Object):void
		{
			info_txt.appendText("onLogin\n");
			if (result) {
				// login successed
				info_txt.appendText(t.obj(result));
				removeChild(connect_btn);
				connect_btn = null;
				initMap();
			} else {
				// login fail
				removeFBLoading();
				connect_btn.mouseEnabled = true;
			}
		}
		
		// Get Data **********************************************************************************************************************************
		private function getUserData():void
		{
			info_txt.appendText("getUserData\n");
			Facebook.fqlQuery("SELECT uid,name,pic_big FROM user WHERE uid = me() ", onDataComplete);
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
				
				//checkin_btn.mouseEnabled = true;
			}
			if (fail) {
				//t.obj(fail);
				//_txt.text = "fail";
			}
		}
		
		// Get Checkin **********************************************************************************************************************************
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
				
				
				//putPlaceToComboBox(result as Array);
				trace("=========      end       ==========");
			}
			if (fail) {
				t.obj(fail);
			}
			
			removeFBLoading();
		}
		
		/*private function putPlaceToComboBox(_array:Array):void
		{
			place_cb.removeAll();
			var i:uint;
			var len:uint = _array.length;
			var place_obj:Object;
			for (i = 0; i < len; i++) {
				place_obj = _array[i];
				place_obj.label = place_obj.name;
				place_cb.addItem(place_obj);
			}
		}*/
		
		// Checkin **********************************************************************************************************************************
		private function checkin(e:MouseEvent = null):void
		{
			//checkin_btn.mouseEnabled = false;
			
			info_txt.appendText("checkin\n");
			var obj:Object = { };
			obj.place = checkin_obj.id; // 
			obj.coordinates = JSON.encode({ "latitude":checkin_obj.lat, "longitude":checkin_obj.lng }); // location
			//obj.tags = [uid1,uid2]; // with who
			//info_txt.appendText(t.obj(obj));
			Facebook.api("me/checkins", onCheckinComplete, obj, "POST");
			
			addFBLoading();
		}
		
		private function onCheckinComplete(result:Object, fail:Object):void
		{
			info_txt.appendText("onCheckinComplete\n");
			//checkin_btn.mouseEnabled = true;
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
		
		// Get Place **********************************************************************************************************************************
		private function getPlace(e:MouseEvent = null):void
		{
			info_txt.appendText("getPlace\n");
			var obj:Object = { };
			//obj.q = "pizza";
			obj.type = "place";
			//obj.center = default_lat + "," + default_lng;
			obj.center = map.getCenter().lat() + "," + map.getCenter().lng();
			obj.distance = 2000; // 2,000 meter
			Facebook.api("search", onGetPlaceComplete, obj, "GET");
			
			addFBLoading();
		}
		
		private function onGetPlaceComplete(result:Object, fail:Object):void
		{
			info_txt.appendText("onGetPlaceComplete\n");
			if (result) {
				trace("======= onGetPlaceComplete ========");
				//t.obj(result);
				info_txt.appendText(t.obj(result));
				putPlaceToMap(result as Array);
				trace("=========      end       ==========");
			}
			if (fail) {
				t.obj(fail);
			}
			
			removeFBLoading();
		}
		
		private function putPlaceToMap(_array:Array):void
		{
			map.clearOverlays();
			var i:uint;
			var len:uint = _array.length;
			var place_obj:Object;
			//var latlng:LatLng;
			for (i = 0; i < len; i++) {
				place_obj = _array[i];
				//latlng = new LatLng(place_obj.location.latitude, place_obj.location.longitude);
				//map.addOverlay(createMarker(latlng));
				map.addOverlay(createMarker(place_obj));
			}
		}
		
		// Facebook Loading **********************************************************************************************************************************
		private function addFBLoading():void 
		{
			if (fb_loading) {
				fb_loading.visible = true;
			}else {
				fb_loading = new Distractor();
				fb_loading.x = stage.stageWidth * 0.5 - 100;
				fb_loading.y = 40;
				fb_loading.mouseChildren = fb_loading.mouseEnabled = false;
				addChild(fb_loading);
			}
		}
		
		private function removeFBLoading():void 
		{
			if (fb_loading) {
				fb_loading.visible = false;
			}
		}
		
		// Google Map **********************************************************************************************************************************
		private function initMap():void
		{
			Security.allowInsecureDomain("maps.googleapis.com");
			map = new Map();
			map.key = MAP_KEY;
			
			//介面語系
			map.language = "zh-TW";
			map.setSize(new Point(stage.stageWidth, stage.stageHeight));
			map.x = 0;
			map.y = 0;
			//偵聽MAP載入完成
			map.addEventListener(MapEvent.MAP_READY, onMapReady);
			//addChild(map);
			addChildAt(map, getChildIndex(info_txt));
		}
		
		private function onMapReady(e:MapEvent):void
		{
			//trace("onMapReady");
			
			//設定MAP中心
			//map.setCenter(new LatLng(40.736072,-73.992062), 14, MapType.NORMAL_MAP_TYPE);
			//map.setCenter(new LatLng(25.057538,121.548421), 17); // wwwins
			map.setCenter(new LatLng(default_lat, default_lng), 16);
			//map.setCenter(new LatLng(_lat, _lng), 14);
			
			//整個台灣
			//map.setCenter(new LatLng(25.142798,121.549537), 15);
			//setMapCenter( { "lat":25.142798, "lng":121.549537 }, 15);
			
			//增加控制列：上下左右
			//map.addControl(new PositionControl());  
			//增加控制列：地圖類型
			//map.addControl(new MapTypeControl());
			//增加控制列：放大縮小
			var control:IControl = new ZoomControl();
			map.addControl(control);
			//Sprite(control).x = 5;
			Sprite(control).y = 105;
			//使用滾輪縮放地圖
			map.enableScrollWheelZoom();
			//平滑縮放地圖
			map.enableContinuousZoom();
			//取消點擊地圖放大
			//map.setDoubleClickMode(3);
				
			//移除偵聽MAP載入完成
			map.removeEventListener(MapEvent.MAP_READY, onMapReady);
			//偵聽MAP VIEW CHANGE START
			map.addEventListener(MapMoveEvent.MOVE_START, onMapMoveStart);
			//偵聽MAP VIEW CHANGE END
			map.addEventListener(MapMoveEvent.MOVE_END, onMapMoveEnd);
			//偵聽MAP ZOOM CHANGE
			//map.addEventListener(MapZoomEvent.CONTINUOUS_ZOOM_END , onMapZoomEnd);
			
			//var latlng:LatLng = new LatLng(map.getCenter().lat(), map.getCenter().lng());
			//map.clearOverlays();
			//map.addOverlay(createMarker(latlng));
			getPlace();
		}
		
		private function onMapMoveStart(e:MapMoveEvent):void
		{
			map.clearOverlays();
		}
		
		private function onMapMoveEnd(e:MapMoveEvent):void
		{
			getPlace();
		}
		
		//private function createMarker(latlng:LatLng):Marker
		private function createMarker(place_obj:Object):Marker
		{
			var options:MarkerOptions = new MarkerOptions();
			var _mc:MyMarker = new MyMarker();
			_mc.mouseEnabled = false;
			_mc.mouseChildren = false;
			_mc["place_obj"] = place_obj;
			options.icon = _mc;
			//options.clickable = false;// 讓marker不能點
			
			var latlng:LatLng = new LatLng(place_obj.location.latitude, place_obj.location.longitude);
			var marker:Marker = new Marker(latlng, options);
			marker.addEventListener(MapMouseEvent.ROLL_OVER, onMakerOver);
			marker.addEventListener(MapMouseEvent.ROLL_OUT , onMakerOut);
			marker.addEventListener(MapMouseEvent.CLICK    , onMakerClick);
			return marker;
		}
		
		private function onMakerOver(e:MapMouseEvent):void 
		{
			var marker:Marker = e.target as Marker;
			var _mc:MyMarker = marker.getOptions().icon as MyMarker;
			var tf:TextField = new TextField();
			tf.name = "tip";
			tf.autoSize = TextFieldAutoSize.LEFT;
			//tf.text = "Test";
			tf.text = _mc["place_obj"].name;
			tf.background = true;
			tf.x = - tf.textWidth * 0.5;
			tf.y = -50;
			_mc.addChild(tf);
		}
		
		private function onMakerOut(e:MapMouseEvent):void 
		{
			var marker:Marker = e.target as Marker;
			var _mc:MyMarker = marker.getOptions().icon as MyMarker;
			_mc.removeChild(_mc.getChildByName("tip"));
		}
		
		private function onMakerClick(e:MapMouseEvent):void 
		{
			var marker:Marker = e.target as Marker;
			var _mc:MyMarker = marker.getOptions().icon as MyMarker;
			checkin_obj.id = _mc["place_obj"].id;
			checkin_obj.lat = _mc["place_obj"].location.latitude;
			checkin_obj.lng = _mc["place_obj"].location.longitude;
			checkin();
		}
	}
	
}