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
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import org.omoa.framework.SymbolProperty;
	import org.omoa.framework.SymbolPropertyType;
	import org.omoa.framework.BoundingBox;
	import org.omoa.spacemodel.SpaceModelEntity;
	
	/**
	 * A symbol that renders a text Label.
	 * 
	 * @author Sebastian Specht
	 *
	 */
	
	public class LabelSymbol extends AbstractSymbol {
		
		public const COLOR:String = "color";
		public const ALPHA:String = "alpha";	
		public const SIZE:String = "size";
		public const ALIGNMENT:String = "alignment";
		public const DISTANCE:String = "distance";
		
		private var style:TextFormat;
		private var alpha:Number = 1;
		private var distance:Number = 0;
		private var alignment:Number = 3;
		
		public function LabelSymbol() {
			_symbolProperties = new Vector.<SymbolProperty>(5, true);
			
			_symbolProperties[0] = new SymbolProperty();
			_symbolProperties[0].name = COLOR;
			_symbolProperties[0].type = SymbolPropertyType.VALUE;
			
			_symbolProperties[1] = new SymbolProperty();
			_symbolProperties[1].name = ALPHA;
			_symbolProperties[1].type = SymbolPropertyType.VALUE;
			
			_symbolProperties[2] = new SymbolProperty();
			_symbolProperties[2].name = SIZE;
			_symbolProperties[2].type = SymbolPropertyType.VALUE;
			
			_symbolProperties[3] = new SymbolProperty();
			_symbolProperties[3].name = ALIGNMENT;
			_symbolProperties[3].type = SymbolPropertyType.VALUE;
			
			_symbolProperties[4] = new SymbolProperty();
			_symbolProperties[4].name = DISTANCE;
			_symbolProperties[4].type = SymbolPropertyType.VALUE;
			
			super();
			
			_entities = true;
			_interactive = false;
			_transform = false;
			_recenter = true;
			_rescale = true;
			
			style = new TextFormat( "_sans", 12, 0x000000 );
			style.align = "left";
			style.bold = true;
		}
		
		override public function setupEntity(parentSprite:Sprite, spaceEntity:SpaceModelEntity):DisplayObject {
			var container:Sprite = new Sprite();
			container.name = spaceEntity.id;
			var tf:TextField = new TextField();
			tf.name = spaceEntity.id;
			tf.selectable = false;
			tf.mouseEnabled = false;
			tf.mouseWheelEnabled = false;
			tf.tabEnabled = false;
			tf.multiline = true;
			tf.wordWrap = false;
			//tf.border = true;
			tf.antiAliasType = AntiAliasType.NORMAL;// AntiAliasType.ADVANCED;
			container.addChild( tf );
			parentSprite.addChild( container );
			//trace( "TextField created for " + spaceEntity.name );
			return container;
		}
		
		override protected function renderEntity(target:DisplayObject, spaceEntity:SpaceModelEntity, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void {
			var container:Sprite = target as Sprite;
			container.cacheAsBitmap = true;
			var tf:TextField = container.getChildAt(0) as TextField;
			var x:Number = 0;
			var y:Number = 0;
			
			var xdistance:Number = distance;
			var ydistance:Number = distance;
				
			if (style.size>0 && alpha>0) {
				tf.visible = true;
				
				switch (alignment) {
					case 1:
					case 2:
					case 3:
					case 4:
					case 5:
						tf.autoSize = TextFieldAutoSize.LEFT;
					break;
					case 7:
					case 8:
					case 9:
					case 10:
					case 11:
						tf.autoSize = TextFieldAutoSize.RIGHT;
					break;
					case 6:
					case 12:
					case 0:
						tf.autoSize = TextFieldAutoSize.CENTER;
					break;
				}	
				
				tf.defaultTextFormat = style;
				tf.text = spaceEntity.name;
				tf.alpha = alpha;
				
				
				switch (alignment) {
					case 3:
					case 4:
					case 2:
						ydistance = 0;
						break;
					case 8:
					case 9:
					case 10:
						ydistance = 0;
						xdistance = distance * -1;
						break;
					case 11:
					case 12:
					case 1:
						xdistance = 0;
						ydistance = distance * -1;
						break;
					case 5:
					case 6:
					case 7:
						xdistance = 0;
						ydistance = distance;
						break;
				}
					
				// y
				switch (alignment) {
					case 3:
					case 9:
					case 0:
						y = tf.height * -0.5;
						break;
					case 2:
					case 10:
						y = tf.height * -0.7;
						break;
					case 12:
					case 11:
					case 1:
						y = tf.height * -1;
						break;
					case 4:
					case 8:
						y = tf.height * -0.2;
						break;
				}
				// x
				switch (alignment) {
					case 12:
					case 6:
					case 0:
						x = tf.width * -0.5;
						break;
					case 9:
					case 10:
					case 8:
					case 7:
					case 11:
						x = tf.width * -1;
						break;
				}
				
				tf.x = x + xdistance;
				tf.y = y + ydistance;
				
				var p:Point = transformation.transformPoint( spaceEntity.center );
				container.x = p.x;
				container.y = p.y;
				
			} else {
				tf.visible = false;
			}
		}
		
		override public function recenter(target:DisplayObject, spaceEntity:SpaceModelEntity, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void {
			var p:Point = transformation.transformPoint( spaceEntity.center );
			target.x = p.x;
			target.y = p.y;
		}
		
		override public function rescale(target:DisplayObject, spaceEntity:SpaceModelEntity, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void 
		{
			var p:Point = transformation.transformPoint( spaceEntity.center );
			target.x = p.x;
			target.y = p.y;
		}
		
		override protected function setStaticProperty(property:SymbolProperty):void {
			switch (property.name) {
				case DISTANCE: distance = Number(property.manipulator.value); break;
				case ALIGNMENT: alignment = Number(property.manipulator.value); break;
				case SIZE: style.size = Number(property.manipulator.value); break;
				case COLOR: style.color = Number(property.manipulator.value); break;
				case ALPHA: alpha = Number(property.manipulator.value); break;
			}
		}
		
		public function set interactive( value:Boolean ):void {
			_interactive = value;
		}
		
	}
	
}