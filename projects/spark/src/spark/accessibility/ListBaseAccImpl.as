////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.accessibility
{

import flash.accessibility.Accessibility;
import flash.events.Event;

import flash.geom.Point;

import mx.accessibility.AccImpl;
import mx.accessibility.AccConst;
import mx.core.mx_internal;
import mx.core.UIComponent;
import spark.components.List;
import spark.components.supportClasses.ListBase;
import spark.events.IndexChangeEvent;

use namespace mx_internal;

/**
 *  ListBaseAccImpl is a superclass of the Spark ListAccImpl,
 *  DropDownListAccImpl, ComboBoxAccImpl, ButtonBarBaseAccImpl,
 *  and TabBarAccImpl.
 *
 *  <p>Please see the documentation of these classes for more information
 *  about how the Spark components List, DropDownList, ComboBox, ButtonBar,
 *  and TabBar implement accessibility.</p>
 *
 *  @see spark.accessibility.ListAccImpl
 *  @see spark.accessibility.DropDownListAccImpl
 *  @see spark.accessibility.ComboBoxAccImpl
 *  @see spark.accessibility.ButtonBarBaseAccImpl
 *  @see spark.accessibility.TabBarAccImpl  
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class ListBaseAccImpl extends AccImpl
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Enables accessibility in the ListBase class.
     *
     *  <p>This method is called by application startup code
     *  that is autogenerated by the MXML compiler.
     *  Afterwards, when instances of ListBase are initialized,
     *  their <code>accessibilityImplementation</code> property
     *  will be set to an instance of this class.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static function enableAccessibility():void
    {
        ListBase.createAccessibilityImplementation =
            createAccessibilityImplementation;
    }

    /**
     *  @private
     *  Creates a ListBase's AccessibilityImplementation object.
     *  This method is called from UIComponent's
     *  initializeAccessibility() method.
     */
    mx_internal static function createAccessibilityImplementation(
                                component:UIComponent):void
    {
        component.accessibilityImplementation =
            new ListBaseAccImpl(component);
    }

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  @param master The UIComponent instance that this AccImpl instance
     *  is making accessible.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function ListBaseAccImpl(master:UIComponent)
    {
        super(master);

        role = AccConst.ROLE_SYSTEM_LIST;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden properties: AccImpl
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  eventsToHandle
    //----------------------------------

    /**
     *  @private
     *    Array of events that we should listen for from the master component.
     */
    override protected function get eventsToHandle():Array
    {
        return super.eventsToHandle.concat([ "change", "caretChange"]);
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: AccessibilityImplementation
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Returns the name of the component.
     *
     *  @param childID uint.
     *
     *  @return Name of the component.
     *
     *  @tiptext Returns the name of the component
     */
    override public function get_accName(childID:uint):String
    {
        if (childID == 0)
            return super.get_accName(childID);
        var accName:String = getName(childID);
        return (accName != null && accName != "") ? accName : null;
    }


    /**
     *  @private
     *  Gets the role for the component.
     *
     *  @param childID children of the component
     */
    override public function get_accRole(childID:uint):uint
    {
        return childID == 0 ? role : AccConst.ROLE_SYSTEM_LISTITEM;
    }

    /**
     *  @private
     *  IAccessible method for returning the state of the ListItem.
     *  States are predefined for all the components in MSAA.
     *  Values are assigned to each state.
     *  Depending upon the listItem being Selected, Selectable,
     *  Invisible, Offscreen, a value is returned.
     *
     *  @param childID uint
     *
     *  @return State uint
     */
    override public function get_accState(childID:uint):uint
    {
        var accState:uint = getState(childID);

        if (childID > 0)
        {
            var index:uint = childID - 1;

            // For returning states (OffScreen and Invisible)
            // when the list Item is not in the displayed rows.
            var isInvisible:Boolean = false;
            //TODO: Add invisibility check

            if (isInvisible)
            {
            accState |= (AccConst.STATE_SYSTEM_OFFSCREEN |
                                 AccConst.STATE_SYSTEM_INVISIBLE);
            }
            else
            {
                if (master is List)
                    accState |= AccConst.STATE_SYSTEM_SELECTABLE;

                if (ListBase(master).isItemIndexSelected(index))
                {
                    accState |= AccConst.STATE_SYSTEM_SELECTED;
                }
                if (index == ListBase(master).caretIndex)
                    accState |= AccConst.STATE_SYSTEM_FOCUSED;
            }
        }
        else
        {
            if (master is List && List(master).allowMultipleSelection)
                accState |= AccConst.STATE_SYSTEM_MULTISELECTABLE;
        }
        return accState;
    }

    /**
     *  @private
     *  IAccessible method for returning the Default Action.
     *
     *  @param childID uint
     *
     *  @return DefaultAction String
     */
    override public function get_accDefaultAction(childID:uint):String
    {
        if (childID == 0)
            return null;

        return "Double Click";
    }

    /**
     *  @private
     *  IAccessible method for executing the Default Action.
     *
     *  @param childID uint
     */
    override public function accDoDefaultAction(childID:uint):void
    {
        if (childID > 0)
            ListBase(master).selectedIndex = childID - 1;
    }

     /**
     *  @private
     *  Method to return an array of childIDs.
     *
     *  @return Array
     */
    override public function getChildIDArray():Array
    {
        var n:int = ListBase(master).dataProvider ?
                    ListBase(master).dataProvider.length :
                    0;

        return createChildIDArray(n);;
    }

    /**
     *  @private
     *  IAccessible method for returning the bounding box of the ListItem.
     *
     *  @param childID uint
     *
     *  @return Location Object
     */
    override public function accLocation(childID:uint):*
    {
        var listBase:ListBase = ListBase(master);
        var index:uint = childID - 1;
        var isInvisible:Boolean = false;
        //TODO: Add visibility check
        if (isInvisible)
            return null;
        else
            return getItemAt(index);
    }

    /**
     *  @private
     *  IAccessible method for returning the child Selections in the List.
     *
     *  @param childID uint
     *
     *  @return focused childID.
     */
    override public function get_accSelection():Array
    {
        var accSelection:Array = [];
        var selectedIndices:Array = [];
        if (master is List && List(master).allowMultipleSelection)
            selectedIndices.concat(List(master).selectedIndices);
        else
            selectedIndices.concat(ListBase(master).selectedIndex);
        var n:int = selectedIndices.length;
        for (var i:int = 0; i < n; i++)
        {
            accSelection[i] = selectedIndices[i] + 1;
        }

        return accSelection;
    }

    /**
     *  @private
     *  IAccessible method for returning the childFocus of the List.
     *
     *  @param childID uint
     *
     *  @return focused childID.
     */
    override public function get_accFocus():uint
    {
        var index:uint = ListBase(master).caretIndex;

        return index >= 0 ? index + 1 : 0;
    }

    /**
     *  @private
     *  IAccessible method for selecting an item.
     *
     *  @param childID uint
     */
    override public function accSelect(selFlag:uint, childID:uint):void
    {
        var listBase:ListBase = ListBase(master);

        var index:uint = childID - 1;

        if (index >= 0 && index < listBase.dataProvider.length)
            listBase.selectedIndex = index;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: AccImpl
    //
    //--------------------------------------------------------------------------

     /**
     *  @private
     *  method for returning the name of the ListItem/ListBox
     *  which is spoken out by the screen reader.
     *  The ListItem should return the label as the name
     *  and ListBox should return the name
     *  specified in the Accessibility Panel.
     *
     *  @param childID uint
     *
     *  @return Name String
     */
    override protected function getName(childID:uint):String
    {
        if (childID == 0)
            return "";
        var listBase:ListBase = ListBase(master);
        return listBase.itemToLabel(listBase.dataProvider.getItemAt(childID - 1));
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden event handlers: AccImpl
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Override the generic event handler.
     *  All AccImpl must implement this
     *  to listen for events from its master component.
     */
    override protected function eventHandler(event:Event):void
    {
        // Let AccImpl class handle the events
        // that all accessible UIComponents understand.
        $eventHandler(event);
        var index:uint;
        var childID:uint;
        switch (event.type)
        {
            case "change":
            {
                index = IndexChangeEvent(event).newIndex;

                if (index >= 0)
                {
                    childID = index + 1;
                    Accessibility.sendEvent(master, childID,
                                            AccConst.EVENT_OBJECT_SELECTION);
                }
                break;
            }
            case "caretChange":
            {
                index = IndexChangeEvent(event).newIndex;
                childID = index + 1;
                Accessibility.sendEvent(master, childID,
                    AccConst.EVENT_OBJECT_FOCUS);
                break;
            }
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function getItemAt(index:int):Object
    {
        if (ListBase(master).dataGroup)
            return ListBase(master).dataGroup.getElementAt(index);
        else
            return master;
    }
}

}
