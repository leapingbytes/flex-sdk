////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components
{
import flash.events.Event;
import spark.layouts.VerticalLayout;
import spark.layouts.supportClasses.LayoutBase;

[IconFile("VGroup.png")]

/**
 *  The VGroup container is an instance of the Group container 
 *  that uses the VerticalLayout class.  
 *  Do not modify the <code>layout</code> property. 
 *  Instead, use the properties of the VGroup class to modify the 
 *  characteristics of the VerticalLayout class.
 * 
 *  @mxml
 *
 *  <p>The <code>&lt;s:VGroup&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:VGroup
 *    <strong>Properties</strong>
 *    gap="6"
 *    horizontalAlign="left"
 *    paddingBottom="0"
 *    paddingLeft="0"
 *    paddingRight="0"
 *    paddingTop="0"
 *    requestedRowCount"-1"
 *    rowHeight="no default"
 *    variableRowHeight="true"
 *  /&gt;
 *  </pre>
 * 
 *  @see spark.layouts.VerticalLayout
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class VGroup extends Group
{
    include "../core/Version.as";
    
    /**
     *  Constructor. 
     *  Initializes the <code>layout</code> property to an instance of 
     *  the VerticalLayout class.
     * 
     *  @see spark.layouts.VerticalLayout
     *  @see spark.components.HGroup
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */  
    public function VGroup():void
    {
        super();
        super.layout = new VerticalLayout();
    }
    
    private function get verticalLayout():VerticalLayout
    {
        return VerticalLayout(layout);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  gap
    //----------------------------------

    [Inspectable(category="General")]

    /**
     *  @copy spark.layouts.VerticalLayout#gap
     * 
     *  @default 6
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get gap():int
    {
        return verticalLayout.gap;
    }

    /**
     *  @private
     */
    public function set gap(value:int):void
    {
        verticalLayout.gap = value;
    }
    
    //----------------------------------
    //  horizontalAlign
    //----------------------------------

    [Inspectable(category="General", enumeration="left,right,center,justify,contentJustify", defaultValue="left")]

    /**
     *  @copy spark.layouts.VerticalLayout#horizontalAlign
     *  
     *  @default "left"
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get horizontalAlign():String
    {
        return verticalLayout.horizontalAlign;
    }

    /**
     *  @private
     */
    public function set horizontalAlign(value:String):void
    {
        verticalLayout.horizontalAlign = value;
    }

    //----------------------------------
    //  paddingLeft
    //----------------------------------

    [Inspectable(category="General")]

    /**
     *  @copy spark.layouts.VerticalLayout#paddingLeft
     *  
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get paddingLeft():Number
    {
        return verticalLayout.paddingLeft;
    }

    /**
     *  @private
     */
    public function set paddingLeft(value:Number):void
    {
        verticalLayout.paddingLeft = value;
    }    
    
    //----------------------------------
    //  paddingRight
    //----------------------------------

    [Inspectable(category="General")]

    /**
     *  @copy spark.layouts.VerticalLayout#paddingRight
     *  
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get paddingRight():Number
    {
        return verticalLayout.paddingRight;
    }

    /**
     *  @private
     */
    public function set paddingRight(value:Number):void
    {
        verticalLayout.paddingRight = value;
    }    
    
    //----------------------------------
    //  paddingTop
    //----------------------------------

    [Inspectable(category="General")]

    /**
     *  @copy spark.layouts.VerticalLayout#paddingTop
     *  
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get paddingTop():Number
    {
        return verticalLayout.paddingTop;
    }

    /**
     *  @private
     */
    public function set paddingTop(value:Number):void
    {
        verticalLayout.paddingTop = value;
    }    
    
    //----------------------------------
    //  paddingBottom
    //----------------------------------

    [Inspectable(category="General")]

    /**
     *  @copy spark.layouts.VerticalLayout#paddingBottom
     *  
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get paddingBottom():Number
    {
        return verticalLayout.paddingBottom;
    }

    /**
     *  @private
     */
    public function set paddingBottom(value:Number):void
    {
        verticalLayout.paddingBottom = value;
    }    
    
    //----------------------------------
    //  rowCount
    //----------------------------------

    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  @copy spark.layouts.VerticalLayout#rowCount
     * 
     *  @default -1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get rowCount():int
    {
        return verticalLayout.rowCount;
    }
    
    //----------------------------------
    //  requestedRowCount
    //----------------------------------

    [Inspectable(category="General")]

    /**
     *  @copy spark.layouts.VerticalLayout#requestedRowCount
     * 
     *  @default -1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get requestedRowCount():int
    {
        return verticalLayout.requestedRowCount;
    }

    /**
     *  @private
     */
    public function set requestedRowCount(value:int):void
    {
        verticalLayout.requestedRowCount = value;
    }    
    
    //----------------------------------
    //  rowHeight
    //----------------------------------
    
    [Inspectable(category="General")]

    /**
     *  @copy spark.layouts.VerticalLayout#rowHeight
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get rowHeight():Number
    {
        return verticalLayout.rowHeight;
    }

    /**
     *  @private
     */
    public function set rowHeight(value:Number):void
    {
        verticalLayout.rowHeight = value;
    }

    //----------------------------------
    //  variableRowHeight
    //----------------------------------

    [Inspectable(category="General")]

    /**
     *  @copy spark.layouts.VerticalLayout#variableRowHeight
     * 
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get variableRowHeight():Boolean
    {
        return verticalLayout.variableRowHeight;
    }

    /**
     *  @private
     */
    public function set variableRowHeight(value:Boolean):void
    {
        verticalLayout.variableRowHeight = value;
    }
    
    //----------------------------------
    //  firstIndexInView
    //----------------------------------

    [Bindable("indexInViewChanged")]    
    [Inspectable(category="General")]
 
    /**
     * @copy spark.layouts.VerticalLayout#firstIndexInView
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get firstIndexInView():int
    {
        return verticalLayout.firstIndexInView;
    }
    
    //----------------------------------
    //  lastIndexInView
    //----------------------------------

    [Bindable("indexInViewChanged")]    
    [Inspectable(category="General")]

    /**
     *  @copy spark.layouts.VerticalLayout#lastIndexInView
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get lastIndexInView():int
    {
        return verticalLayout.lastIndexInView;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  layout
    //----------------------------------    
        
    /**
     *  @private
     */
    override public function set layout(value:LayoutBase):void
    {
        throw(new Error(resourceManager.getString("components", "layoutReadOnly")));
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
    {
        switch(type)
        {
            case "indexInViewChanged":
            case "propertyChange":
                if (!hasEventListener(type))
                    verticalLayout.addEventListener(type, redispatchHandler);
                break;
        }
        super.addEventListener(type, listener, useCapture, priority, useWeakReference)
    }    
    
    /**
     * @private
     */
    override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
    {
        super.removeEventListener(type, listener, useCapture);
        switch(type)
        {
            case "indexInViewChanged":
            case "propertyChange":
                if (!hasEventListener(type))
                    verticalLayout.removeEventListener(type, redispatchHandler);
                break;
        }
    }
    
    private function redispatchHandler(event:Event):void
    {
        dispatchEvent(event);
    }
    
}
}