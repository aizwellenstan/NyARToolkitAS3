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
package jp.nyatla.nyartoolkit.as3.core.labeling 
{
	public class NyARLabelOverlapChecker
	{
		private var _labels:Vector.<Object>;
		private var _length:int;
		/*
		*/
		public function NyARLabelOverlapChecker(i_max_label:int)
		{
			this._labels = createArray(i_max_label);
		}
		protected function createArray(i_length:int):Vector.<Object>
		{
			return new Vector.<Object>(i_length);
		}

		/**
		 * チェック対象のラベルを追加する。
		 * 
		 * @param i_label_ref
		 */
		public function push(i_label_ref:NyARLabelInfo):void
		{
			this._labels[this._length] = i_label_ref;
			this._length++;
		}

		/**
		 * 現在リストにあるラベルと重なっているかを返す。
		 * 
		 * @param i_label
		 * @return 何れかのラベルの内側にあるならばfalse,独立したラベルである可能性が高ければtrueです．
		 */
		public function check(i_label:NyARLabelInfo):Boolean
		{
			// 重なり処理かな？
			var label_pt:Vector.<Object>  = this._labels;
			var px1:int = (int)(i_label.pos_x);
			var py1:int = (int)(i_label.pos_y);
			for (var i:int = this._length - 1; i >= 0; i--) {
				var label_ptr:NyARLabelInfo = (NyARLabelInfo)(label_pt[i]);
				var px2:int = (int)(label_ptr.pos_x);
				var py2:int = (int)(label_ptr.pos_y);
				var d:int = (px1 - px2) * (px1 - px2) + (py1 - py2) * (py1 - py2);
				if (d < label_ptr.area / 4) {
					// 対象外
					return false;
				}
			}
			// 対象
			return true;
		}
		/**
		 * 最大i_max_label個のラベルを蓄積できるようにオブジェクトをリセットする
		 * 
		 * @param i_max_label
		 */
		public function setMaxLabels(i_max_label:int):void
		{
			if (i_max_label > this._labels.length) {
				this._labels = createArray(i_max_label);
			}
			this._length = 0;
		}
	}
}