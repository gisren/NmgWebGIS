////////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2010 ESRI
//
// All rights reserved under the copyright laws of the United States.
// You may freely redistribute and use this software, with or
// without modification, provided you include the original copyright
// and use restrictions.  See use restrictions in the file:
// <install location>/License.txt
//
////////////////////////////////////////////////////////////////////////////////
package widgets.exInterface.BufferAnalyse
{

import com.esri.ags.Graphic;
import com.esri.ags.geometry.Geometry;
import com.esri.ags.geometry.MapPoint;
import com.esri.ags.symbols.Symbol;

import flash.events.EventDispatcher;

[Bindable]
[RemoteClass(alias="widgets.toolBar.Search.SearchResult")]

public class BufferResult extends EventDispatcher
{
    public var title:String;
	
	public var layer:String;

    public var symbol:Symbol;

    public var content:String;

    public var point:MapPoint;

    public var link:String;
	
	public var link2:String;
	
	public var link3:String;

    public var geometry:Geometry;

    public var graphic:Graphic;
	
}

}
