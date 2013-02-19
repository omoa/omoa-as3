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
	
	import flash.display.DisplayObject;
	import flash.display.GraphicsEndFill;
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsStroke;
	import flash.display.IGraphicsData;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import org.omoa.framework.BoundingBox;
	import org.omoa.framework.SymbolProperty;
	import org.omoa.framework.SymbolPropertyType;
	import org.omoa.spacemodel.SpaceModelEntity;
	
	/**
	 * Simple Symbol that renders a SpaceModelEntities vector data (fill and outline, color and alpha)
	 * as graphics. This symbol is not interactive.
	 * 
	 * @author Sebastian Specht
	 */
	
	public class VectorSymbol extends AbstractSymbol {
		
		public const FILLCOLOR:String = "fillcolor";
		public const OUTLINECOLOR:String = "outlinecolor";
		public const FILLALPHA:String = "fillalpha";
		public const OUTLINEALPHA:String = "outlinealpha";
		public const OUTLINEWIDTH:String = "outlinewidth";
		
		private var graphics:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
		private var fill:GraphicsSolidFill = new GraphicsSolidFill(0xffffff);
		private var strokefill:GraphicsSolidFill = new GraphicsSolidFill();
		private var stroke:GraphicsStroke = new GraphicsStroke(1);
		
		private var noStroke:GraphicsStroke = new GraphicsStroke();
		private var noFill:GraphicsEndFill = new GraphicsEndFill();
		
		public function VectorSymbol() {			
			_symbolProperties = new Vector.<SymbolProperty>(5, true);
			
			_symbolProperties[0] = new SymbolProperty();
			_symbolProperties[0].name = FILLCOLOR;
			_symbolProperties[0].type = SymbolPropertyType.VALUE;
			
			_symbolProperties[1] = new SymbolProperty();
			_symbolProperties[1].name = OUTLINECOLOR;
			_symbolProperties[1].type = SymbolPropertyType.VALUE;
			
			_symbolProperties[2] = new SymbolProperty();
			_symbolProperties[2].name = FILLALPHA;
			_symbolProperties[2].type = SymbolPropertyType.VALUE;
			
			_symbolProperties[3] = new SymbolProperty();
			_symbolProperties[3].name = OUTLINEALPHA;
			_symbolProperties[3].type = SymbolPropertyType.VALUE;
			
			_symbolProperties[4] = new SymbolProperty();
			_symbolProperties[4].name = OUTLINEWIDTH;
			_symbolProperties[4].type = SymbolPropertyType.VALUE;
			super();
			
			stroke.fill = strokefill;
			stroke.scaleMode = LineScaleMode.NONE;
		}
		
		override public function setupEntity(parentSprite:Sprite, spaceEntity:SpaceModelEntity):DisplayObject {
			return null;
		}
		
		override public function prepareRender(parentSprite:Sprite):void {
			parentSprite.graphics.clear();
		}
		
		override protected function renderEntity(target:DisplayObject, spaceEntity:SpaceModelEntity, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void {
			var sprite:Sprite = target as Sprite;
			graphics.splice(0, graphics.length);
			if (fill.alpha > 0) {
				graphics.push( fill );
			} else {
				graphics.push( noFill );
			}
			if (strokefill.alpha > 0) {
				graphics.push( stroke );
			} else {
				graphics.push( noStroke );
			}
			graphics.push( spaceEntity.path );
			if (fill.alpha > 0) {
				graphics.push( noFill );
			}
			sprite.graphics.drawGraphicsData(graphics);
			//trace( "    VectorSymbol: Rendering " + spaceEntity.name);
		}
		
		override protected function setStaticProperty(property:SymbolProperty):void {
			switch (property.name) {
				case FILLCOLOR: fill.color = Number(property.manipulator.value); break;
				case OUTLINECOLOR: strokefill.color = Number(property.manipulator.value); break;
				case FILLALPHA: fill.alpha = Number(property.manipulator.value); break;
				case OUTLINEALPHA: strokefill.alpha = Number(property.manipulator.value); break;
				case OUTLINEWIDTH: stroke.thickness = Number(property.manipulator.value); break;
			}
		}
		
	}
	
}