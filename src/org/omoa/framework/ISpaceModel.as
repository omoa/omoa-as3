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

	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import org.omoa.spacemodel.SpaceModelEntity;
	
	
	/**
	 * Signalises the end of the loading process. You may now use this class as a SpaceModel.
	 */
	[Event(name = Event.COMPLETE, type = "flash.events.Event")]
	/**
	 * Signalises a change in the SpaceModel.
	 */
	[Event(name = Event.CHANGE, type = "flash.events.Event")]
	/**
	 * Signalises the pending deconstruction of a SpaceModel.
	 */
	[Event(name = Event.REMOVED, type = "flash.events.Event")]
	
	/**
	 * Implementations of this interface store (or process) spatial data.
	 * 
	 * @author Sebastian Specht
	 */

	public interface ISpaceModel extends IEventDispatcher {

		function get id():String;
		function get projection():IProjection;
		function get bounds():BoundingBox;
		function get geometryType():String;
		function get isComplete():Boolean;
		
		function iterator(type:String = null):ISpaceModelIterator;
		function attributes():IDataModel;
		function getIndexByAttribute(attribute:String, value:String):int;
		function entityCount():int;
		function entity(index:uint):SpaceModelEntity;
		function linkDataModel( model:IDataModel, dataDescription:Description = null ):void;

		function findById(id:String):SpaceModelEntity;
		
		function createPropertyDimension(withLabels:Boolean = false):ModelDimension;
	}
}