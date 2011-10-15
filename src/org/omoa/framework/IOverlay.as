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
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	/**
	 * Implementaions of this interface provide a visualization of a SpaceModel
	 * on top of all other layers in a MapFrame, example: a coordinate grid.
	 * 
	 * @author Sebastian Specht
	 */
	
	public interface IOverlay {
		
		function get spaceModel():ISpaceModel;
		function get id():String;
		function get isSetup():Boolean;
		
		function setup( sprite:Sprite ):void;
		function render( sprite:Sprite, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void;
		function deconstruct( sprite:Sprite ):void;
	}
	
}