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


package org.omoa.datamodel.loader {
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import org.omoa.datamodel.AbstractDMLoader;
	import org.omoa.datamodel.DataModel;
	import org.omoa.framework.Datum;
	import org.omoa.framework.ModelDimension;
	import org.omoa.framework.ModelDimensionType;
	
	/**
	 * A compact proprietary XML based file format for multidimensional statistical data.
	 * Use like this:
	 * <code>map.createDataModel("modelID", "dataFile.xml", null, "XmlIfl");</code>
	 * 
	 * @author Sebastian Specht
	 */
	public class XmlIfl extends AbstractDMLoader {
		//private var xml:XML;
		private var loader:URLLoader
		
		public function XmlIfl() {
			super( );
		}
		
		override public function load( url:String, parameters:Object = null ):void {
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loadComplete );
			loader.addEventListener(IOErrorEvent.IO_ERROR, error );
			loader.load( new URLRequest(url) );
		}
		
		private function loadComplete( e:Event ):void {
			if (loader) {
				init( new XML( loader.data ) );
				dispatchEvent( new Event( Event.COMPLETE ) );
			}
		}
		
		private function parseCollection( collection:XMLList, dimensionOrder:int, value:Datum ):void {
			for each ( var data:XML in collection ) {
				if (data.hasSimpleContent()) {
					value.description.selectByCode( dimensionOrder, data.@i );
					value.value = parseFloat( data.toString() );
					model.addDatum( value );
					
				} else {
					value.description.selectByCode( dimensionOrder, data.@i );
					parseCollection( data.children(), dimensionOrder+1, value );
				}
			}
		}
		
		private function error(e:Event):void {
			trace( "IflXml: Load error" + e);
			dispatchEvent( new ErrorEvent(ErrorEvent.ERROR, false, false, ("IflXml: Load error " + e) ));
		}
		
		override public function initialize(data:*):void {
			init(data as XML);
		}
		
		private function init(xmlFile:XML):void {
			var type:String;
			var id:String;
			var countDimension:int;
			
			var xml:XML = xmlFile;
			
			//Model erzeugen
			id = xml.@id.toString();
			if (id == "") {
				id = xml.@name.toString();
			}
			if (id == "") {
				id = "DataModel" + (Math.round(Math.random()*100000));
			}
			
			// TODO: Richtiges Modell, abhängig vom Inhalt, erzeugen
			model = new DataModel(id);
			//model = new GenericDataModel(id);
			
			switch (xml.@type.toString()) {
				case "0":type = ModelDimensionType.NOMINAL; break;
				case "1":type = ModelDimensionType.ORDINAL; break;
				case "2":type = ModelDimensionType.RATIO; break;
				case "nominal":type = ModelDimensionType.NOMINAL; break;
				case "ordinal":type = ModelDimensionType.ORDINAL; break;
				case "ratio":type = ModelDimensionType.RATIO; break;
			}
			
			
			var model_id:String = id;
			
			// add PropertyDimensions
			for each ( var dim:XML in xml.dimension ) {
				countDimension++;
				
				var codes:Array = new Array();
				var labels:Array = new Array();
				
				// In case there is no code-list in the file it is built up
				if (dim.i.length()>0) {
					for each (var index:XML in dim.i) {
						codes.push ( index.toString() );
						if (index.@l.toString()!="") {
							labels.push( index.@l );
						}
					}
				} else {
					var dimLabel:String = "d" + (countDimension - 1);
					var indexValues:XMLList = xml.descendants( dimLabel ).@i;
					var indexBuilder:Object = new Object();
					for each (var i:XML in indexValues) {
						if (!indexBuilder[i.toString()]) {
							indexBuilder[i.toString()] = 1;
						}
					}
					for (var code:String in indexBuilder) {
						codes.push( code );
					}
				}
				
				if (labels.length < codes.length) {
					labels = null;
				}
				
				switch (dim.@type.toString()) {
					case "0":type = ModelDimensionType.NOMINAL; break;
					case "1":type = ModelDimensionType.ORDINAL; break;
					case "2":type = ModelDimensionType.RATIO; break;
					case "nominal":type = ModelDimensionType.NOMINAL; break;
					case "ordinal":type = ModelDimensionType.ORDINAL; break;
					case "ratio":type = ModelDimensionType.RATIO; break;
				}
				if (dim.@unit.toString() == "(ID)") {
					type = ModelDimensionType.ENTITY_ID;
				}
				id = dim.@id.toString();
				if (id == "") {
					id = dim.@name.toString();
				}
				var propDim:ModelDimension = new ModelDimension(id, dim.@name, dim.@unit, type, codes, labels);
				model.addPropertyDimension( propDim );
			}
			
			// add ONE value dimensions
			
			
			var valueDim:ModelDimension = new ModelDimension( model_id, xml.@name,
												xml.@unit, type );
			
			model.addValueDimension( valueDim );
			
			// add values
			var value:Datum = new Datum();
			value.description = model.createDescription();
			value.description.selectByCode( value.description.valueDimensionOrder(), model_id );

			parseCollection( xml.d0, 1, value );
		}
		
	}
	
}