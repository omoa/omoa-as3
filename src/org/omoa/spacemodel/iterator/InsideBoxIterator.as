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

package org.omoa.spacemodel.iterator {
	
	import flash.geom.Rectangle;
	import org.omoa.framework.BoundingBox;
	import org.omoa.spacemodel.*;
	
	/**
	 * Iterates over the entities of s SpaceModel that are inside a
	 * BoundingBox. At the moment the the center point of the entity is used
	 * for the inside / outside decision.
	 * 
	 * @author Sebastian Specht
	 */
	
	public class InsideBoxIterator extends SimpleIterator
	{
		private var _originalEntities:Vector.<SpaceModelEntity>;
		
		public static const CONTAINS_CENTER:int = 0;
		public static const CONTAINS_BOUNDS:int = 1;
		public static const INTERSECTS_BOUNDS:int = 2;
		
		public var strategy:int = 0;
		
		public function InsideBoxIterator(entities:Vector.<SpaceModelEntity> = null) 
		{
			_originalEntities = entities.slice(0, entities.length);
			super(entities);
		}
		
		public function init( boundingBox:BoundingBox ):void {
			var sme:SpaceModelEntity;
			
			_entities.splice(0, _entities.length);
			
			if (strategy == CONTAINS_CENTER) {
				for each (sme in _originalEntities) {
					if (boundingBox.containsPoint(sme.center)) {
						_entities.push( sme );
					}
				}
			} else if (strategy == CONTAINS_BOUNDS) {
				for each (sme in _originalEntities) {
					if (boundingBox.containsRect(sme.bounds as Rectangle)) {
						_entities.push( sme );
					}
				}
			} else if (strategy == INTERSECTS_BOUNDS) {
				for each (sme in _originalEntities) {
					if (boundingBox.intersects(sme.bounds as Rectangle)) {
						_entities.push( sme );
					}
				}
			}
			
			
			reset();
		}
	}

}