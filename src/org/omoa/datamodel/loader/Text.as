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
	import org.omoa.datamodel.GenericDataModel;
	import org.omoa.framework.ModelDimension;
	import org.omoa.framework.ModelDimensionType;
	
	/**
	 * ...
	 * @author Sebastian Specht
	 */
	
	public class Text extends AbstractDMLoader {
		
		private var loader:URLLoader
		private var _parameters:Object;
		
		public function Text(){
			super();
		}
		
		override public function load(url:String, parameters:Object = null):void {
			_parameters = parameters;
			
			/*
			var settings:Object = {
				linebreak:"\n",
				separator:",",
				hasHeader:true,
				values: [
				{
				  id:'commuter',
				  unit:'Commuter',
				  type:2
				}
				],
				properties: [
				{
				  id: 'ID1',
				  name: 'Ursprung',
				  unit:'ID',
				  type: 'ID',
				  column: 0
				},
				{
				  id: 'ID2',
				  name: 'Pendelbeziehung',
				  unit:'ID',
				  type: 'ID',
				  column: 1
				},
				{
				  id: 'indicator',
				  name: 'Indikator',
				  unit:'',
				  type: 0,
				  column: false,
				  codes:['ein','aus','saldo'],
				  columns:[
					{
					  id:'ein',
					  column:2
					},
					{
					  id:'aus',
					  column:3
					},
					{
					  id:'saldo',
					  column:4
					}
				  ]
				} 
				]
			};
			*/
			
			// before we load: parse parameters
			var dim:Object;
			var type:String;
			var hasNonNumericValues:Boolean = false;
			for each (dim in _parameters.values) {
				type = parseType(dim.type);
				switch (type) {
					case ModelDimensionType.ENTITY_ID:
					case ModelDimensionType.NOMINAL:
					case ModelDimensionType.ORDINAL:
						hasNonNumericValues = true;
					break;
					
				}
			}
			model = new GenericDataModel(_id);
			/*
			if (hasNonNumericValues) {
				model = new GenericDataModel(_id);
			} else {
				model = new DataModel(_id);
			}
			*/
			
			if (url){
				loader = new URLLoader();
				loader.addEventListener(Event.COMPLETE, loadComplete);
				loader.addEventListener(IOErrorEvent.IO_ERROR, error);
				loader.load(new URLRequest(url));
			}
		}
		
		private function loadComplete(e:Event):void {
			if (loader){
				initialize(loader.data);
				_isComplete = true;
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		private function error(e:Event):void {
			//trace("CsvLoader: Load error" + e);
			//dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, ("CsvLoader: Load error " + e)));
			throw new Error(e.toString());
		}
		
		private function parseType(value:*):String {
			var type:String = "";
			switch (String(value)){
				case "ID": 
					type = ModelDimensionType.ENTITY_ID;
					break;
				case "id": 
					type = ModelDimensionType.ENTITY_ID;
					break;
				case "0": 
					type = ModelDimensionType.NOMINAL;
					break;
				case "1": 
					type = ModelDimensionType.ORDINAL;
					break;
				case "2": 
					type = ModelDimensionType.RATIO;
					break;
				case "nominal": 
					type = ModelDimensionType.NOMINAL;
					break;
				case "ordinal": 
					type = ModelDimensionType.ORDINAL;
					break;
				case "ratio": 
					type = ModelDimensionType.RATIO;
					break;
				case "interval": 
					type = ModelDimensionType.INTERVAL;
					break;
				default: 
					type = ModelDimensionType.RATIO;
			}
			return type;
		}
		
		override public function initialize(data:*):void {
			var t:Date = new Date();
			var file:String = data as String;
			var id:String;
			var type:String;
			var name:String;
			var unit:String;
			var record:Array;
			var column:int;
			var header:Array;
			var valueColumns:Array;
			var valueColumn:int;
			var dimOrder:int = 0;
			var i:int = 0;
			
			// splite file by lines
			var lines:Array = file.split(_parameters.linebreak);
			file = null;
			
			if (lines.length < 3) {
				throw new Error("Text-Loader: wrong linebreak parameter\r"+lines[0]);
			}
			// extract header
			if (_parameters.hasHeader){
				header = String(lines.shift()).split(_parameters.separator);
			}
			
			// split lines into records
			var records:Vector.<Array> = parseFile( lines );
			lines = null;
			
			var propertyColumns:Array = new Array();
			
			for each (var dim:Object in _parameters.properties){
				id = dim.id;
				if (!id){
					id = "Dim" + (Math.round(Math.random() * 100000));
				}
				name = dim.name;
				if (!name){
					name = id;
				}
				type = parseType(dim.type);
				
				unit = dim.unit;
				
				if (dim.columns){
					valueColumns = dim.columns;
					column = NaN;
				} else {
					column = parseInt(String(dim.column));
					propertyColumns[dimOrder] = column;
				}
				
				var codes:Array;
				
				if (dim.codes && (dim.codes is Array)){
					// die Codes werden geliefert
					codes = dim.codes;
				} else {
					// die Codes müssen extrahiert werden
					codes = new Array();
					var code:String;
					var codeIndex:Object = new Object();
					
					for each (record in records){
						code = record[column];
						// faster than if (!())
						if (codeIndex[code]){
						} else {
							codeIndex[code] = 1;
							codes.push(code);
						}
					}
					codeIndex = null;
				}
				model.addPropertyDimension(new ModelDimension(id, name, unit, type, codes));
				codes = null;
				dimOrder++;
			}
			
			//trace( propertyColumns );
			var value:Datum = new Datum();
			if (!valueColumns) {
				valueColumns = new Array();
			}
			
			for each (dim in _parameters.values){
				id = dim.id;
				if (!id){
					id = "Dim" + (Math.round(Math.random() * 100000));
				}
				name = dim.name;
				if (!name){
					name = id;
				}
				type = parseType(dim.type);
				unit = dim.unit;
				
				model.addValueDimension(new ModelDimension(id, name, unit, type, null, null, true));
				
				column = NaN;
				column = parseInt(String(dim.column));
				
				if (isNaN(column)){
					//
				} else {
					valueColumn = column;
				}
				
				value.description = model.createDescription();
				value.description.selectByCode(value.description.valueDimensionOrder(), id);
				valueColumns.push( dim ); 
				//trace ( value.toString() );
				
				// Im Moment rechnen wir nur mit einer value dimension
				//break;
			}
			
			
			
			//store data
			
			if (valueColumns){
				var simplePropDimCount:int = propertyColumns.length;
				var valueCol:Object;
				for each (record in records){
					for (i = 0; i <= simplePropDimCount; i++){
						value.description.selectByCode(i, record[propertyColumns[i - 1]]);
					}
					
					for each (valueCol in valueColumns){
						value.description.selectByCode(i, valueCol.id);
						value.value = record[int(valueCol.column)];
						model.addDatum(value);
					}
					
				}
			}
		
		}
		
		private function parseFile(file:Array):Vector.<Array> {
			var records:Vector.<Array> = new Vector.<Array>(file.length, true);
			var record:Array;
			var line:String;
			var column:int;
			var separator:String = _parameters.separator;
			var i:int = 0;
			
			for each (line in file){
				records[i++] = line.split(separator);
			}
			
			return records;
		}
	
	}

}