package org.omoa.util 
{
	import flash.display.GraphicsPath;
	import org.omoa.framework.BoundingBox;
	/**
	 * ...
	 * @author SKS
	 */
	public class GeometryFunctions {
		
		public function GeometryFunctions() {}
		
		/**
		 * 
		 * @param	bb	A BoundingBox instance - will be overwritten.
		 * @param	path A GraphicsPath instance.
		 */
		public static function boundsFromPath( bb:BoundingBox, path:GraphicsPath ):void {
			var val:Number, xmin:Number, xmax:Number, ymin:Number, ymax:Number;
			var i:int;
			var points:Vector.<Number> = path.data;
			var numPoints:int = points.length / 2;
			if (numPoints > 0) {
				xmin = xmax = points[0];
				ymin = ymax = points[1];
				for (i = 1; i < numPoints; i++) {
					val = points[i * 2];
					if (val > xmax) xmax = val;
					if (val < xmin) xmin = val;
					val = points[i * 2 + 1];
					if (val > ymax) ymax = val;
					if (val < ymin) ymin = val;
				}
				bb.minx = xmin;
				bb.maxx = xmax;
				bb.miny = ymin;
				bb.maxy = ymax;
			}
		}
		
	}

}