// Copyright (C) 2013 Christopher "Kasoki" Kaster
// 
// This file is part of "nme-tiled". <http://github.com/Kasoki/nme-tiled>
// 
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
// THE SOFTWARE.
package de.kasoki.nmetiled;

import nme.geom.Point;
import nme.display.BitmapData;
import nme.geom.Rectangle;

class Tileset {

	/** The first GID this tileset has */
	public var firstGID:Int;

	/** The name of this tileset */
	public var name:String;

	/** The width of the tileset image */
	public var width(getTilesetWidth, null):Int;

	/** The height of the tileset image */
	public var height(getTilesetHeight, null):Int;

	/** The width of one tile */
	public var tileWidth:Int;

	/** The height of one tile */
	public var tileHeight:Int;
	
	/** Spacing between tiles */
	public var spacing:Int;
	
	/** Margins of tileset */
	public var margin:Int;

	/** All properties this Tileset contains */
	public var properties:Hash<String>;

	/** All tiles with special properties */
	public var propertyTiles:IntHash<PropertyTile>;

	/** The image of this tileset */
	public var image:TilesetImage;
	
	private function new(name:String, tileWidth:Int, tileHeight:Int, properties:Hash<String>, image:TilesetImage, ?spacing:Int = 0, ?margin:Int = 0) {
		this.name = name;
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;
		this.properties = properties;
		this.image = image;
		this.spacing = spacing;
		this.margin = margin;
	}
	
	/** Sets the first GID. */
	public function setFirstGID(gid:Int) {
		this.firstGID = gid;
	}
	
	/** Generates a new Tileset from the given Xml code */
	public static function fromGenericXml(content:String):Tileset {
		var xml = Xml.parse(content).firstElement();
		
		var name:String = xml.get("name");
		var tileWidth:Int = Std.parseInt(xml.get("tilewidth"));
		var tileHeight:Int = Std.parseInt(xml.get("tileheight"));
		
		var tileSpacing:Int = Helper.getIntIfExists(xml, "spacing", 0);
		var tileMargin:Int = Helper.getIntIfExists(xml, "margin", 0);
		
		var properties:Hash<String> = new Hash<String>();
		var propertyTiles:IntHash<PropertyTile> = new IntHash<PropertyTile>();
		var image:TilesetImage = null;
		
		for (child in xml.elements()) {
			if(Helper.isValidElement(child)) {
				if (child.nodeName == "properties") {
					properties = Helper.getProperties(child);
				}
				
				if (child.nodeName == "image") {
					var width = Std.parseInt(child.get("width"));
					var height = Std.parseInt(child.get("height"));
					
					image = new TilesetImage(child.get("source"), width, height);
				}
				
				if (child.nodeName == "tile") {
					var id:Int = Std.parseInt(child.get("id"));
					var properties:Hash<String> = new Hash<String>();
					
					for (element in child) {
						if(Helper.isValidElement(element)) {
							if (element.nodeName == "properties") {
								properties = Helper.getProperties(element);
							}
						}
					}
					
					propertyTiles.set(id, new PropertyTile(id, properties));
				}
			}
		}
		
		return new Tileset(name, tileWidth, tileHeight, properties, image, tileSpacing, tileMargin);
	}
	
	/** Returns the BitmapData of the given GID */
	public function getTileBitmapDataByGID(gid:Int):BitmapData {
		var bitmapData = new BitmapData(this.tileWidth, this.tileHeight, true, 0x000000);

		var texture:BitmapData = Helper.getBitmapData(this.image.source);
		var rect:Rectangle = new Rectangle(getTexturePositionByGID(gid).x * this.tileWidth,
			getTexturePositionByGID(gid).y * this.tileHeight, this.tileWidth, this.tileHeight);
		var point:Point = new Point(0, 0);

		bitmapData.copyPixels(texture, rect, point, null, null, true);

		return bitmapData;
	}

	/** Returns a Point which specifies the position of the gid in this tileset (Not in pixels!) */
	public function getTexturePositionByGID(gid:Int):Point {
		var number = gid - this.firstGID;

		return new Point(getInnerTexturePositionX(number), getInnerTexturePositionY(number));
	}

	/** Returns the inner x-position of a texture with given tileNumber */
	private function getInnerTexturePositionX(tileNumber):Int {
		return (tileNumber % Std.int(this.width / this.tileWidth));
	}
	
	/** Returns the inner y-position of a texture with given tileNumber */
	private function getInnerTexturePositionY(tileNumber):Int {
		return Std.int(tileNumber / Std.int(this.width / this.tileWidth));
	}
	
	private function getTilesetWidth():Int {
		return this.image.width;
	}
	
	private function getTilesetHeight():Int {
		return this.image.height;
	}
}
