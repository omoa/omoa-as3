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

package org.omoa.layer {

	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import org.omoa.framework.ILayer;
	import org.omoa.framework.ILegend;
	import org.omoa.framework.ISpaceModel;
	import org.omoa.framework.BoundingBox;
	
	/**
	 * This is an abstract implementation of the ILayer interface.
	 * 
	 * @author Sebastian Specht
	 *
	 */

	public class AbstractLayer extends EventDispatcher implements ILayer {

		protected var _legend:ILegend;
		protected var _spaceModel:ISpaceModel;
		
		protected var _id:String;
		protected var _type:String = "AbstractLayer";
		protected var _title:String;
		protected var _description:String;
		protected var _isSetUp:Boolean = false;

		public function AbstractLayer(id:String, spaceModel:ISpaceModel) {
			_id = id;
			_spaceModel = spaceModel;
		}

		public function get id():String {
			return _id;
		}

		public function get type():String {
			return _type;
		}

		public function get title():String {
			return _title;
		}

		public function get description():String {
			return _description;
		}
		
		public function get isSetUp():Boolean { return _isSetUp; }

		public function setSpaceModel(spacemodel:ISpaceModel):void {
			_spaceModel = spacemodel;
		}

		public function get spaceModel():ISpaceModel {
			return _spaceModel;
		}

		public function get legend():ILegend {
			return _legend;
		}
		
		public function setup(sprite:Sprite):void {
			throw new Error( "AbstractLayer.setup() must be implemented in subclass.");
		}
		
		public function render(sprite:Sprite, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void {
			throw new Error( "AbstractLayer.render() must be implemented in subclass.");
		}
		
		public function rescale(sprite:Sprite, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void {
			throw new Error( "AbstractLayer.rescale() must be implemented in subclass.");
		}
		
		public function recenter(sprite:Sprite, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void {
			throw new Error( "AbstractLayer.recenter() must be implemented in subclass.");
		}
		
		public function cleanup(sprite:Sprite):void {
			throw new Error( "AbstractLayer.cleanup() must be implemented in subclass.");
		}
		
		/**
		 * Creates an ILayer instance.
		 * 
		 * @throws ReferenceError
		 * 
		 * @param	className	The name of the loader class, for example "SymbolLayer". If you
		 * 						want to create an instance of your own loader subclass you need
		 * 						to include the package.
		 * @param	name	This will set the name/id property of the layer.
		 * @return	Returns the ISpaceModelLoader instance or throws an ReferenceError.
		 */
		public static function create(className:String, name:String, spacemodel:ISpaceModel):ILayer {
			
			var layerClass:Class;
			var layer:ILayer;
			
			// we need to "mention" the classes for inclusion at compile time
			SymbolLayer;
			ImageLayer;
			
			// create instance
			try {
				// try loading omoa layer first
				layerClass = getDefinitionByName( "org.omoa.layer." + className ) as Class;
				if (!layerClass) {
					layerClass = getDefinitionByName( className ) as Class;
				}
				if (layerClass) {
					layer = new layerClass( name, spacemodel );
				}
			} catch (e:ReferenceError) {
				e.message = "Layer class '" + className + "' could not be loaded. " + e.message;
				throw e;
			}
			
			return layer;
		}

	}
}