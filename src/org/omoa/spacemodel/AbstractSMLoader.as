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

package org.omoa.spacemodel {
	
	import flash.utils.getDefinitionByName;
	import org.omoa.framework.ISpaceModelLoader;
	import org.omoa.spacemodel.loader.*;
	
	/**
	 * ...
	 * @author Sebastian Specht
	 */
	
	public class AbstractSMLoader extends SpaceModel implements ISpaceModelLoader {
		
		public function AbstractSMLoader() {
			super();
		}
		
		/**
		 * This setter allows to override the model id. Subclasses should respect an pre-set
		 * model id value and should not overwrite it during the loading process.
		 */
		public function setId(value:String):void{
			_id = value;
		}
		
		
		/**
		 * Implemented by subclass.
		 */
		public function load( url:String, parameters:Object=null ):void {
			throw new Error( "Needs to be implemented by a Loader-Subclass." );
		}
		
		/**
		 * Implemented by subclass.
		 */
		public function initialise( data:* ):void {
			throw new Error( "Needs to be implemented by a Loader-Subclass." );
		}
		
		/**
		 * Creates an ISpaceModelLoader instance.
		 * 
		 * @throws ReferenceError
		 * 
		 * @param	className	The name of the loader class, for example "Shapefile". If you
		 * 						want to create an instance of your own loader subclass you need
		 * 						to include the package.
		 * @param	name	This will set the id property of the model.
		 * @return	Returns the ISpaceModelLoader instance or throws an ReferenceError.
		 */
		public static function create(className:String, name:String=null):ISpaceModelLoader {
			
			// we need to "mention" the classes for inclusion at compile time
			Shapefile;
			AsmaSpaceXml;
			RasterSpaceModel;
			
			var loaderClass:Class;
			var loader:ISpaceModelLoader;
			
			// create loader
			try {
				// try loading from omoa loaders package first
				loaderClass = getDefinitionByName( "org.omoa.spacemodel.loader." + className ) as Class;
				if (!loaderClass) {
					loaderClass = getDefinitionByName( className ) as Class;
				}
				if (loaderClass) {
					loader = new loaderClass() as ISpaceModelLoader;
					loader.setId(name);
				}
			} catch (e:ReferenceError) {
				e.message = "SpaceModelLoader class '" + className + "' could not be loaded. " + e.message;
				throw e;
			}
			
			return loader;
		}
		
	}

}