/*
This file is part of OMOA.

(C) Leibniz Institute for Regional Geography,
    Leipzig, Germany

OMOA is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

OMOA is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with OMOA.  If not, see <http://www.gnu.org/licenses/>.
*/

package org.omoa.symbol {
	import flash.display.CapsStyle;
	import flash.display.DisplayObject;
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsStroke;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import org.omoa.framework.BoundingBox;
	import org.omoa.framework.SymbolProperty;
	import org.omoa.framework.SymbolPropertyType;
	import org.omoa.spacemodel.SpaceModelEntity;
	import org.omoa.symbol.AbstractSymbol;
	
	
	/**
	 * A symbol that renders ...
	 * 
	 * @author Sebastian Specht
	 *
	 */
	
	public class DirectionsSymbol extends AbstractSymbol {
		
		public const CENTER_FILLCOLOR:String = "fillcolor";
		public const CENTER_OUTLINECOLOR:String = "outlinecolor";
		public const CENTER_FILLALPHA:String = "fillalpha";
		public const CENTER_OUTLINEALPHA:String = "outlinealpha";
		public const CENTER_OUTLINEWIDTH:String = "outlinewidth";
		public const CENTER_SIZE:String = "size";
		
		public const N_COLOR:String = "n_color";
		public const N_ALPHA:String = "n_alpha";
		public const N_WIDTH:String = "n_width";
		public const N_LENGTH:String = "n_length";
		
		public const NE_COLOR:String = "ne_color";
		public const NE_ALPHA:String = "ne_alpha";
		public const NE_WIDTH:String = "ne_width";
		public const NE_LENGTH:String = "ne_length";
		
		public const E_COLOR:String = "e_color";
		public const E_ALPHA:String = "e_alpha";
		public const E_WIDTH:String = "e_width";
		public const E_LENGTH:String = "e_length";
		
		public const SE_COLOR:String = "se_color";
		public const SE_ALPHA:String = "se_alpha";
		public const SE_WIDTH:String = "se_width";
		public const SE_LENGTH:String = "se_length";
		
		public const S_COLOR:String = "s_color";
		public const S_ALPHA:String = "s_alpha";
		public const S_WIDTH:String = "s_width";
		public const S_LENGTH:String = "s_length";
		
		public const SW_COLOR:String = "sw_color";
		public const SW_ALPHA:String = "sw_alpha";
		public const SW_WIDTH:String = "sw_width";
		public const SW_LENGTH:String = "sw_length";
		
		public const W_COLOR:String = "w_color";
		public const W_ALPHA:String = "w_alpha";
		public const W_WIDTH:String = "w_width";
		public const W_LENGTH:String = "w_length";
		
		public const NW_COLOR:String = "nw_color";
		public const NW_ALPHA:String = "nw_alpha";
		public const NW_WIDTH:String = "nw_width";
		public const NW_LENGTH:String = "nw_length";
		
		public const ALL_COLOR:String = "all_color";
		public const ALL_ALPHA:String = "all_alpha";

		private var fill:GraphicsSolidFill = new GraphicsSolidFill(0xffffff);
		private var strokefill:GraphicsSolidFill = new GraphicsSolidFill();
		private var stroke:GraphicsStroke = new GraphicsStroke(1);
		
		private var n_dirStroke:GraphicsStroke = new GraphicsStroke(1);
		private var n_dirStrokefill:GraphicsSolidFill = new GraphicsSolidFill();
		private var ne_dirStroke:GraphicsStroke = new GraphicsStroke(1);
		private var ne_dirStrokefill:GraphicsSolidFill = new GraphicsSolidFill();
		private var e_dirStroke:GraphicsStroke = new GraphicsStroke(1);
		private var e_dirStrokefill:GraphicsSolidFill = new GraphicsSolidFill();
		private var se_dirStroke:GraphicsStroke = new GraphicsStroke(1);
		private var se_dirStrokefill:GraphicsSolidFill = new GraphicsSolidFill();
		private var s_dirStroke:GraphicsStroke = new GraphicsStroke(1);
		private var s_dirStrokefill:GraphicsSolidFill = new GraphicsSolidFill();
		private var sw_dirStroke:GraphicsStroke = new GraphicsStroke(1);
		private var sw_dirStrokefill:GraphicsSolidFill = new GraphicsSolidFill();
		private var w_dirStroke:GraphicsStroke = new GraphicsStroke(1);
		private var w_dirStrokefill:GraphicsSolidFill = new GraphicsSolidFill();
		private var nw_dirStroke:GraphicsStroke = new GraphicsStroke(1);
		private var nw_dirStrokefill:GraphicsSolidFill = new GraphicsSolidFill();
		
		private var size:Number = 1;
		
		private var n_length:Number = 1;
		private var ne_length:Number = 1;
		private var e_length:Number = 1;
		private var se_length:Number = 1;
		private var s_length:Number = 1;
		private var sw_length:Number = 1;
		private var w_length:Number = 1;
		private var nw_length:Number = 1;
		
		public function DirectionsSymbol() {
			_symbolProperties = new Vector.<SymbolProperty>(40, true);
			
			_symbolProperties[0] = new SymbolProperty();
			_symbolProperties[0].name = CENTER_FILLCOLOR;
			_symbolProperties[0].type = SymbolPropertyType.VALUE;
			
			_symbolProperties[1] = new SymbolProperty();
			_symbolProperties[1].name = CENTER_OUTLINECOLOR;
			_symbolProperties[1].type = SymbolPropertyType.VALUE;
			
			_symbolProperties[2] = new SymbolProperty();
			_symbolProperties[2].name = CENTER_FILLALPHA;
			_symbolProperties[2].type = SymbolPropertyType.VALUE;
			
			_symbolProperties[3] = new SymbolProperty();
			_symbolProperties[3].name = CENTER_OUTLINEALPHA;
			_symbolProperties[3].type = SymbolPropertyType.VALUE;
			
			_symbolProperties[4] = new SymbolProperty();
			_symbolProperties[4].name = CENTER_OUTLINEWIDTH;
			_symbolProperties[4].type = SymbolPropertyType.VALUE;
			
			_symbolProperties[5] = new SymbolProperty();
			_symbolProperties[5].name = CENTER_SIZE;
			_symbolProperties[5].type = SymbolPropertyType.VALUE;
			
			
			
			
			_symbolProperties[6] = new SymbolProperty();
			_symbolProperties[6].name = N_COLOR;
			_symbolProperties[6].type = SymbolPropertyType.VALUE;

			_symbolProperties[7] = new SymbolProperty();
			_symbolProperties[7].name = N_ALPHA;
			_symbolProperties[7].type = SymbolPropertyType.VALUE;

			_symbolProperties[8] = new SymbolProperty();
			_symbolProperties[8].name = N_WIDTH;
			_symbolProperties[8].type = SymbolPropertyType.VALUE;

			_symbolProperties[9] = new SymbolProperty();
			_symbolProperties[9].name = N_LENGTH;
			_symbolProperties[9].type = SymbolPropertyType.VALUE;

			
			_symbolProperties[10] = new SymbolProperty();
			_symbolProperties[10].name = NE_COLOR;
			_symbolProperties[10].type = SymbolPropertyType.VALUE;

			_symbolProperties[11] = new SymbolProperty();
			_symbolProperties[11].name = NE_ALPHA;
			_symbolProperties[11].type = SymbolPropertyType.VALUE;

			_symbolProperties[12] = new SymbolProperty();
			_symbolProperties[12].name = NE_WIDTH;
			_symbolProperties[12].type = SymbolPropertyType.VALUE;

			_symbolProperties[13] = new SymbolProperty();
			_symbolProperties[13].name = NE_LENGTH;
			_symbolProperties[13].type = SymbolPropertyType.VALUE;

			
			_symbolProperties[14] = new SymbolProperty();
			_symbolProperties[14].name = E_COLOR;
			_symbolProperties[14].type = SymbolPropertyType.VALUE;

			_symbolProperties[15] = new SymbolProperty();
			_symbolProperties[15].name = E_ALPHA;
			_symbolProperties[15].type = SymbolPropertyType.VALUE;

			_symbolProperties[16] = new SymbolProperty();
			_symbolProperties[16].name = E_WIDTH;
			_symbolProperties[16].type = SymbolPropertyType.VALUE;

			_symbolProperties[17] = new SymbolProperty();
			_symbolProperties[17].name = E_LENGTH;
			_symbolProperties[17].type = SymbolPropertyType.VALUE;

			
			_symbolProperties[18] = new SymbolProperty();
			_symbolProperties[18].name = SE_COLOR;
			_symbolProperties[18].type = SymbolPropertyType.VALUE;

			_symbolProperties[19] = new SymbolProperty();
			_symbolProperties[19].name = SE_ALPHA;
			_symbolProperties[19].type = SymbolPropertyType.VALUE;

			_symbolProperties[20] = new SymbolProperty();
			_symbolProperties[20].name = SE_WIDTH;
			_symbolProperties[20].type = SymbolPropertyType.VALUE;

			_symbolProperties[21] = new SymbolProperty();
			_symbolProperties[21].name = SE_LENGTH;
			_symbolProperties[21].type = SymbolPropertyType.VALUE;

			
			_symbolProperties[22] = new SymbolProperty();
			_symbolProperties[22].name = S_COLOR;
			_symbolProperties[22].type = SymbolPropertyType.VALUE;

			_symbolProperties[23] = new SymbolProperty();
			_symbolProperties[23].name = S_ALPHA;
			_symbolProperties[23].type = SymbolPropertyType.VALUE;

			_symbolProperties[24] = new SymbolProperty();
			_symbolProperties[24].name = S_WIDTH;
			_symbolProperties[24].type = SymbolPropertyType.VALUE;

			_symbolProperties[25] = new SymbolProperty();
			_symbolProperties[25].name = S_LENGTH;
			_symbolProperties[25].type = SymbolPropertyType.VALUE;

			
			_symbolProperties[26] = new SymbolProperty();
			_symbolProperties[26].name = SW_COLOR;
			_symbolProperties[26].type = SymbolPropertyType.VALUE;

			_symbolProperties[27] = new SymbolProperty();
			_symbolProperties[27].name = SW_ALPHA;
			_symbolProperties[27].type = SymbolPropertyType.VALUE;

			_symbolProperties[28] = new SymbolProperty();
			_symbolProperties[28].name = SW_WIDTH;
			_symbolProperties[28].type = SymbolPropertyType.VALUE;

			_symbolProperties[29] = new SymbolProperty();
			_symbolProperties[29].name = SW_LENGTH;
			_symbolProperties[29].type = SymbolPropertyType.VALUE;

			
			_symbolProperties[30] = new SymbolProperty();
			_symbolProperties[30].name = W_COLOR;
			_symbolProperties[30].type = SymbolPropertyType.VALUE;

			_symbolProperties[31] = new SymbolProperty();
			_symbolProperties[31].name = W_ALPHA;
			_symbolProperties[31].type = SymbolPropertyType.VALUE;

			_symbolProperties[32] = new SymbolProperty();
			_symbolProperties[32].name = W_WIDTH;
			_symbolProperties[32].type = SymbolPropertyType.VALUE;

			_symbolProperties[33] = new SymbolProperty();
			_symbolProperties[33].name = W_LENGTH;
			_symbolProperties[33].type = SymbolPropertyType.VALUE;

			
			_symbolProperties[34] = new SymbolProperty();
			_symbolProperties[34].name = NW_COLOR;
			_symbolProperties[34].type = SymbolPropertyType.VALUE;

			_symbolProperties[35] = new SymbolProperty();
			_symbolProperties[35].name = NW_ALPHA;
			_symbolProperties[35].type = SymbolPropertyType.VALUE;

			_symbolProperties[36] = new SymbolProperty();
			_symbolProperties[36].name = NW_WIDTH;
			_symbolProperties[36].type = SymbolPropertyType.VALUE;

			_symbolProperties[37] = new SymbolProperty();
			_symbolProperties[37].name = NW_LENGTH;
			_symbolProperties[37].type = SymbolPropertyType.VALUE;
		
			_symbolProperties[38] = new SymbolProperty();
			_symbolProperties[38].name = ALL_COLOR;
			_symbolProperties[38].type = SymbolPropertyType.VALUE;

			_symbolProperties[39] = new SymbolProperty();
			_symbolProperties[39].name = ALL_ALPHA;
			_symbolProperties[39].type = SymbolPropertyType.VALUE;
			
			
			super();
			
			stroke.fill = strokefill;
			stroke.scaleMode = LineScaleMode.NONE;
			
			n_dirStroke.fill = n_dirStrokefill;
			n_dirStroke.scaleMode = LineScaleMode.NONE;
			n_dirStroke.caps = CapsStyle.NONE;
			
			ne_dirStroke.fill = ne_dirStrokefill;
			ne_dirStroke.scaleMode = LineScaleMode.NONE;
			ne_dirStroke.caps = CapsStyle.NONE;
			
			e_dirStroke.fill = e_dirStrokefill;
			e_dirStroke.scaleMode = LineScaleMode.NONE;
			e_dirStroke.caps = CapsStyle.NONE;
			
			se_dirStroke.fill = se_dirStrokefill;
			se_dirStroke.scaleMode = LineScaleMode.NONE;
			se_dirStroke.caps = CapsStyle.NONE;
			
			s_dirStroke.fill = s_dirStrokefill;
			s_dirStroke.scaleMode = LineScaleMode.NONE;
			s_dirStroke.caps = CapsStyle.NONE;
			
			sw_dirStroke.fill = sw_dirStrokefill;
			sw_dirStroke.scaleMode = LineScaleMode.NONE;
			sw_dirStroke.caps = CapsStyle.NONE;
			
			w_dirStroke.fill = w_dirStrokefill;
			w_dirStroke.scaleMode = LineScaleMode.NONE;
			w_dirStroke.caps = CapsStyle.NONE;
			
			nw_dirStroke.fill = nw_dirStrokefill;
			nw_dirStroke.scaleMode = LineScaleMode.NONE;
			nw_dirStroke.caps = CapsStyle.NONE;
		}
		
		
		override protected function renderEntity(target:DisplayObject, spaceEntity:SpaceModelEntity, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void {
			//sprite.graphics.clear();
			var sprite:Sprite = target as Sprite;
			var SINPI4:Number = Math.sin( Math.PI * 0.25 );
			var COSPI4:Number = Math.cos( Math.PI * 0.25 );
		
			if (size!=0) {
				if (fill.alpha > 0) {
					sprite.graphics.beginFill( fill.color, fill.alpha );
				} else {
					sprite.graphics.endFill();
				}
				if (strokefill.alpha > 0) {
					sprite.graphics.lineStyle( stroke.thickness, strokefill.color, strokefill.alpha, false, LineScaleMode.NONE );
				} else {
					sprite.graphics.lineStyle();
				}
				sprite.graphics.drawCircle( spaceEntity.center.x, spaceEntity.center.y, size );
				if (fill.alpha > 0) {
					sprite.graphics.endFill();
				}
			}
			var x:Number = spaceEntity.center.x;
			var y:Number = spaceEntity.center.y;
			var rc:Number = size;
			
			if (w_length > 0) {
				sprite.graphics.lineStyle( w_dirStroke.thickness, w_dirStrokefill.color, w_dirStrokefill.alpha, false, w_dirStroke.scaleMode, w_dirStroke.caps );
				sprite.graphics.moveTo( x - rc, y );
				sprite.graphics.lineTo( x - rc - w_length, y );
			}
			if (e_length > 0) {
				sprite.graphics.lineStyle( e_dirStroke.thickness, e_dirStrokefill.color, e_dirStrokefill.alpha, false, e_dirStroke.scaleMode, e_dirStroke.caps );
				sprite.graphics.moveTo( x + rc, y );
				sprite.graphics.lineTo( x + rc + e_length, y );
			}
			if (n_length > 0) {
				sprite.graphics.lineStyle( n_dirStroke.thickness, n_dirStrokefill.color, n_dirStrokefill.alpha, false, n_dirStroke.scaleMode, n_dirStroke.caps );
				sprite.graphics.moveTo( x, y + rc );
				sprite.graphics.lineTo( x, y + rc + n_length );
			}
			if (s_length > 0) {
				sprite.graphics.lineStyle( s_dirStroke.thickness, s_dirStrokefill.color, s_dirStrokefill.alpha, false, s_dirStroke.scaleMode, s_dirStroke.caps );
				sprite.graphics.moveTo( x, y - rc );
				sprite.graphics.lineTo( x, y - rc - s_length);
			}
			rc = size * SINPI4;
			if (ne_length > 0) {
				sprite.graphics.lineStyle( ne_dirStroke.thickness, ne_dirStrokefill.color, ne_dirStrokefill.alpha, false, ne_dirStroke.scaleMode, ne_dirStroke.caps );
				sprite.graphics.moveTo( x + rc, y + rc);
				sprite.graphics.lineTo( x + rc + ne_length * SINPI4, y + rc + ne_length * SINPI4);
			}
			if (se_length > 0) {
				sprite.graphics.lineStyle( se_dirStroke.thickness, se_dirStrokefill.color, se_dirStrokefill.alpha, false, se_dirStroke.scaleMode, se_dirStroke.caps );
				sprite.graphics.moveTo( x + rc, y - rc);
				sprite.graphics.lineTo( x + rc + se_length * SINPI4, y - rc - se_length * SINPI4);
			}
			if (sw_length > 0) {
				sprite.graphics.lineStyle( sw_dirStroke.thickness, sw_dirStrokefill.color, sw_dirStrokefill.alpha, false, sw_dirStroke.scaleMode, sw_dirStroke.caps );
				sprite.graphics.moveTo( x - rc, y - rc);
				sprite.graphics.lineTo( x - rc - sw_length * SINPI4, y - rc - sw_length * SINPI4);
			}
			if (nw_length > 0) {
				sprite.graphics.lineStyle( nw_dirStroke.thickness, nw_dirStrokefill.color, nw_dirStrokefill.alpha, false, nw_dirStroke.scaleMode, nw_dirStroke.caps );
				sprite.graphics.moveTo( x - rc, y + rc);
				sprite.graphics.lineTo( x - rc - nw_length * SINPI4, y + rc + nw_length * SINPI4);
			}
		}
		
		override protected function setStaticProperty(property:SymbolProperty):void {
			switch (property.name) {
				case CENTER_SIZE: size = Number(property.manipulator.value) * 0.5; break;
				
				case N_WIDTH: n_dirStroke.thickness = Number(property.manipulator.value); break;
				case N_LENGTH: n_length = Number(property.manipulator.value); break;
				case NE_WIDTH: ne_dirStroke.thickness = Number(property.manipulator.value); break;
				case NE_LENGTH: ne_length = Number(property.manipulator.value); break;
				case E_WIDTH: e_dirStroke.thickness = Number(property.manipulator.value); break;
				case E_LENGTH: e_length = Number(property.manipulator.value); break;
				case SE_WIDTH: se_dirStroke.thickness = Number(property.manipulator.value); break;
				case SE_LENGTH: se_length = Number(property.manipulator.value); break;
				case S_WIDTH: s_dirStroke.thickness = Number(property.manipulator.value); break;
				case S_LENGTH: s_length = Number(property.manipulator.value); break;
				case SW_WIDTH: sw_dirStroke.thickness = Number(property.manipulator.value); break;
				case SW_LENGTH: sw_length = Number(property.manipulator.value); break;
				case W_WIDTH: w_dirStroke.thickness = Number(property.manipulator.value); break;
				case W_LENGTH: w_length = Number(property.manipulator.value); break;
				case NW_WIDTH: nw_dirStroke.thickness = Number(property.manipulator.value); break;
				case NW_LENGTH: nw_length = Number(property.manipulator.value); break;
				
				case CENTER_FILLCOLOR: fill.color = Number(property.manipulator.value); break;
				case CENTER_OUTLINECOLOR: strokefill.color = Number(property.manipulator.value); break;
				
				case N_COLOR: n_dirStrokefill.color = Number(property.manipulator.value); break;
				case N_ALPHA: n_dirStrokefill.alpha = Number(property.manipulator.value); break;
				case NE_COLOR: ne_dirStrokefill.color = Number(property.manipulator.value); break;
				case NE_ALPHA: ne_dirStrokefill.alpha = Number(property.manipulator.value); break;
				case E_COLOR: e_dirStrokefill.color = Number(property.manipulator.value); break;
				case E_ALPHA: e_dirStrokefill.alpha = Number(property.manipulator.value); break;
				case SE_COLOR: se_dirStrokefill.color = Number(property.manipulator.value); break;
				case SE_ALPHA: se_dirStrokefill.alpha = Number(property.manipulator.value); break;
				case S_COLOR: s_dirStrokefill.color = Number(property.manipulator.value); break;
				case S_ALPHA: s_dirStrokefill.alpha = Number(property.manipulator.value); break;
				case SW_COLOR: sw_dirStrokefill.color = Number(property.manipulator.value); break;
				case SW_ALPHA: sw_dirStrokefill.alpha = Number(property.manipulator.value); break;
				case W_COLOR: w_dirStrokefill.color = Number(property.manipulator.value); break;
				case W_ALPHA: w_dirStrokefill.alpha = Number(property.manipulator.value); break;
				case NW_COLOR: nw_dirStrokefill.color = Number(property.manipulator.value); break;
				case NW_ALPHA: nw_dirStrokefill.alpha = Number(property.manipulator.value); break;
				
				case CENTER_OUTLINEWIDTH: stroke.thickness = Number(property.manipulator.value); break;
				case CENTER_FILLALPHA: fill.alpha = Number(property.manipulator.value); break;
				case CENTER_OUTLINEALPHA: strokefill.alpha = Number(property.manipulator.value); break;
				
				case ALL_COLOR:
					n_dirStrokefill.color = Number(property.manipulator.value);
					ne_dirStrokefill.color = Number(property.manipulator.value);
					e_dirStrokefill.color = Number(property.manipulator.value);
					se_dirStrokefill.color = Number(property.manipulator.value);
					s_dirStrokefill.color = Number(property.manipulator.value);
					sw_dirStrokefill.color = Number(property.manipulator.value);
					w_dirStrokefill.color = Number(property.manipulator.value);
					nw_dirStrokefill.color = Number(property.manipulator.value); break;
				case ALL_ALPHA:
					n_dirStrokefill.alpha = Number(property.manipulator.value);
					ne_dirStrokefill.alpha = Number(property.manipulator.value);
					e_dirStrokefill.alpha = Number(property.manipulator.value);
					se_dirStrokefill.alpha = Number(property.manipulator.value);
					s_dirStrokefill.alpha = Number(property.manipulator.value);
					sw_dirStrokefill.alpha = Number(property.manipulator.value);
					w_dirStrokefill.alpha = Number(property.manipulator.value);
					nw_dirStrokefill.alpha = Number(property.manipulator.value); break;
			}
		}
		
		public function set interactive( value:Boolean ):void {
			_interactive = value;
		}
		
	}
	
}