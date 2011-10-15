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

	import flash.events.IEventDispatcher;
	import org.omoa.datamodel.Description;
	import org.omoa.datamodel.Datum;
	import org.omoa.datamodel.ModelDimension;
	
	/**
	 * Signalises the end of the loading process. You may now use this class.
	 */
	[Event(name = Event.COMPLETE, type = "flash.events.Event")]
	/**
	 * Signalises a change in the Model.
	 */
	[Event(name = Event.CHANGE, type = "flash.events.Event")]
	/**
	 * Signalises the pending deconstruction of a Model.
	 */
	[Event(name = Event.REMOVED, type = "flash.events.Event")]
	
	/**
	 * Implemetations of this interface store statistical, better non-spatial, data.
	 * 
	 * @author Sebastian Specht
	 */

	public interface IDataModel extends IEventDispatcher {

		function get id():String;
		function iterator(type:String):IDataModelIterator;
		function propertyDimensionCount():int;
		function propertyDimension(order:int):ModelDimension;
		function valueDimensionCount():int;
		function valueDimension(index:int = 0):ModelDimension;
		function createDescription( descriptionString:String = null ):Description;
		function getDatum(description:Description):Datum;
		function updateDatum(datum:Datum):void;
		function get isRemote():Boolean;
		function get isComplete():Boolean;
		function toString():String;
		
		function addDatum(datum:Datum):void;
		function addPropertyDimension(propertyDimension:ModelDimension):void;
		function addValueDimension(valueDimension:ModelDimension):void;

	}
}