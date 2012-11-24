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
	
package org.omoa.framework {

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.IEventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import org.omoa.framework.BoundingBox;
	import org.omoa.spacemodel.SpaceModelEntity;
	
	
	/**
	 * Implementations of this interface are responsible for the visualization
	 * of SpaceModel(Entities) for example inside a SymbolLayer.
	 * 
	 * @see org.omoa.layer.SymbolLayer SymbolLayer
	 * 
	 * @author Sebastian Specht
	 */

	public interface ISymbol extends IEventDispatcher {
		
		function getPropertyNames():Array;
		function getProperty(propertyName:String):SymbolProperty;
		function setProperty(propertyName:String, manipulator:ISymbolPropertyManipulator):void;
		
		
		function get needsEntities():Boolean;
		function setupEntity(parentSprite:Sprite, spaceEntity:SpaceModelEntity):DisplayObject;
		
		function get interactive():Boolean;
		function get needsInteractivity():Boolean;
		
		function prepareRender(parentSprite:Sprite):void;
		function render(target:DisplayObject, spaceEntity:SpaceModelEntity, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void;
		function afterRender(parentSprite:Sprite):void;
		
		function get needsTransformation():Boolean;
		
		function get needsRescale():Boolean;
		function get needsRenderOnRescale():Boolean;
		function rescale(target:DisplayObject, spaceEntity:SpaceModelEntity, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void;
		
		function get needsRecenter():Boolean;
		function get needsRenderOnRecenter():Boolean;
		function recenter(target:DisplayObject, spaceEntity:SpaceModelEntity, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void;
		
		function updateValues(spaceEntity:SpaceModelEntity, property:SymbolProperty):void;

	}
}