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
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsStroke;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.omoa.framework.SymbolProperty;
	import org.omoa.framework.SymbolPropertyType;
	import org.omoa.framework.BoundingBox;
	import org.omoa.spacemodel.SpaceModelEntity;
	
	/**
	 * ...
	 * @author Sebastian Specht
	 */
	
	public class PointSymbolEntity extends AbstractSymbol {
		
		public const FILLCOLOR:String = "fillcolor";
		public const OUTLINECOLOR:String = "outlinecolor";
		public const FILLALPHA:String = "fillalpha";
		public const OUTLINEALPHA:String = "outlinealpha";
		public const OUTLINEWIDTH:String = "outlinewidth";
		public const SIZE:String = "size";
		public const SHAPE:String = "shape";
		
		public const VAL_SHAPE_CIRCLE:String = "circle";
		public const VAL_SHAPE_SQUARE:String = "square";

		private var fill:GraphicsSolidFill = new GraphicsSolidFill(0xffffff);
		private var strokefill:GraphicsSolidFill = new GraphicsSolidFill();
		private var stroke:GraphicsStroke = new GraphicsStroke(1);
		
		private var size:Number = 1;
		private var shape:String = VAL_SHAPE_CIRCLE;
		
		public function PointSymbolEntity() {
			_symbolProperties = new Vector.<SymbolProperty>(7, true);
			
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
			
			_symbolProperties[5] = new SymbolProperty();
			_symbolProperties[5].name = SIZE;
			_symbolProperties[5].type = SymbolPropertyType.VALUE;
			
			_symbolProperties[6] = new SymbolProperty();
			_symbolProperties[6].name = SHAPE;
			_symbolProperties[6].type = SymbolPropertyType.VALUE;
			
			super();
			
			stroke.fill = strokefill;
			stroke.scaleMode = LineScaleMode.NONE;
			
			_entities = true;
			_interactive = false;
			_transform = false;
			_rescale = true;
			_recenter = true;
			
			
		}
		
		
		override public function setupEntity(parentSprite:Sprite, spaceEntity:SpaceModelEntity):DisplayObject {
			var entitySprite:Sprite = new Sprite();
			entitySprite.name = spaceEntity.id;
			parentSprite.addChild( entitySprite );
			return entitySprite;
		}
		
		
		override protected function renderEntity(target:DisplayObject, spaceEntity:SpaceModelEntity, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void {
			var sprite:Sprite = target as Sprite;
			sprite.graphics.clear();
			//var center:Point = spaceEntity.center;

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
				
				switch (shape) {
					case VAL_SHAPE_CIRCLE:
						sprite.graphics.drawCircle( 0, 0, size );
						break;
					case VAL_SHAPE_SQUARE:
						sprite.graphics.drawRect( -size, -size, size * 2, size * 2);
						break;
				}
				if (fill.alpha > 0) {
					sprite.graphics.endFill();
				}
				var p:Point = transformation.transformPoint( spaceEntity.center );
				target.x = p.x;
				target.y = p.y;
			}
		}
		
		override public function rescale(target:DisplayObject, spaceEntity:SpaceModelEntity, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void {
			var p:Point = transformation.transformPoint( spaceEntity.center );
			target.x = p.x;
			target.y = p.y;
		}
		
		override public function recenter(target:DisplayObject, spaceEntity:SpaceModelEntity, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void {
			var p:Point = transformation.transformPoint( spaceEntity.center );
			target.x = p.x;
			target.y = p.y;	
		}
		
		override protected function setStaticProperty(property:SymbolProperty):void {
			switch (property.name) {
				case SIZE: size = Number(property.manipulator.value)*0.5; break;
				case FILLCOLOR: fill.color = Number(property.manipulator.value); break;
				case OUTLINECOLOR: strokefill.color = Number(property.manipulator.value); break;
				case OUTLINEWIDTH: stroke.thickness = Number(property.manipulator.value); break;
				case SHAPE: shape = String(property.manipulator.value); break;
				case FILLALPHA: fill.alpha = Number(property.manipulator.value); break;
				case OUTLINEALPHA: strokefill.alpha = Number(property.manipulator.value); break;
			}
		}
		
		public function set needsInteractivity( value:Boolean ):void {
			_interactive = value;
		}
		
	}
	
}