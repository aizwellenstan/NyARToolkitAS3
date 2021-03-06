package 
{

	import jp.nyatla.as3utils.*;
	import jp.nyatla.nyartoolkit.as3.*;
	import jp.nyatla.nyartoolkit.as3.core.param.*;
	import jp.nyatla.nyartoolkit.as3.core.*;
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import jp.nyatla.nyartoolkit.as3.core.types.matrix.*;
	import jp.nyatla.nyartoolkit.as3.detector.*;
	import jp.nyatla.nyartoolkit.as3.core.raster.rgb.*;
	import jp.nyatla.nyartoolkit.as3.core.transmat.*;
	import jp.nyatla.nyartoolkit.as3.rpf.reality.nyartk.*;
	import jp.nyatla.nyartoolkit.as3.rpf.realitysource.nyartk.*;
	import jp.nyatla.nyartoolkit.as3.markersystem.*;
	import flash.net.*;
	import flash.text.*;
    import flash.display.*; 
    import flash.events.*;
    import flash.utils.*;
	/**
	 * ...
	 * @author 
	 */
	public class Main extends Sprite 
	{
		
		private static var inst:Main;
        private var textbox:TextField = new TextField();
		private var param:NyARParam;
		private var code:NyARCode;
		private var raster_bgra:NyARRgbRaster;
		private var id_bgra:NyARRgbRaster;
		public function msg(i_str:String):void
		{
			this.textbox.text = this.textbox.text + "\n" + i_str;
		}
		public static function megs(i_str:String):void
		{
			inst.msg(i_str);
		}

		public function Main():void 
		{
			Main.inst = this;
			//デバック用のテキストボックス
			this.textbox.x = 0; this.textbox.y = 0;
			this.textbox.width=640,this.textbox.height=480; 
			this.textbox.condenseWhite = true;
			this.textbox.multiline =   true;
			this.textbox.border = true;
            addChild(textbox);

			//ファイルをメンバ変数にロードする。
			var mf:NyMultiFileLoader=new NyMultiFileLoader();
			mf.addTarget(
				"../../../data/camera_para.dat",URLLoaderDataFormat.BINARY,
				function(data:ByteArray):void
				{
 		            param = NyARParam.createFromARParamFile(data);
            		param.changeScreenSize(320,240);
				});
			mf.addTarget(
				"../../../data/patt.hiro",URLLoaderDataFormat.TEXT,
				function(data:String):void
				{
					code=NyARCode.createFromARPattFile(data,16, 16);
				}
			);
			mf.addTarget(
				"../../../data/320x240ABGR.raw",URLLoaderDataFormat.BINARY,
				function(data:ByteArray):void
				{
					var r:NyARRgbRaster = new NyARRgbRaster(320, 240, NyARBufferType.INT1D_X8R8G8B8_32);
					var b:Vector.<int> =	Vector.<int>(r.getBuffer());
					data.endian = Endian.LITTLE_ENDIAN;
					for (var i:int = 0; i < 320 * 240; i++) {
						b[i]=data.readInt();
					}
            		raster_bgra=r;
				});

			mf.addTarget(
				"../../../data/320x240NyId.raw",URLLoaderDataFormat.BINARY,
				function(data:ByteArray):void
				{
					var r:NyARRgbRaster = new NyARRgbRaster(320, 240, NyARBufferType.INT1D_X8R8G8B8_32);
					var b:Vector.<int> =	Vector.<int>(r.getBuffer());
					data.endian = Endian.LITTLE_ENDIAN;
					for (var i:int = 0; i < 320 * 240; i++) {
						b[i]=data.readInt();
					}
            		id_bgra=r;
				});				
            //終了後mainに遷移するよ―に設定
			mf.addEventListener(Event.COMPLETE,main);
            mf.multiLoad();//ロード開始
            return;//dispatch event*/
		}
		private function testNyARSingleDetectMarker():void
		{
			var mat:NyARDoubleMatrix44=new NyARDoubleMatrix44();
			var ang:NyARDoublePoint3d = new NyARDoublePoint3d();
			var d:NyARSingleDetectMarker=NyARSingleDetectMarker.createInstance_2(this.param, this.code, 80.0);
			d.detectMarkerLite(raster_bgra,100);
			msg("cf=" + d.getConfidence());
			{
				d.getTransmationMatrix(mat);
				msg("getTransmationMatrix");
				msg(mat.m00 + "," + mat.m01 + "," + mat.m02 + "," + mat.m03);
				msg(mat.m10 + "," + mat.m11 + "," + mat.m12 + "," + mat.m13);
				msg(mat.m20 + "," + mat.m21 + "," + mat.m22 + "," + mat.m23);
				msg("getZXYAngle");
				mat.getZXYAngle(ang);
				msg(ang.x + "," + ang.y + "," + ang.z);
			}
			msg("#benchmark");
			{
				var date : Date = new Date();
				for(var i2:int=0;i2<100;i2++){
					d.detectMarkerLite(raster_bgra,100);
					d.getTransmationMatrix(mat);
				}
				var date2 : Date = new Date();
				msg(((date2.valueOf() - date.valueOf()).toString())+"[ms] par 100 frame");
			}
			return;
		}
		private function testNyARDetectMarker():void
		{
			var mat:NyARDoubleMatrix44=new NyARDoubleMatrix44();
			var ang:NyARDoublePoint3d = new NyARDoublePoint3d();
			var codes:Vector.<NyARCode>=new Vector.<NyARCode>();
			var codes_width:Vector.<Number>=new Vector.<Number>();
			codes[0]=code;
			codes_width[0]=80.0;
			var t:NyARDetectMarker=new NyARDetectMarker(param,codes,codes_width,1,NyARBufferType.INT1D_X8R8G8B8_32);
			var num_of_detect:int=t.detectMarkerLite(raster_bgra,100);
			msg("found="+num_of_detect);
			for(var i:int=0;i<num_of_detect;i++){
				msg("no="+i);
				t.getConfidence(i);
				t.getTransmationMatrix(i,mat);
				msg("getTransmationMatrix");
				msg(mat.m00 + "," + mat.m01 + "," + mat.m02 + "," + mat.m03);
				msg(mat.m10 + "," + mat.m11 + "," + mat.m12 + "," + mat.m13);
				msg(mat.m20 + "," + mat.m21 + "," + mat.m22 + "," + mat.m23);
				msg("getZXYAngle");
				mat.getZXYAngle(ang);
				msg(ang.x + "," + ang.y + "," + ang.z);
			}		
		}
		private function testSingleProcessor():void
		{
			var codes:Vector.<NyARCode>=new Vector.<NyARCode>();
			var codes_width:Vector.<Number>=new Vector.<Number>();
			codes[0]=code;
			codes_width[0]=80.0;
			var t3:SingleProcessor=new SingleProcessor(param,NyARBufferType.INT1D_X8R8G8B8_32,this);
			t3.setARCodeTable(codes,16,80.0);
			t3.detectMarker(raster_bgra);
		}
		private function testIdMarkerProcessor():void
		{
			var t:IdMarkerProcessor=new IdMarkerProcessor(param,NyARBufferType.INT1D_X8R8G8B8_32,this);
			t.detectMarker(id_bgra);
		}
		public function testNyARReality():void 
		{
			var reality:NyARReality=new NyARReality(param.getScreenSize(),10,1000,param.getPerspectiveProjectionMatrix(),null,10,10);
			var reality_in:NyARRealitySource = new NyARRealitySource_Reference(320, 240, null, 2, 100, NyARBufferType.INT1D_X8R8G8B8_32);
			var dt:Vector.<int> = Vector.<int>(reality_in.refRgbSource().getBuffer());
			var sr:Vector.<int> = Vector.<int>(raster_bgra.getBuffer());
			for (var i:int = 0; i < sr.length; i++) { dt[i] = sr[i]; }
			

//			FileInputStream fs = new FileInputStream(DATA_FILE);
//			fs.read((byte[])reality_in.refRgbSource().getBuffer());
			var date : Date = new Date();
			for(var i2:int=0;i2<100;i2++){
				reality.progress(reality_in);
			}
			var date2 : Date = new Date();
			msg(((date2.valueOf() - date.valueOf()).toString())+"[ms] par 100 frame");

			
			msg(reality.getNumberOfKnown().toString());
			msg(reality.getNumberOfUnknown().toString());
			msg(reality.getNumberOfDead().toString());
			var rt:Vector.<NyARRealityTarget>=new Vector.<NyARRealityTarget>(10);
			reality.selectUnKnownTargets(rt);
			reality.changeTargetToKnown(rt[0],2,80);
			msg(rt[0]._transform_matrix.m00+","+rt[0]._transform_matrix.m01+","+rt[0]._transform_matrix.m02+","+rt[0]._transform_matrix.m03);
			msg(rt[0]._transform_matrix.m10+","+rt[0]._transform_matrix.m11+","+rt[0]._transform_matrix.m12+","+rt[0]._transform_matrix.m13);
			msg(rt[0]._transform_matrix.m20+","+rt[0]._transform_matrix.m21+","+rt[0]._transform_matrix.m22+","+rt[0]._transform_matrix.m23);
			msg(rt[0]._transform_matrix.m30+","+rt[0]._transform_matrix.m31+","+rt[0]._transform_matrix.m32+","+rt[0]._transform_matrix.m33);
		}
		private function testNyMarkerSystem():void
		{
			var ss:NyARSensor = new NyARSensor(new NyARIntSize(320, 240));
			var cf:NyARMarkerSystemConfig = new NyARMarkerSystemConfig(320, 240);
			var ms:NyARMarkerSystem = new NyARMarkerSystem(cf);
			
			var id:int = ms.addARMarker(this.code, 25, 80);
			ss.update(this.raster_bgra);
			ms.update(ss);
			var mat:NyARDoubleMatrix44=ms.getMarkerMatrix(id);

			msg("cf=" + ms.getConfidence(id));
			{
				msg("getTransmationMatrix");
				msg(mat.m00 + "," + mat.m01 + "," + mat.m02 + "," + mat.m03);
				msg(mat.m10 + "," + mat.m11 + "," + mat.m12 + "," + mat.m13);
				msg(mat.m20 + "," + mat.m21 + "," + mat.m22 + "," + mat.m23);
			}
			msg("#benchmark");
			{
				var date : Date = new Date();
				for(var i2:int=0;i2<100;i2++){
					ss.update(this.raster_bgra);
					ms.update(ss);
				}
				var date2 : Date = new Date();
				msg(((date2.valueOf() - date.valueOf()).toString())+"[ms] par 100 frame");
			}
			return;
		}		
		private function main(e:Event):void
		{
			var mat:NyARDoubleMatrix44=new NyARDoubleMatrix44();
			var ang:NyARDoublePoint3d = new NyARDoublePoint3d();
			msg("NyARToolkitAS3 check program.");
			msg("(c)2010 nyatla.");
			msg("#ready!");
			{
				msg("<NyARSingleDetectMarker>");
				testNyARSingleDetectMarker();
			}
			{
				msg("<NyARDetectMarker>");
				testNyARDetectMarker();
			}
			{
				msg("<IdMarkerProcessor>");
				testIdMarkerProcessor();
			}
			{
				msg("<SingleProcessor>");
				testSingleProcessor();
			}
			{
				msg("<Reality>");
				testNyARReality();
			}
			{
				msg("<testNyMarkerSystem>");
				testNyMarkerSystem();
			}
			msg("#finish!");
			return;
		}
		
	}
	
}
import jp.nyatla.nyartoolkit.as3.processor.*;
import jp.nyatla.nyartoolkit.as3.core.transmat.*;
import jp.nyatla.nyartoolkit.as3.nyidmarker.*;
import jp.nyatla.nyartoolkit.as3.nyidmarker.data.*;
import jp.nyatla.nyartoolkit.as3.core.squaredetect.*;
import jp.nyatla.nyartoolkit.as3.core.param.*;
import jp.nyatla.nyartoolkit.as3.core.types.matrix.*;

