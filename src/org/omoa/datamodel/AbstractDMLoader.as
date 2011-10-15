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

package org.omoa.datamodel {
	
	import flash.events.EventDispatcher;
	import flash.utils.getDefinitionByName;
	import org.omoa.datamodel.Description;
	import org.omoa.datamodel.Datum;
	import org.omoa.datamodel.loader.SMEAttributeDataModel;
	import org.omoa.datamodel.loader.Text;
	import org.omoa.datamodel.ModelDimension;
	import org.omoa.framework.IDataModel;
	import org.omoa.framework.IDataModelIterator;
	import org.omoa.framework.IDataModelLoader;
	
	/**
	* Subclasses need to initialise the storage core - the <code>model</code> property - 
	* in the initialisation phase. Classes that use subclasses of this class are expected
	* to check the initialisation status <code>isComplete</code> before they
	* access the underlying model.
	* 
	* @author Sebastian Specht
	*/

	public class AbstractDMLoader extends EventDispatcher implements IDataModelLoader, IDataModel {
				
		// the storage core
		protected var model:IDataModel;
		
		// these properties are not proxied to the model
		protected var _id:String;
		protected var _isComplete:Boolean = false;
		protected var _isRemote:Boolean = false;

		public function AbstractDMLoader() {
			super();
		}

		public function load(url:String, parameters:Object = null):void {
			throw new Error("Must be implemented by Loader subclass");
		}
		
		public function initialise(data:*):void {
			throw new Error("Must be implemented by Loader subclass");
		}
		
		public function setId(value:String):void {
			_id = value;
		}
		
		/**
		 * Creates an IDataModelLoader instance.
		 * 
		 * @throws ReferenceError
		 * 
		 * @param	className	The name of the loader class, for example "Text". If you
		 * 						want to create an instance of your own loader subclass you need
		 * 						to include the package.
		 * @param	name	This will set the id property of the model.
		 * @return	Returns the IDataModelLoader instance or throws an ReferenceError.
		 */
		public static function create(className:String, name:String=null):IDataModelLoader {
			
			// we need to "mention" the classes for inclusion at compile time
			Text;
			SMEAttributeDataModel;
			
			var loaderClass:Class;
			var loader:IDataModelLoader;
			
			// create loader
			try {
				// try loading from omoa loaders package first
				loaderClass = getDefinitionByName( "org.omoa.datamodel.loader." + className ) as Class;
				if (!loaderClass) {
					loaderClass = getDefinitionByName( className ) as Class;
				}
				if (loaderClass) {
					loader = new loaderClass() as IDataModelLoader;
					loader.setId(name);
				}
			} catch (e:ReferenceError) {
				e.message = "DataModelLoader class '" + className + "' could not be loaded. " + e.message;
				throw e;
			}
			
			return loader;
		}
		
		// These properties are not proxied
		
		public function get id():String {
			return _id;
		}
		
		public function get isRemote():Boolean {
			return _isRemote;
		}
		
		public function get isComplete():Boolean {
			return _isComplete;
		}
		
		// We proxy almost the complete org.omoa.framework.IDataModel
		
		public function iterator(type:String):IDataModelIterator {
			return model.iterator(type);
		}
		
		public function propertyDimensionCount():int {
			return model.propertyDimensionCount();
		}
		
		public function propertyDimension(order:int):ModelDimension {
			return model.propertyDimension(order);
		}
		
		public function valueDimensionCount():int {
			return model.valueDimensionCount();
		}
		
		public function valueDimension(index:int = 0):ModelDimension {
			return model.valueDimension(index);
		}
		
		public function createDescription(descriptionString:String = null):Description {
			return model.createDescription(descriptionString);
		}
		
		public function getDatum(description:Description):Datum {
			return model.getDatum(description);
		}
		
		public function updateDatum(datum:Datum):void {
			return model.updateDatum(datum);
		}
		
		public function addDatum(datum:Datum):void {
			model.addDatum(datum);
		}
		
		public function addPropertyDimension(propertyDimension:ModelDimension):void {
			model.addPropertyDimension(propertyDimension);
		}
		
		public function addValueDimension(valueDimension:ModelDimension):void {
			model.addValueDimension(valueDimension);
		}
		
		override public function toString():String {
			return model.toString();
		}


	}
}