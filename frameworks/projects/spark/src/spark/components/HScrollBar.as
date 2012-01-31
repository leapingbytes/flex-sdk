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

package mx.components
{
import mx.components.baseClasses.FxScrollBar;
import mx.core.ScrollUnit;
import mx.core.IViewport;
import mx.core.ILayoutElement;
import mx.layout.LayoutElementFactory;
import mx.events.PropertyChangeEvent;
import mx.events.ResizeEvent;

[IconFile("FxHScrollBar.png")]

/**
 *  The FxHScrollBar (horizontal ScrollBar) control lets you control
 *  the portion of data that is displayed when there is too much data
 *  to fit horizontally in a display area.
 * 
 *  <p>Although you can use the FxHScrollBar control as a stand-alone control,
 *  you usually combine it as part of another group of components to
 *  provide scrolling functionality.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class FxHScrollBar extends FxScrollBar
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function FxHScrollBar()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    /**
     *  The size of the track, which equals the width of the track.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function get trackSize():Number
    {
        if (track)
            return track.width;
        else
           return 0;
    }
    
    override public function set viewport(newViewport:IViewport):void
    {
        super.viewport = newViewport;
        if (newViewport)
        {
            var hsp:Number = newViewport.horizontalScrollPosition;
            // Special case: if contentWidth is 0, assume that it hasn't been 
            // updated yet.  Making the maximum==hsp here avoids trouble later
            // when FxRange constrains value
            var cWidth:Number = newViewport.contentWidth;
            maximum = (cWidth == 0) ? hsp : cWidth - newViewport.width;
            pageSize = newViewport.width;
            value = hsp;
        }
    }      
    
    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Update the value property and, if viewport is non null, then set 
     *  its horizontalScrollPosition to <code>value</code>.
     * 
     *  @param value The new value of the <code>value</code> property. 
     *  @see viewport
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function setValue(value:Number):void
    {
        super.setValue(value);
        if (viewport)
            viewport.horizontalScrollPosition = value;
    }
    

    /**
     *  Position the thumb button based on the specified thumb position,
     *  relative to the current X location of the track in the control.
     * 
     *  @param thumbPos A number representing the new position of the thumb
     *  button in the control.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function positionThumb(thumbPos:Number):void
    {
        if (thumb)
        {
            var trackPos:Number = track ? track.x : 0;   
            var layoutElement:ILayoutElement = LayoutElementFactory.getLayoutElementFor(thumb);
            layoutElement.setLayoutBoundsPosition(Math.round(trackPos + thumbPos),
                                            layoutElement.getLayoutBoundsY());
        }
    }
    
    /**
     *  @private
     */
    override protected function calculateThumbSize():Number
    {
        return Math.max(thumb.minWidth, super.calculateThumbSize());
    }

    /**
     *  @private
     */
    override protected function sizeThumb(thumbSize:Number):void
    {
        thumb.width = thumbSize;
        thumb.visible = thumbSize < trackSize;
    }
    
    /**
     *  Returns the position of the thumb button on an FxHScrollBar control, 
     *  which is equal to the <code>localX</code> parameter.
     * 
     *  @param localX The X position relative to the scrollbar control.
     *
     *  @param localY The Y position relative to the scrollbar control.
     *
     *  @return The position of the thumb button.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function pointToPosition(localX:Number, 
                                                localY:Number):Number
    {
        return localX;
    }
    
    /**
     *  Implicitly update the viewport's verticalScrollPosition per the
     *  specified scrolling unit, by setting the scrollbar's value.
     *
     *  @private
     */
    private function updateViewportHSP(scrollUnit:uint):void
    {
        var delta:Number = viewport.getHorizontalScrollPositionDelta(scrollUnit);
        setValue(viewport.horizontalScrollPosition + delta);
    }
    
    /**
     *  If <code>viewport</code> is not null, 
     *  change the horizontal scroll position for page up or page down by 
     *  scrolling the viewport.
     *  This method calculates the amount to scroll by calling the 
     *  <code>IViewport.getHorizontalScrollPositionDelta()</code> method 
     *  with either <code>flash.ui.Keyboard.PAGE_UP</code> 
     *  or <code>flash.ui.Keyboard.PAGE_DOWN</code>.
     *  It then calls the <code>setValue()</code> method to 
     *  set the <code>IViewport.horizontalScrollPosition</code> property 
     *  to the appropriate value.
     *
     *  <p>If <code>viewport</code> is null, 
     *  change the scroll position for page up or page down by calling 
     *  the <code>page()</code> method.</p>
     *
     *  @param increase Whether the page scroll is up (<code>true</code>) or
     *  down (<code>false</code>). 
     * 
     *  @see mx.components.baseClasses.FxTrackBase#page()
     *  @see mx.components.baseClasses.FxTrackBase#setValue()
     *  @see mx.core.IViewport
     *  @see mx.core.IViewport#horizontalScrollPosition
     *  @see mx.core.IViewport#getHorizontalScrollPositionDelta()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function page(increase:Boolean = true):void
    {
        if (!viewport)
            super.page(increase);
        else
            updateViewportHSP((increase) ? ScrollUnit.PAGE_RIGHT : ScrollUnit.PAGE_LEFT);
    }
    
    /**
     *  If <code>viewport</code> is not null, 
     *  change the horizontal scroll position for line up or line down by 
     *  scrolling the viewport.
     *  This method calculates the amount to scroll by calling the 
     *  <code>IViewport.getHorizontalScrollPositionDelta()</code> method 
     *  with either <code>flash.ui.Keyboard.RIGHT</code> 
     *  or <code>flash.ui.Keyboard.LEFT</code>.
     *  It then calls the <code>setValue()</code> method to 
     *  set the <code>IViewport.horizontalScrollPosition</code> property 
     *  to the appropriate value.
     *
     *  <p>If <code>viewport</code> is null, 
     *  change the scroll position for line up or line down by calling 
     *  the <code>step()</code> method.</p>
     *
     *  @param increase Whether the line scoll is up (<code>true</code>) or
     *  down (<code>false</code>). 
     * 
     *  @see mx.components.baseClasses.FxTrackBase#step()
     *  @see mx.components.baseClasses.FxTrackBase#setValue()
     *  @see mx.core.IViewport
     *  @see mx.core.IViewport#horizontalScrollPosition
     *  @see mx.core.IViewport#getHorizontalScrollPositionDelta()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function step(increase:Boolean = true):void
    {
        if (!viewport)
            super.step(increase);
        else
            updateViewportHSP((increase) ? ScrollUnit.RIGHT : ScrollUnit.LEFT);
    }   
    
    /**
     *  @private
     */    
    override protected function partAdded(partName:String, instance:Object):void
    {
        if (instance == thumb)
        {
            thumb.setConstraintValue("left", undefined);
            thumb.setConstraintValue("right", undefined);
            thumb.setConstraintValue("horizontalCenter", undefined);
        }      
        
        super.partAdded(partName, instance);
    }
    
    /**
     *  Set this scrollbar's value to the viewport's current horizontalScrollPosition.
     * 
     *  @see IViewport#horizontalScrollPosition
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function viewportHorizontalScrollPositionChangeHandler(event:PropertyChangeEvent):void
    {
        if (viewport)
            value = viewport.horizontalScrollPosition;
    } 
    
    /**
     *  Set this scrollbar's maximum to the viewport's contentWidth 
     *  less the viewport width and its pageSize to the viewport's width. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function viewportResizeHandler(event:ResizeEvent):void
    {
        if (viewport)
        {
            var hsp:Number = viewport.horizontalScrollPosition;
            // Special case: if contentWidth is 0, assume that it hasn't been 
            // updated yet.  Making the maximum==hsp here avoids trouble later
            // when FxRange constrains value
            var cWidth:Number = viewport.contentWidth;
            maximum = (cWidth == 0) ? hsp : cWidth - viewport.width;
            pageSize = viewport.width;
        } 
    }
    
    /**
     *  Set this scrollbar's maximum to the viewport's contentWidth 
     *  less the viewport width. 
     *
     *  @see IViewport#contentWidth
     *  @see IViewport#width 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function viewportContentWidthChangeHandler(event:PropertyChangeEvent):void
    {
        if (viewport)
            maximum = viewport.contentWidth - viewport.width;
    }

        
}

}