class SingleProcessor extends SingleARMarkerProcesser
{
	public var transmat:NyARDoubleMatrix44=null;
	public var current_code:int=-1;
	private var _parent:Main;
	public function SingleProcessor(i_cparam:NyARParam,i_raster_format:int,i_parent:Main)
	{
		super();
		this._parent=i_parent;
		initInstance(i_cparam);
	}
	
	protected override function onEnterHandler(i_code:int):void
	{
		current_code=i_code;
		_parent.msg("onEnterHandler:"+i_code);
	}

	protected override function onLeaveHandler():void
	{
	}

	protected override function onUpdateHandler(i_square:NyARSquare,result:NyARDoubleMatrix44):void
	{
		_parent.msg("onUpdateHandler:" + current_code);
		_parent.msg(result.m00 + "," + result.m01 + "," + result.m02 + "," + result.m03);
		_parent.msg(result.m10 + "," + result.m11 + "," + result.m12 + "," + result.m13);
		_parent.msg(result.m20 + "," + result.m21 + "," + result.m22 + "," + result.m23);
		this.transmat=result;
	}	
}

class IdMarkerProcessor extends SingleNyIdMarkerProcesser
{	
	public var transmat:NyARDoubleMatrix44=null;
	public var current_id:int=-1;
	private var _parent:Main;
	private var _encoder:NyIdMarkerDataEncoder_RawBit;

