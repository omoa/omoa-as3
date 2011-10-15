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

package org.omoa.overlay {
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import org.omoa.framework.IOverlay;
	import org.omoa.framework.ISpaceModel;
	import org.omoa.framework.ISpaceModelIterator;
	import org.omoa.framework.ISymbol;
	import org.omoa.framework.BoundingBox;
	import org.omoa.spacemodel.iterator.InsideBoxIterator;
	import org.omoa.spacemodel.iterator.OutsideBoxIterator;
	import org.omoa.spacemodel.SpaceModelEntity;
	import org.omoa.symbol.PointSymbol;
	import org.omoa.symbol.PointSymbolEntity;
	
	
	/**
	 * Visualizes SpaceModelEntities, that are outside the map window, as PointSymbols / 
	 * PointSymbolEntities in the perimeter of the map frame.
	 * 
	 * @see org.omoa.framework.IOverlay IOverlay
	 * @see org.omoa.symbol.PointSymbol PointSymbol
	 * @see org.omoa.symbol.PointSymbolEntity PointSymbolEntity
	 * 
	 * @author Sebastian Specht
	 */
	
	public class PointSymbolOrbit implements IOverlay {
		
		private var _id:String;
		private var _spaceModel:ISpaceModel;
		private var _symbol:ISymbol;
		private var _isSetup:Boolean = false;
		
		private var entityDictionary:Dictionary;
		private var iterator:ISpaceModelIterator;
		private var outsideIterator:OutsideBoxIterator;
		private var insideIterator:InsideBoxIterator;
		
		private var blurShape:Shape;
		
		public var margin:Number = 0;
		
		public var blur:Boolean = false;
		
		public function PointSymbolOrbit( id:String, spaceModel:ISpaceModel, symbol:ISymbol ) {
			_id = id;
			_spaceModel = spaceModel;
			
			if (symbol is PointSymbol || symbol is PointSymbolEntity) {
				_symbol = symbol;
			} else {
				throw new Error( "PointSymbolOrbit can only handle PointSymbol or PointSymbolEntity");
			}
		}
		
		public function get spaceModel():ISpaceModel { return _spaceModel; }
		
		public function get id():String { return _id; }
		
		public function get isSetup():Boolean { return _isSetup; }
		
		public function setup(sprite:Sprite):void {
			var sme:SpaceModelEntity;
			
			outsideIterator = _spaceModel.iterator( "OutsideBoxIterator" ) as OutsideBoxIterator;
			if (_symbol is PointSymbol) {
				
			} else if (_symbol is PointSymbolEntity) {
				entityDictionary = new Dictionary();
				
				insideIterator = _spaceModel.iterator( "InsideBoxIterator" ) as InsideBoxIterator;
				
				if (blur) {
					blurShape = new Shape();
					var filters:Array = blurShape.filters;
					filters.push( new BlurFilter(16,16) );
					blurShape.filters = filters;
					sprite.addChild(blurShape);
				}
				
				iterator = _spaceModel.iterator();
				while (iterator.hasNext()) {
					sme = iterator.next();
					
					entityDictionary[sme] = _symbol.setupEntity(sprite, sme);
				}
				
				_isSetup = true;
			}
		}
		
		public function deconstruct(sprite:Sprite):void {
			sprite.removeChild( blurShape );
			for (var i:int = 0; i < sprite.numChildren; i++ ) {
				sprite.removeChildAt(i);
			}
		}
		
		public function render(sprite:Sprite, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void {
			var sme:SpaceModelEntity;
			var s:Sprite;
			
			if (displayExtent && sprite) {
				
				var smeProxy:SpaceModelEntity = new SpaceModelEntity();
				var frame:Rectangle = displayExtent.clone();
				if (margin > 0) {
					frame.inflate(margin * 2, margin * 2);
				}
				var invt:Matrix = transformation.clone();
				invt.invert();
		
				
				outsideIterator.init( viewportBounds );
				
				if (blur) {
					blurShape.graphics.clear();
					blurShape.graphics.beginFill(0xffffff, 1);
					blurShape.graphics.drawRect( frame.x-15, frame.y-15, frame.width+30, frame.height+30 );
					blurShape.graphics.drawRect( frame.x + 15, frame.y + 15, frame.width - 30, frame.height - 30 );
					blurShape.graphics.endFill();
				}
				
				
				//sprite.graphics.clear();
				//sprite.graphics.lineStyle( 5, 0x00000, 0.1 );
				//sprite.graphics.drawRect( frame.x, frame.y, frame.width, frame.height );
				//sprite.graphics.lineStyle( 0, 0x00000, 0.1 );
				var p:Point;
				var cp:Point = new Point();
				var p3:Point;
				var p4:Point = new Point();
				var bbCenter:Point = new Point();
				var pointFound:Boolean;
				var isEntity:Boolean = true;
				
				_symbol.prepareRender( sprite );
				
				if (_symbol is PointSymbol) {
					sprite.transform.matrix = transformation;
					isEntity = false;
				}
				
				while (outsideIterator.hasNext()) {
					sme = outsideIterator.next();
					
					smeProxy.id = sme.id;
					smeProxy.name = sme.name;
					smeProxy.attributes = sme.attributes;
					smeProxy.bounds = sme.bounds;
					smeProxy.path = sme.path;
					smeProxy.removeDescription( sme.getDescription(sme.getModelIDs()[0]) );
					smeProxy.addDescription( sme.getDescription(sme.getModelIDs()[0]) );
					
					
					p = transformation.transformPoint(sme.center);
					bbCenter.y = frame.top + frame.height * 0.5;
					bbCenter.x = frame.left + frame.width * 0.5;
					
					p3 = frame.topLeft;
					p4.x = frame.right;
					p4.y = frame.top;
					pointFound = doIntersect(p, bbCenter, p3, p4, cp);
					
					if (!pointFound) {
						p4.y = frame.bottom;
						p4.x = frame.left;
						pointFound = doIntersect(p, bbCenter, p3, p4, cp);
					}
					if (!pointFound) {
						p3 = frame.bottomRight;
						pointFound = doIntersect(p, bbCenter, p3, p4, cp);
					}
					if (!pointFound) {
						p4.y = frame.top;
						p4.x = frame.right;
						pointFound = doIntersect(p, bbCenter, p3, p4, cp);
					}	
					
					smeProxy.center = invt.transformPoint(cp);
					
					if (isEntity) {
						s = entityDictionary[sme] as Sprite;
						s.visible = true;
						_symbol.render( s, smeProxy, transformation );
						
					} else {
						_symbol.render( sprite, smeProxy, transformation );
					}
				}
				
				if (isEntity) {
					insideIterator.init( viewportBounds );
					while (insideIterator.hasNext()) {
						sme = insideIterator.next();
						s = entityDictionary[sme] as Sprite;
						s.visible = false;
					}
				}
			}
			
		}
		
		// Test, ob sich die Strecken p1p2 und p3p4 schneiden, p5 enthält, bei Rückgabewert "true" den Schnittpunkt
		private function doIntersect( p1:Point, p2:Point, p3:Point, p4:Point, p5:Point ):Boolean {
			// Der gute Paul Bourke hilft mal wieder
			// http://local.wasp.uwa.edu.au/~pbourke/geometry/lineline2d/
			
			var nenner:Number = (p4.y-p3.y)*(p2.x-p1.x)-(p4.x-p3.x)*(p2.y-p1.y);
			if (nenner==0) {
				return false;
			} else {
				var zaehlerA:Number = (p4.x-p3.x)*(p1.y-p3.y)-(p4.y-p3.y)*(p1.x-p3.x);
				var ua:Number = zaehlerA/nenner;
				
				//if (isNaN(ua)) {  // isNaN() is said to be slow
				if (ua!=ua) {
					return false;
				} else {
					if (ua>=0 && ua<=1) {
						var zaehlerB:Number = (p2.x-p1.x)*(p1.y-p3.y) - (p2.y-p1.y)*(p1.x-p3.x);
						var ub:Number = zaehlerB/nenner;
						if (ub >= 0 && ub <= 1) {
							p5.x = p1.x + ua * (p2.x - p1.x);
							p5.y = p1.y + ua * (p2.y - p1.y);
							return true;
						} else {
							return false;
						}
					} else {
						return false;
					}
				}
			}
		}
		
	}

}