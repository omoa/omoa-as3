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

	import flash.display.Sprite;
	import flash.events.IEventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Transform;
	import flash.geom.Rectangle;
	
	/**
	 * Implementations of this interface provide a visualization of a SpaceModel in a MapFrame.
	 * 
	 * @author Sebastian Specht
	 */

	public interface ILayer extends IEventDispatcher{

		function get id():String;
		function get type():String;
		function get title():String;
		function get description():String;
		
		function get spaceModel():ISpaceModel;
		function setSpaceModel(spacemodel:ISpaceModel):void;
		
		function get legend():ILegend;
		
		function setup(sprite:Sprite):void;
		function isSetup(sprite:Sprite):Boolean;
		
		function render(sprite:Sprite, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void;
		function rescale(sprite:Sprite, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void;
		function recenter(sprite:Sprite, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void;
		
		function cleanup(sprite:Sprite):void;
		
	}
}