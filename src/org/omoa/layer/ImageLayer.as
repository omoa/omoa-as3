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
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import org.omoa.framework.ISpaceModelIterator;
	import org.omoa.framework.BoundingBox;
	import org.omoa.spacemodel.loader.RasterSpaceModel;
	import org.omoa.spacemodel.SpaceModelEntity;
	
	/**
	 * Loads an image from a file/url and fits it into a bounding box.
	 * 
	 * @see org.omoa.spacemodel.RasterSpaceModel
	 * 
	 * @author Sebastian Specht
	 *
	 */

	public class ImageLayer extends AbstractLayer {
		
		/** 
		 * This Dictionary resolves the layer Sprites (that come from the mapframe)
		 * to the Dictionaries that resolves the SpaceModelEntity (raster tile) to
		 * the container Sprite.
		 */
		private var layerspriteToEntityDictionary:Dictionary;

		public function ImageLayer(id:String, spaceModel:RasterSpaceModel) {
			super( id, spaceModel );
			_type = "ImageLayer";
			
			_scalable = true;
			_interactive = false;
			
			layerspriteToEntityDictionary = new Dictionary(false);
		}
		
		
		/**
		 * Sets up a Bitmap for every raster tile (SpaceModelEntity) and fills it
		 * with the BitmapData from that raster tile. The Bitmap is transformed to fit the BoundingBox inside a
		 * container Sprite. This container Sprite receives the transformation matrix in render, rescale, recenter.
		 * 
		 * @param	sprite The Layer Sprite.
		 */
		override public function setup(sprite:Sprite):void {
			var i:ISpaceModelIterator = spaceModel.iterator();
			
			var entityToEntitySprite:Dictionary = new Dictionary(false);
			while (i.hasNext()) {
				var sme:SpaceModelEntity = i.next();
				var content:Sprite = new Sprite();
				
				/*
				// This is Debug Code. Draws the Bitmap-Bounds.
				content.graphics.lineStyle(0, 0xff0000);
				content.graphics.drawRect( sme.bounds.x, sme.bounds.y, sme.bounds.width, sme.bounds.height);
				*/
				
				var bitmap:Bitmap = new Bitmap( sme.bitmapData, "auto", true );
				bitmap.x = sme.bounds.minx;
				bitmap.y = sme.bounds.miny + sme.bounds.height;
				bitmap.width = sme.bounds.width;
				bitmap.height = sme.bounds.height;
				bitmap.scaleY = bitmap.scaleY * -1;
				
				content.addChild( bitmap );
				sprite.addChild( content );
				entityToEntitySprite[sme] = content;
			}
			
			layerspriteToEntityDictionary[sprite] = entityToEntitySprite;
			_isSetUp = true;
			
		}
		
		private function applyMatrix( sprite:Sprite, matrix:Matrix ):void {
			var entityToEntitySprite:Dictionary = layerspriteToEntityDictionary[sprite];
			for each (var content:Sprite in entityToEntitySprite) {
				content.transform.matrix = matrix;
			}
			
		}
		
		override public function render(sprite:Sprite, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void {
			applyMatrix( sprite, transformation);
		}
		
		override public function rescale(sprite:Sprite, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void {
			applyMatrix( sprite, transformation);
		}
		
		override public function recenter(sprite:Sprite, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void {
			applyMatrix( sprite, transformation);
		}
		
		override public function cleanup(sprite:Sprite):void {
			//TODO: implement
		}

	}
}