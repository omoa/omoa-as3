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
	import org.omoa.spacemodel.SpaceModelEntity;
	
	/**
	 * Simple Symbol that renders a SpaceModelEntities vector data (fill and outline, color and alpha)
	 * into a Sprite. Use this Symbol if you need interaction.
	 */
	
	public class VectorSymbolEntity extends VectorSymbol {
		
		public function VectorSymbolEntity() {
			super();
			
			_entities = true;
			_interactive = false;
			_transform = true;
			_rescale = false;
			_recenter = false;
		}
		
		override public function setupEntity(parentSprite:Sprite, spaceEntity:SpaceModelEntity):DisplayObject {
			var entitySprite:Sprite = new Sprite();
			entitySprite.name = spaceEntity.id;
			parentSprite.addChild( entitySprite );
			return entitySprite;
		}
		
		override public function prepareRender(parentSprite:Sprite):void {
			var childSprite:Sprite;
			for (var i:int = 0; i < parentSprite.numChildren; i++) {
				childSprite = parentSprite.getChildAt(i) as Sprite;
				childSprite.graphics.clear();
			}
		}

		public function set needsInteractivity( value:Boolean ):void {
			_interactive = value;
		}
		
	}
	
}