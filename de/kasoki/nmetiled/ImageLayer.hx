package de.kasoki.nmetiled;

/**
 * ...
 * @author dj_pale
 */
class ImageLayer
{
	public var name:String;
	
	public var properties:Hash<String>;
	
	public var width:Int;
	
	public var height:Int;
	
	public var source:String;
	
	public function new(name:String, width:Int, height:Int, source:String, properties:Hash<String>) 
	{
		this.name = name;
		this.width = width;
		this.height = height;
		this.source = source;
		this.properties = properties;
	}
	
	public static function fromGenericXml(xml:Xml):ImageLayer {
		var name:String = xml.get("name");
		var width:Int = Std.parseInt(xml.get("width"));
		var height:Int = Std.parseInt(xml.get("height"));
		var props:Hash<String> = new Hash<String>();
		var source:String = "";
		
		for (child in xml) {
			if (Helper.isValidElement(child)) {
				if (child.nodeName == "properties")	{
					props = Helper.getProperties(child);
				}
				
				if (child.nodeName == "image") {
					source = child.get("source");
				}
			}
		}
		
		return new ImageLayer(name, width, height, source, props);
	}
}