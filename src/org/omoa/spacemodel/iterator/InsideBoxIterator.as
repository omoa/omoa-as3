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
		
		public function InsideBoxIterator(entities:Vector.<SpaceModelEntity> = null) 
		{
			_originalEntities = entities.slice(0, entities.length);
			super(entities);
		}
		
		public function init( boundingBox:BoundingBox ):void {
			var sme:SpaceModelEntity;
			
			_entities.splice(0, _entities.length);
			
			for each (sme in _originalEntities) {
				// TODO: by configuration or by subclassing?
				//if (boundingBox.containsRect(sme.bounds as Rectangle)) {
				if (boundingBox.containsPoint(sme.center)) {
					_entities.push( sme );
				} /* else if (boundingBox.intersects(sme.bounds as Rectangle)) {
					_entities.push( sme );
				} */
			}
			
			reset();
		}
	}

}