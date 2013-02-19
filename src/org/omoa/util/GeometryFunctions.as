package org.omoa.util 
{
	import flash.display.GraphicsPath;
	import flash.display.GraphicsPathCommand;
	import flash.geom.Point;
	import org.omoa.framework.BoundingBox;
	/**
	 * ...
	 * @author SKS
	 */
	public class GeometryFunctions {
		
		public function GeometryFunctions() {}
		
		/**
		 * Calculates the bounding values from a GraphicsPath object. This bounding box includes
		 * all existing points including control points of curves.
		 * @param	bb	A BoundingBox instance - will be overwritten.
		 * @param	path A GraphicsPath instance.
		 */
		public static function boundsFromPath( path:GraphicsPath, bb:BoundingBox ):void {
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
		
		/**
		 * Adds copies of the individual polygons from a composite polygon to the polys Vector.
		 * 
		 * @param	path	The composite polygon.
		 * @param	polys The result.
		 */
		public static function polygonsFromPath( path:GraphicsPath, polys:Vector.<GraphicsPath> ):void {
			var points:Vector.<Number> = path.data;
			var numCommands:int = path.commands.length;
			var currentPath:GraphicsPath;
			
			if (numCommands > 0) {
				var i:int = 0;
				var currentCommand:int = 0;
				while (currentCommand < numCommands) {
					switch ( path.commands[currentCommand] ) {
						case GraphicsPathCommand.LINE_TO:
							currentPath.lineTo( points[i++], points[i++] );
							break;
						case GraphicsPathCommand.MOVE_TO:
							if (currentPath && currentPath.commands) {
								polys.push( currentPath );
							}
							currentPath = new GraphicsPath( new Vector.<int>, new Vector.<Number> );
							currentPath.moveTo( points[i++], points[i++] );
							break;
						case GraphicsPathCommand.CURVE_TO:
							currentPath.curveTo( points[i++], points[i++], points[i++], points[i++] );
							break;
						case GraphicsPathCommand.CUBIC_CURVE_TO:
							currentPath.cubicCurveTo( points[i++], points[i++], points[i++], points[i++], points[i++], points[i++] );
							break;
						case GraphicsPathCommand.WIDE_LINE_TO:
							currentPath.wideLineTo( points[i++], points[i++] );
							i++; i++;
							// TODO: Test
							break;
						case GraphicsPathCommand.WIDE_MOVE_TO:
							if (currentPath && currentPath.commands) {
								polys.push( currentPath );
							}
							currentPath = new GraphicsPath( new Vector.<int>, new Vector.<Number> );
							currentPath.wideMoveTo( points[i++], points[i++] );
							i++; i++;
							break;
					}
					currentCommand++;
				}
				if (currentPath && currentPath.commands) {
					polys.push( currentPath );
				}
			}
		}
		
		public static function area( path:GraphicsPath ):Number {
			var area:Number = 0;
			var points:Vector.<Number> = path.data;
			var numPoints:int = path.data.length - 2;
			var pointIndex:int = 0;
			while (pointIndex < numPoints) {
				area += points[pointIndex] * points[pointIndex + 3] - points[pointIndex + 2] * points[pointIndex + 1];
				pointIndex += 2;
			}
			area += points[pointIndex] * points[1] - points[0] * points[pointIndex + 1];
			return area/-2;
		}
		
		public static function centroid( path:GraphicsPath, p:Point, area:Number = NaN ):void {
			var x:Number = 0, y:Number = 0;
			var c:Number = 0;
			if (p && path) {
				var points:Vector.<Number> = path.data;
				var numPoints:int = path.data.length - 2;
				var pointIndex:int = 0;
				if (isNaN(area)) {
					area = GeometryFunctions.area( path );
				}
				
				while (pointIndex < numPoints) {
					c = points[pointIndex] * points[pointIndex + 3] - points[pointIndex + 2] * points[pointIndex + 1];
					x += (points[pointIndex] + points[pointIndex + 2]) * c;
					y += (points[pointIndex+1] + points[pointIndex + 3]) 	* c;
					pointIndex += 2;
				}
				
				c = points[pointIndex] * points[1] - points[0] * points[pointIndex + 1];
				x += (points[pointIndex] + points[0]) * c;
				y += (points[pointIndex + 1] + points[1]) * c;
				p.x = x / (-6 * area);
				p.y = y / (-6 * area);
			}
		}
		
	}

}