	public function IdMarkerProcessor(i_cparam:NyARParam,i_raster_format:int,i_parent:Main)
	{
		//アプリケーションフレームワークの初期化
		super();
		this._parent=i_parent;
		this._encoder=new NyIdMarkerDataEncoder_RawBit();
		initInstance(i_cparam,this._encoder,100,i_raster_format);
		return;
	}
	
	/**
	 * アプリケーションフレームワークのハンドラ（マーカ出現）
	 */
	protected override function onEnterHandler(i_code:INyIdMarkerData):void
	{
		var code:NyIdMarkerData_RawBit=i_code as NyIdMarkerData_RawBit;
		
		//read data from i_code via Marsial--Marshal経由で読み出す
		var i:int;
		if(code.length>4){
			//4バイト以上の時はint変換しない。
			this.current_id=-1;//undefined_id
		}else{
			this.current_id=0;
			//最大4バイト繋げて１個のint値に変換
			for(i=0;i<code.length;i++){
				this.current_id=(this.current_id<<8)|code.packet[i];
			}
		}
		_parent.msg("onEnterHandler:"+this.current_id);
		this.transmat=null;
	}
	/**
	 * アプリケーションフレームワークのハンドラ（マーカ消滅）
	 */
	protected override function onLeaveHandler():void
	{
		this.current_id=-1;
		this.transmat=null;
		return;
	}
	/**
	 * アプリケーションフレームワークのハンドラ（マーカ更新）
	 */
	protected override function onUpdateHandler(i_square:NyARSquare,result:NyARDoubleMatrix44):void
	{
		_parent.msg("onUpdateHandler:"+this.current_id);
		_parent.msg(result.m00 + "," + result.m01 + "," + result.m02 + "," + result.m03);
		_parent.msg(result.m10 + "," + result.m11 + "," + result.m12 + "," + result.m13);
		_parent.msg(result.m20 + "," + result.m21 + "," + result.m22 + "," + result.m23);
		this.transmat=result;
	}
}

