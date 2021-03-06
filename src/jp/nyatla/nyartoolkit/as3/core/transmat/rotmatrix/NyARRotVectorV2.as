/* 
 * PROJECT: NyARToolkitAS3
 * --------------------------------------------------------------------------------
 *
 * The NyARToolkitCS is AS3 edition NyARToolKit class library.
 * Copyright (C)2010 Ryo Iizuka
 *
 * This work is based on the ARToolKit developed by
 *   Hirokazu Kato
 *   Mark Billinghurst
 *   HITLab, University of Washington, Seattle
 * http://www.hitl.washington.edu/artoolkit/
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as publishe
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * For further information please contact.
 *	http://nyatla.jp/nyatoolkit/
 *	<airmail(at)ebony.plala.or.jp> or <nyatla(at)nyatla.jp>
 * 
 */
package jp.nyatla.nyartoolkit.as3.core.transmat.rotmatrix
{

	import jp.nyatla.nyartoolkit.as3.core.*;
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import jp.nyatla.nyartoolkit.as3.core.types.matrix.*;
	import jp.nyatla.nyartoolkit.as3.core.param.*;

	/**
	 * このクラスは、{@link NyARRotMatrix}クラスに、ベクトル(直線)から回転行列を計算する機能を追加します。
	 * 通常、ユーザがこのクラスを使うことはありません。{@link NyARRotMatrix}クラスから使います。
	 */
	public class NyARRotVectorV2 extends NyARRotVector
	{
		//privateメンバ達	
		private var _projection_mat_ref:NyARPerspectiveProjectionMatrix;
		private var _inv_cpara:NyARDoubleMatrix44=new NyARDoubleMatrix44();

		/**
		 * コンストラクタです。
		 * 射影変換オブジェクトの参照値を設定して、インスタンスを作成します。
		 * @param i_cmat
		 * 射影変換オブジェクト。この値はインスタンスの生存中は変更しないでください。
		 * @throws NyARException
		 */
		public function NyARRotVectorV2(i_cmat:NyARPerspectiveProjectionMatrix)
		{
			super();
			this._inv_cpara.inverse(i_cmat);
			this._projection_mat_ref = i_cmat;
		}

		/**
		 * この関数は、２直線に直交するベクトルを計算して、その３次元ベクトルをインスタンスに格納します。
		 * （多分）
		 * @param i_linear1
		 * 直線１
		 * @param i_linear2
		 * 直線２
		 */
		public function exteriorProductFromLinear(i_linear1:NyARLinear,i_linear2:NyARLinear):void
		{
			//1行目
			var cmat:NyARPerspectiveProjectionMatrix= this._projection_mat_ref;
			var w1:Number = i_linear1.a * i_linear2.b - i_linear2.a * i_linear1.b;
			var w2:Number = i_linear1.b * i_linear2.c - i_linear2.b * i_linear1.c;
			var w3:Number = i_linear1.c * i_linear2.a - i_linear2.c * i_linear1.a;

			var m0:Number = w1 * (cmat.m01 * cmat.m12 - cmat.m02 * cmat.m11) + w2 * cmat.m11 - w3 * cmat.m01;//w1 * (cpara[0 * 4 + 1] * cpara[1 * 4 + 2] - cpara[0 * 4 + 2] * cpara[1 * 4 + 1]) + w2 * cpara[1 * 4 + 1] - w3 * cpara[0 * 4 + 1];
			var m1:Number = -w1 * cmat.m00 * cmat.m12 + w3 * cmat.m00;//-w1 * cpara[0 * 4 + 0] * cpara[1 * 4 + 2] + w3 * cpara[0 * 4 + 0];
			var m2:Number = w1 * cmat.m00 * cmat.m11;//w1 * cpara[0 * 4 + 0] * cpara[1 * 4 + 1];
			var w:Number = Math.sqrt(m0 * m0 + m1 * m1 + m2 * m2);
			this.v1 = m0 / w;
			this.v2 = m1 / w;
			this.v3 = m2 / w;
			return;
		}
		/**
		 * この関数は、ARToolKitのcheck_dir関数に相当します。
		 * 詳細は不明です。(ベクトルの開始/終了座標を指定して、ベクトルの方向を調整？)
		 * @param i_start_vertex
		 * 開始位置？
		 * @param i_end_vertex
		 * 終了位置？
		 * @throws NyARException
		 */
		public function checkVectorByVertex(i_start_vertex:NyARDoublePoint2d, i_end_vertex:NyARDoublePoint2d):Boolean
		{
			var h:Number;
			var inv_cpara:NyARDoubleMatrix44 = this._inv_cpara;
			//final double[] world = __checkVectorByVertex_world;// [2][3];
			var world0:Number = inv_cpara.m00 * i_start_vertex.x * 10.0 + inv_cpara.m01 * i_start_vertex.y * 10.0 + inv_cpara.m02 * 10.0;// mat_a->m[0]*st[0]*10.0+
			var world1:Number = inv_cpara.m10 * i_start_vertex.x * 10.0 + inv_cpara.m11 * i_start_vertex.y * 10.0 + inv_cpara.m12 * 10.0;// mat_a->m[3]*st[0]*10.0+
			var world2:Number = inv_cpara.m20 * i_start_vertex.x * 10.0 + inv_cpara.m21 * i_start_vertex.y * 10.0 + inv_cpara.m22 * 10.0;// mat_a->m[6]*st[0]*10.0+
			var world3:Number = world0 + this.v1;
			var world4:Number = world1 + this.v2;
			var world5:Number = world2 + this.v3;
			// </Optimize>

			var cmat:NyARPerspectiveProjectionMatrix= this._projection_mat_ref;
			h = cmat.m20 * world0 + cmat.m21 * world1 + cmat.m22 * world2;
			if (h == 0.0) {
				return false;
			}
			var camera0:Number = (cmat.m00 * world0 + cmat.m01 * world1 + cmat.m02 * world2) / h;
			var camera1:Number = (cmat.m10 * world0 + cmat.m11 * world1 + cmat.m12 * world2) / h;

			//h = cpara[2 * 4 + 0] * world3 + cpara[2 * 4 + 1] * world4 + cpara[2 * 4 + 2] * world5;
			h = cmat.m20 * world3 + cmat.m21 * world4 + cmat.m22 * world5;
			if (h == 0.0) {
				return false;
			}
			var camera2:Number = (cmat.m00 * world3 + cmat.m01 * world4 + cmat.m02 * world5) / h;
			var camera3:Number = (cmat.m10 * world3 + cmat.m11 * world4 + cmat.m12 * world5) / h;

			var v:Number = (i_end_vertex.x - i_start_vertex.x) * (camera2 - camera0) + (i_end_vertex.y - i_start_vertex.y) * (camera3 - camera1);
			if (v < 0) {
				this.v1 = -this.v1;
				this.v2 = -this.v2;
				this.v3 = -this.v3;
			}
			return true;
		}
	}
}