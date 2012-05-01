package sketch 
{
	import flash.media.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.text.*;
    import flash.display.*; 
    import flash.events.*;
    import flash.utils.*;
	import jp.nyatla.as3utils.sketch.*;
	import jp.nyatla.as3utils.*;
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import org.libspark.flartoolkit.core.*;
	import org.libspark.flartoolkit.core.types.*;
	import org.libspark.flartoolkit.markersystem.*;
	import org.libspark.flartoolkit.pv3d.*;
	import org.papervision3d.render.*;
	import org.papervision3d.view.*;
	import org.papervision3d.objects.*;
	import org.papervision3d.lights.*;
	import org.papervision3d.materials.*;
	import org.papervision3d.materials.shadematerials.*;
	import org.papervision3d.objects.primitives.*;
	import org.papervision3d.materials.utils.*;
	import org.papervision3d.scenes.*;
	/**
	 * FLSketchを使用したプログラムです。
	 * PV3Dの初期化、Flashオブジェクトの配置などを省略せずに実装しています。
	 */
	public class ARSketch extends FLSketch
	{
		private static const _CAM_W:int = 320;
		private static const _CAM_H:int = 240;
		private var _ss:FLARSensor;
		private var _ms:FLARPv3dMarkerSystem;
		public var bitmap:Bitmap = new Bitmap(new BitmapData(_CAM_W,_CAM_H));

		private var _video:Video;
		private var _render:LazyRenderEngine;
		
		private var marker_id:int;
		private var marker_node:DisplayObject3D;
		
		public function ARSketch()
		{
			//setup UI
			this.bitmap.x = 0;
			this.bitmap.y = 0;
			this.bitmap.width = _CAM_W;
			this.bitmap.height = _CAM_H;
            this.addChild(bitmap);
		}
		private var _fid:Vector.<int>=new Vector.<int>(3);
		public override function setup():void
		{
			//setup content files...
			this._fid[0]=this.setSketchFile("../../../data/camera_para.dat", URLLoaderDataFormat.BINARY);//0
			this._fid[1]=this.setSketchFile("../../../data/patt.hiro", URLLoaderDataFormat.TEXT);//1
			this._fid[2]=this.setSketchFile("../../../data/320x240ABGR.raw", URLLoaderDataFormat.BINARY);//2
		}

		public override function main():void
		{
			//webcam
			var webcam:Camera = Camera.getCamera();
			if (!webcam) {
				throw new Error('No webcam!!!!');
			}
			webcam.setMode(_CAM_W, _CAM_H, 30);
			this._video = new Video(_CAM_W, _CAM_H);
			this._video.attachCamera(webcam);			
			//FLMarkerSystem
			var cf:FLARMarkerSystemConfig = new FLARMarkerSystemConfig(_CAM_W, _CAM_H);//make configlation
			this._ss = new FLARSensor(new NyARIntSize(_CAM_W, _CAM_H));
			this._ms = new FLARPv3dMarkerSystem(cf);
			this.marker_id = this._ms.addARMarker_2(String(this.getSketchFile(this._fid[1])), 16, 25, 80); //register AR Marker
			
			//setup PV3d
			var light:PointLight3D = new PointLight3D();
			light.x = 0;
			light.y = 1000;
			light.z = -1000;			
			var viewport3d:Viewport3D = new Viewport3D(_CAM_W,_CAM_H);
			viewport3d.scaleX = 1;
			viewport3d.scaleY = 1;
			viewport3d.x = -4; // 4pix ???
			this.addChild(viewport3d);
			//3d object
			this.marker_node = create3dObject(light);
			this.marker_node.visible = false;
			//scene
			var s:Scene3D = new Scene3D();
			s.addChild(this.marker_node);
			this._render=new LazyRenderEngine(s,this._ms.getPv3dCamera(),viewport3d);
			
			//start camera
			this.addEventListener(Event.ENTER_FRAME, _onEnterFrame);
		}
		/**
		 * MainLoop
		 * @param	e
		 */
		private function _onEnterFrame(e:Event = null):void
		{
			this._ss.update_2(this._video);//update sensor status
			this._ms.update(this._ss);//update markersystem status
			if (this._ms.isExistMarker(marker_id)){
				this.marker_node.visible = true;
				this._ms.getPv3dMarkerMatrix(this.marker_id, this.marker_node.transform);
			}else {
				this.marker_node.visible = false;
			}
			this.bitmap.bitmapData.draw(this._video);
			this._render.render();
		}
		/**
		 * Create a 3dModel together with wireframe and cube.
		 * @return
		 */
		private function create3dObject(i_light:PointLight3D):DisplayObject3D
		{
			var node:DisplayObject3D = new DisplayObject3D();
			//Red wireFrame
			var wmat:WireframeMaterial = new WireframeMaterial(0xff0000, 1, 2); // with wireframe. / ワイヤーフレームで。
			var plane:Plane = new Plane(wmat, 80, 80); // 80mm x 80mm。
			plane.rotationX = 180;
			node.addChild(plane);
			//
			var fmat:FlatShadeMaterial = new FlatShadeMaterial(i_light, 0xff22aa, 0x75104e); // Color is ping. / ピンク色。
			var cube:Cube = new Cube(new MaterialsList({all: fmat}), 40, 40, 40); // 40mm x 40mm x 40mm
 	        cube.z = 20; // Move the cube to upper (minus Z) direction Half height of the Cube. / 立方体の高さの半分、上方向(-Z方向)に移動させるとちょうどマーカーにのっかる形になる。
			node.addChild(cube);			
			return node;
		}	
	}
}