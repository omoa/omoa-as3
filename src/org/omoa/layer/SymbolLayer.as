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

package org.omoa.layer {

	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import org.omoa.event.SymbolEvent;
	import org.omoa.framework.ISpaceModel;
	import org.omoa.framework.ISpaceModelIterator;
	import org.omoa.framework.ISymbol;
	import org.omoa.framework.BoundingBox;
	import org.omoa.spacemodel.SpaceModelEntity;
	
	[Event(name = SymbolEvent.CLICK, type = "org.omoa.event.SymbolEvent")]
	
	/**
	 * This layer visualizes a SpaceModel through one or more Symbols. 
	 * 
	 * @author Sebastian Specht
	 *
	 */

	public class SymbolLayer extends AbstractLayer {
		
		public var customIterator:ISpaceModelIterator;

		protected var _symbols:Vector.<ISymbol> = new Vector.<ISymbol>();
		
		private var layerSpriteToSymbol:Dictionary;
		private var symbolToSymbolSprite:Dictionary;
		private var symbolSpriteToEntityDictionary:Dictionary;
		
		private var SpaceModelEntityForSprite:Dictionary;
		
		private var entityDictionaries:Vector.<Dictionary>;
		
		private var _interactive:Boolean;

		public function SymbolLayer(id:String, spaceModel:ISpaceModel) {
			super(id, spaceModel);
			_type = "SymbolLayer";
			SpaceModelEntityForSprite = new Dictionary(true);
			layerSpriteToSymbol = new Dictionary(true);
			symbolSpriteToEntityDictionary = new Dictionary(true);
			entityDictionaries = new Vector.<Dictionary>();
		}

		public function addSymbol(symbol:ISymbol):void {
			_symbols.push( symbol );
			if (symbol.interactive) {
				_interactive = true;
			}
			// if we have been setup already, we need to
			// do it for the new symbol too
			for (var layerSprite:Object in layerSpriteToSymbol) {
				setup( layerSprite as Sprite );
				//TODO: The new Symbol won't display. How do we request a render?
				// Throw everything away and start over?
			}
		}
		
		public function countSymbols():int {
			return _symbols.length;
		}
		
		public function getSymbol(index:uint):ISymbol {
			if (index > 0 && index < _symbols.length) {
				return _symbols[index];
			} else {
				return null;
			}
		}
		
		override public function isSetup(sprite:Sprite):Boolean {
			return Boolean(layerSpriteToSymbol[sprite]);
		}
		
		override public function setup(sprite:Sprite):void {
			var symbol:ISymbol;
			
			var symbolToSymbolSprite:Dictionary;
			var count:int;
			
			if (_interactive) {
				sprite.mouseChildren = true;
				sprite.addEventListener( MouseEvent.MOUSE_UP, symbolClick );
			} else {
				sprite.mouseChildren = false;
			}
			
			
			// this should fail...
			symbolToSymbolSprite = layerSpriteToSymbol[sprite] as Dictionary;
			if (!symbolToSymbolSprite) {
				// ...instead create a symbolToSymbolSprite Dictionary
				symbolToSymbolSprite = new Dictionary(false);
				layerSpriteToSymbol[sprite] = symbolToSymbolSprite;
			}
			
			var symbolCount:int = 0;
			for each (symbol in _symbols) {
				//TODO: How to handle a change in the DataModel or a description?
				
				var symbolSprite:Sprite = symbolToSymbolSprite[symbol];
				
				// prevent setup from being executed twice per symbol and layer
				if (!symbolSprite) {
					
					symbolSprite = new Sprite();
					symbolSprite.name = sprite.name + "_symbol_" + symbolCount;
					sprite.addChild( symbolSprite );
					symbolToSymbolSprite[symbol] = symbolSprite;
					
					if (symbol.needsInteractivity) { 
						symbolSprite.mouseChildren = true;
						symbolSprite.mouseEnabled = true;
					} else {
						symbolSprite.mouseChildren = false;
						symbolSprite.mouseEnabled = false;
					}
					
					var entityToDisplayObjects:Dictionary = null;
					var displayObjectToEntity:Dictionary = null;
					
					
					// setup symbols with individual entites
					if (symbol.needsEntities) {
						var displayObjectForEntity:DisplayObject;
						var spaceEntity:SpaceModelEntity;
						
						entityToDisplayObjects = new Dictionary(true);
						displayObjectToEntity = new Dictionary(true);
						
						// setup uses the standard-iterator of the SpaceModel, not the custom iterator.
						// TODO: introduce a dedicated Setup-Iterator? 
						var iterator:ISpaceModelIterator = _spaceModel.iterator();
						
						iterator.reset();
						
						while (iterator.hasNext()) {
							spaceEntity = iterator.next();
							displayObjectForEntity = symbol.setupEntity( symbolSprite, spaceEntity );
							
							entityToDisplayObjects[spaceEntity] = displayObjectForEntity;
							displayObjectToEntity[displayObjectForEntity] = spaceEntity;
							
							//TODO: This ought to be managed by the symbols themself
							if (symbol.needsInteractivity && displayObjectForEntity is Sprite) {
								// setup interactivity only for Sprites
								var entityAsSprite:Sprite = displayObjectForEntity as Sprite;
								entityAsSprite.mouseEnabled = true;
							}
							
						}
					}
					
					symbolSpriteToEntityDictionary[symbolSprite] = entityToDisplayObjects;
				}
				
				symbolCount++;
				
			}
		}
		
		override public function render(sprite:Sprite, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void {
			var iterator:ISpaceModelIterator;
			var spaceEntity:SpaceModelEntity;
			var symbol:ISymbol;
			
			if (customIterator) {
				iterator = customIterator;
			} else {
				iterator = _spaceModel.iterator();
			}
			
			var symbolToSymbolSprite:Dictionary = layerSpriteToSymbol[sprite] as Dictionary;
			if (!symbolToSymbolSprite) {
				// TODO: This shouldn't happen: Setup hasn't been called yet. Bailing out.
				return;
			}
			
			for each (symbol in _symbols) {
				iterator.reset();
				
				var symbolSprite:Sprite = symbolToSymbolSprite[symbol];
				symbol.prepareRender(symbolSprite);
				
				if (symbol.needsEntities) {
					// render symbols with one DisplayObject per entity
					var entityDisplayObject:DisplayObject;
					var entityDictionary:Dictionary = symbolSpriteToEntityDictionary[symbolSprite];
					
					while (iterator.hasNext()) {
						spaceEntity = iterator.next();
						entityDisplayObject = entityDictionary[spaceEntity];
						symbol.render( entityDisplayObject, spaceEntity, displayExtent, viewportBounds, transformation );
					}
				} else {
					// render symbols with one DisplayObject for all entites
					while (iterator.hasNext()) {
						spaceEntity = iterator.next();
						symbol.render( symbolSprite, spaceEntity, displayExtent, viewportBounds, transformation );
					}
				}
				
				symbol.afterRender(symbolSprite);
				
				if (symbol.needsTransformation) {
					symbolSprite.transform.matrix = transformation;
				}
			}
		}
		
		override public function rescale(sprite:Sprite, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void {
			var iterator:ISpaceModelIterator;
			var spaceEntity:SpaceModelEntity;
			var symbol:ISymbol;
			
			if (customIterator) {
				iterator = customIterator;
			} else {
				iterator = _spaceModel.iterator();
			}
			
			var symbolToSymbolSprite:Dictionary = layerSpriteToSymbol[sprite] as Dictionary;
			if (!symbolToSymbolSprite) {
				// TODO: This shouldn't happen: Setup hasn't been called yet. Bailing out.
				return;
			}
			
			for each (symbol in _symbols) {
				
				var symbolSprite:Sprite = symbolToSymbolSprite[symbol];
				if (!symbolSprite) {
					// TODO: This shouldn't happen: Setup hasn't been called yet. Bailing out.
					trace( "SymbolLayer.rescale(): ERROR, no Sprite for Symbol existing." );
					break;
				}
				
				if (symbol.needsTransformation) {
					symbolSprite.transform.matrix = transformation;
				}
				
				if (symbol.needsRenderOnRescale) {
					symbol.prepareRender(symbolSprite);
				}
				
				if (symbol.needsEntities) {
					// rescale symbols with one DisplayObject per entity
					var entityDisplayObject:DisplayObject;
					var entityDictionary:Dictionary = symbolSpriteToEntityDictionary[symbolSprite];	
					
					if (symbol.needsRescale) {
						iterator.reset();
						if (symbol.needsRenderOnRescale) {
							while (iterator.hasNext()) {
								spaceEntity = iterator.next();
								entityDisplayObject = entityDictionary[spaceEntity];
								symbol.render( entityDisplayObject, spaceEntity, displayExtent, viewportBounds, transformation );
							}
						} else {
							while (iterator.hasNext()) {
								spaceEntity = iterator.next();
								entityDisplayObject = entityDictionary[spaceEntity];
								symbol.rescale( entityDisplayObject, spaceEntity, displayExtent, viewportBounds, transformation );
							}
						}
					}
				} else {
					// rescale symbols with one DisplayObject for all entites
					if (symbol.needsRescale) {
						iterator.reset();
						if (symbol.needsRenderOnRescale) {
							while (iterator.hasNext()) {
								spaceEntity = iterator.next();
								symbol.render( symbolSprite, spaceEntity, displayExtent, viewportBounds, transformation );
							}
						} else {
							while (iterator.hasNext()) {
								spaceEntity = iterator.next();
								symbol.rescale( symbolSprite, spaceEntity, displayExtent, viewportBounds, transformation );
							}
						}
					}
				}
				
				if (symbol.needsRenderOnRescale) {
					symbol.afterRender(symbolSprite);
				}
			}
		}
		
		override public function recenter(sprite:Sprite, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void {
			var iterator:ISpaceModelIterator;
			var spaceEntity:SpaceModelEntity;
			var symbol:ISymbol;
			
			if (customIterator) {
				iterator = customIterator;
			} else {
				iterator = _spaceModel.iterator();
			}
			
			var symbolToSymbolSprite:Dictionary = layerSpriteToSymbol[sprite] as Dictionary;
			if (!symbolToSymbolSprite) {
				// TODO: This shouldn't happen: Setup hasn't been called yet. Bailing out.
				return;
			}
			
			for each (symbol in _symbols) {
				var symbolSprite:Sprite = symbolToSymbolSprite[symbol];
				
				if (!symbolSprite) {
					// TODO: This shouldn't happen: Setup hasn't been called yet. Bailing out.
					trace( "SymbolLayer.recenter(): ERROR, no Sprite vor Symbol existing." );
					break;
				}
				
				if (symbol.needsTransformation) {
					symbolSprite.transform.matrix = transformation;
				}
				
				if (symbol.needsRenderOnRecenter) {
					symbol.prepareRender(symbolSprite);
				}
				
				if (symbol.needsEntities) {
					// recenter symbols with one DisplayObject per entity
					var entityDisplayObject:DisplayObject;
					var entityDictionary:Dictionary = symbolSpriteToEntityDictionary[symbolSprite];
					
					if (symbol.needsRecenter) {
						iterator.reset();
						if (symbol.needsRenderOnRecenter) {
							while (iterator.hasNext()) {
								spaceEntity = iterator.next();
								entityDisplayObject = entityDictionary[spaceEntity];
								symbol.render( entityDisplayObject, spaceEntity, displayExtent, viewportBounds, transformation );
							}	
						} else {
							while (iterator.hasNext()) {
								spaceEntity = iterator.next();
								entityDisplayObject = entityDictionary[spaceEntity];
								symbol.recenter( entityDisplayObject, spaceEntity, displayExtent, viewportBounds, transformation );
							}
						}
					}
				} else {
					// recenter symbols with one DisplayObject for all Entites
					if (symbol.needsRecenter) {
						iterator.reset();
						if (symbol.needsRenderOnRecenter) {
							while (iterator.hasNext()) {
								spaceEntity = iterator.next();
								symbol.render( symbolSprite, spaceEntity, displayExtent, viewportBounds, transformation );
							}
						} else {
							while (iterator.hasNext()) {
								spaceEntity = iterator.next();
								symbol.recenter( symbolSprite, spaceEntity, displayExtent, viewportBounds, transformation );
							}
						}
					}
				}
				
				if (symbol.needsRenderOnRecenter) {
					symbol.afterRender(symbolSprite);
				}
			}

		}
		
		override public function cleanup(sprite:Sprite):void {
			throw new Error( "NOT IMPLEMENTED.");
		}
		
		public function getEntityForSprite( displayObject:DisplayObject ):SpaceModelEntity {
			return spaceModel.findById(displayObject.name);
		}
		
		public function getSymbolForSprite( displayObject:DisplayObject ):SpaceModelEntity {
			return null;
		}
		
		private function symbolClick(e:MouseEvent):void {
			var se:SymbolEvent = new SymbolEvent( SymbolEvent.CLICK, e.bubbles, e.cancelable,
												e.localX, e.localY, e.target as InteractiveObject,
												e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta);
			
			if (e.target) {
				se.entity = spaceModel.findById(e.target.name);
			}
				
			if (se.entity) {
				dispatchEvent( se );
			}
		}

	}
}