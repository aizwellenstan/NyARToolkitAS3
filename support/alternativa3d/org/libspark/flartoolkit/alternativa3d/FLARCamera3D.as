/* 
 * PROJECT: FLARToolKit
 * --------------------------------------------------------------------------------
 * This work is based on the NyARToolKit developed by
 *   R.Iizuka (nyatla)
 * http://nyatla.jp/nyatoolkit/
 *
 * The FLARToolKit is ActionScript 3.0 version ARToolkit class library.
 * Copyright (C)2008 Saqoosha
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this framework; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * 
 * For further information please contact.
 *	http://www.libspark.org/wiki/saqoosha/FLARToolKit
 *	<saq(at)saqoosha.net>
 * 
 */

package org.libspark.flartoolkit.alternativa3d
{
	import alternativa.engine3d.core.*;
	import jp.nyatla.nyartoolkit.as3.core.*;
	import jp.nyatla.nyartoolkit.as3.core.param.*;
	import jp.nyatla.nyartoolkit.as3.core.types.NyARIntSize;	
	import org.libspark.flartoolkit.utils.ArrayUtil;

	public class FLARCamera3D extends Camera3D {
		private static const NEAR_CLIP:Number = 10;
		private static const FAR_CLIP:Number = 10000;		
		
		public function FLARCamera3D(param:NyARParam = null)
		{
			super(NEAR_CLIP, FAR_CLIP);
			if (!param) {
				this.setParam(param,NEAR_CLIP,FAR_CLIP);
			}else {
				this.setParam(NyARParam.createDefaultParameter(), NEAR_CLIP, FAR_CLIP);
			}
			this.x = 0;
			this.y = 0;
			this.z = 0;
		}
		private var _ref_param:NyARParam;
		private var _frustum:NyARFrustum = new NyARFrustum();
		public function setParam(param:NyARParam,i_near:int,i_far:int):void
		{
			var s:NyARIntSize = param.getScreenSize();
			this._frustum.setValue_2(param.getPerspectiveProjectionMatrix(), s.w, s.h,i_near,i_far);
			var ap:NyARFrustum_PerspectiveParam = this._frustum.getPerspectiveParam(new NyARFrustum_PerspectiveParam());
			this._ref_param = param;
			this.nearClipping = i_near;
			this.farClipping = i_far;
			this.fov = 2 *ap.fovy;
		}
		public function createBackgroundPanel(i_backbuffer_size:int=512):FLARBackgroundPanel
		{
			var bgp:FLARBackgroundPanel = new FLARBackgroundPanel(1,1,i_backbuffer_size);
			
			var fp:NyARFrustum_FrustumParam=this._frustum.getFrustumParam(new NyARFrustum_FrustumParam());
			var bg_pos:Number = fp.far-0.1;
			bgp.z=bg_pos;
			var b:Number=bg_pos/fp.near;// 10?
			bgp.scaleX = -((fp.right - fp.left) * b);
			bgp.scaleY = -((fp.top - fp.bottom) * b);
			return bgp;
		}
		
	}
}