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

package spark.components.supportClasses
{

import flash.accessibility.Accessibility;
import flash.accessibility.AccessibilityProperties;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.system.Capabilities;

import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.events.SelectionEvent;

import mx.core.IIMESupport;
import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.TouchInteractionEvent;
import mx.events.SandboxMouseEvent;
import mx.managers.IFocusManagerComponent;
import mx.utils.BitFlagUtil;

import spark.components.RichEditableText;
import spark.components.TextSelectionHighlighting;
import spark.core.IDisplayText;
import spark.core.IEditableText;
import spark.events.TextOperationEvent;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

include "../../styles/metadata/BasicNonInheritingTextStyles.as"
include "../../styles/metadata/BasicInheritingTextStyles.as"
include "../../styles/metadata/AdvancedInheritingTextStyles.as"
include "../../styles/metadata/SelectionFormatTextStyles.as"

/**
 *  The alpha of the border for this component.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="borderAlpha", type="Number", inherit="no", theme="spark", minValue="0.0", maxValue="1.0")]

/**
 *  The color of the border for this component.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="borderColor", type="uint", format="Color", inherit="no", theme="spark")]

/**
 *  Controls the visibility of the border for this component.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="borderVisible", type="Boolean", inherit="no", theme="spark")]

/**
 *  The alpha of the content background for this component.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="contentBackgroundAlpha", type="Number", inherit="yes", theme="spark", minValue="0.0", maxValue="1.0")]

/**
 *  @copy spark.components.supportClasses.GroupBase#contentBackgroundColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="contentBackgroundColor", type="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  The alpha of the focus ring for this component.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="focusAlpha", type="Number", inherit="no", theme="spark", minValue="0.0", maxValue="1.0")]

/**
 *  @copy spark.components.supportClasses.GroupBase#focusColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="focusColor", type="uint", format="Color", inherit="yes", theme="spark")]

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispached after the <code>selectionAnchorPosition</code> and/or
 *  <code>selectionActivePosition</code> properties have changed
 *  for any reason.
 *
 *  @eventType mx.events.FlexEvent.SELECTION_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="selectionChange", type="mx.events.FlexEvent")]

/**
 *  Dispatched before a user editing operation occurs.
 *  You can alter the operation, or cancel the event
 *  to prevent the operation from being processed.
 *
 *  @eventType spark.events.TextOperationEvent.CHANGING
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="changing", type="spark.events.TextOperationEvent")]

/**
 *  Dispatched after a user editing operation is complete.
 *
 *  @eventType spark.events.TextOperationEvent.CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="change", type="spark.events.TextOperationEvent")]

/**
 *  Dispatched when a keystroke is about to be input to
 *  the component.
 *
 *  @eventType flash.events.TextEvent.TEXT_INPUT
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="textInput", type="flash.events.TextEvent")]

/**
 *  The base class for skinnable components, such as the Spark TextInput
 *  and TextArea, that include an instance of RichEditableText in their skin
 *  to provide rich text display, scrolling, selection, and editing.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class SkinnableTextBase extends SkinnableComponent 
    implements IFocusManagerComponent, IIMESupport
{
    include "../../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private static const CONTENT_PROPERTY_FLAG:uint = 1 << 0;

    /**
     *  @private
     */
    private static const DISPLAY_AS_PASSWORD_PROPERTY_FLAG:uint = 1 << 1;
    
    /**
     *  @private
     */
    private static const EDITABLE_PROPERTY_FLAG:uint = 1 << 2;
        
    /**
     *  @private
     */
    private static const HEIGHT_IN_LINES_PROPERTY_FLAG:uint = 1 << 3;
    
    /**
     *  @private
     */
    private static const IME_MODE_PROPERTY_FLAG:uint = 1 << 4;
    
    /**
     *  @private
     */
    private static const MAX_CHARS_PROPERTY_FLAG:uint = 1 << 5;
       
    /**
     *  @private
     */
    private static const MAX_HEIGHT_PROPERTY_FLAG:uint = 1 << 6;
    
    /**
     *  @private
     */
    private static const MAX_WIDTH_PROPERTY_FLAG:uint = 1 << 7;
    
    /**
     *  @private
     */
    private static const RESTRICT_PROPERTY_FLAG:uint = 1 << 8;

    /**
     *  @private
     */
    private static const SELECTABLE_PROPERTY_FLAG:uint = 1 << 9;

    /**
     *  @private
     */
    private static const SELECTION_HIGHLIGHTING_FLAG:uint = 1 << 10;

    /**
     *  @private
     */
    private static const TEXT_PROPERTY_FLAG:uint = 1 << 11;

    /**
     *  @private
     */
    private static const TEXT_FLOW_PROPERTY_FLAG:uint = 1 << 12;
    
	/**
	 *  @private
	 */
	private static const TYPICAL_TEXT_PROPERTY_FLAG:uint = 1 << 13;
	
    /**
     *  @private
     */
    private static const WIDTH_IN_CHARS_PROPERTY_FLAG:uint = 1 << 14;

    /**
     *  @private
     */
    private static const PROMPT_TEXT_PROPERTY_FLAG:uint = 1;
    
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
    public function SkinnableTextBase()
    {
        super();
        addHandlers();
    }

    //--------------------------------------------------------------------------
    //
    //  Skin parts
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  promptDisplay
    //----------------------------------
    
    [SkinPart(required="false")]
    
    /**
     *  The Label or other IDisplayText that may be present
     *  in any skin assigned to this component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var promptDisplay:IDisplayText;
    
    /**
     *  @private
     *  Properties are proxied to promptDisplay.  However, when 
     *  promptDisplay is not around, we need to store values set on 
     *  SkinnableTextBase.  This object stores those values.  If promptDisplay is 
     *  around, the values are  stored  on the promptDisplay directly.  However, 
     *  we need to know what values have been set by the developer on 
     *  TextInput/TextArea (versus set on the promptDisplay or defaults of the 
     *  promptDisplay) as those are values we want to carry around if the 
     *  promptDisplay changes (via a new skin). In order to store this info 
     *  efficiently, promptDisplayProperties becomes a uint to store a series of 
     *  BitFlags.  These bits represent whether a property has been explicitly 
     *  set on this SkinnableTextBase.  When the promptDisplay is not around, 
     *  promptDisplayProperties is a typeless object to store these proxied 
     *  properties.  When promptDisplay is around, promptDisplayProperties stores 
     *  booleans as to whether these properties have been explicitly set or not.
     */
    private var promptDisplayProperties:Object = {};
    
    //----------------------------------
    //  textDisplay
    //----------------------------------

    [SkinPart(required="false")]

    /**
     *  The RichEditableText that may be present
     *  in any skin assigned to this component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var textDisplay:IEditableText;

    /**
     *  @private
     *  Several properties are proxied to textDisplay.  However, when 
     *  textDisplay is not around, we need to store values set on 
     *  SkinnableTextBase.  This object stores those values.  If textDisplay is 
     *  around, the values are  stored  on the textDisplay directly.  However, 
     *  we need to know what values have been set by the developer on 
     *  TextInput/TextArea (versus set on the textDisplay or defaults of the 
     *  textDisplay) as those are values we want to carry around if the 
     *  textDisplay changes (via a new skin). In order to store this info 
     *  efficiently, textDisplayProperties becomes a uint to store a series of 
     *  BitFlags.  These bits represent whether a property has been explicitly 
     *  set on this SkinnableTextBase.  When the  textDisplay is not around, 
     *  textDisplayProperties is a typeless object to store these proxied 
     *  properties.  When textDisplay is around, textDisplayProperties stores 
     *  booleans as to whether these properties have been explicitly set or not.
     */
    private var textDisplayProperties:Object = {};
   
    //--------------------------------------------------------------------------
    //
    //  Overridden properties: UIComponent
    //
    //--------------------------------------------------------------------------
	
	/*
	
	Note:
	
	SkinnableTextBase does not have an accessibilityImplementation
	because, if it does, the Flash Player doesn't support text-selection
	accessibility. The selectionAnchorIndex and selectionActiveIndex
	getters of the acc impl don't get called, probably because Player 10.1
	doesn't like the fact that stage.focus is the texDisplay:RichEditableText
	part instead of the SinnableTextBase component (i.e., the TextInput
	or TextArea).
	
	Instead, we rely on the RichEditableTextAccImpl of the textDisplay
	to provide accessibility.
	
	However, developers expect to be able to control accessibility by setting
	accessibilityProperties, accessibilityName, accessibilityDescription,
	tabIndex, etc. on the component itself.
	
	In order to make these settings usable by RichEditableTextAccImpl,
	we push them down into the accessibilityProperties of the RichEditableText,
	using the invalidateProperties() / commitProperties() pattern.
	
	*/

	//----------------------------------
	//  accessibilityEnabled
	//----------------------------------
	
	/**
	 *  @private
	 */
	override public function set accessibilityEnabled(value:Boolean):void
	{
		if (!Capabilities.hasAccessibility)
			return;
			
		if (!accessibilityProperties)
			accessibilityProperties = new AccessibilityProperties();
		
		accessibilityProperties.silent = !value;
		accessibilityPropertiesChanged = true;
		
		invalidateProperties();
	}
	
	//----------------------------------
	//  accessibilityDescription
	//----------------------------------
	
	/**
	 *  @private
	 */
	override public function set accessibilityDescription(value:String):void
	{
		if (!Capabilities.hasAccessibility)
			return;
		
		if (!accessibilityProperties)
			accessibilityProperties = new AccessibilityProperties();
		
		accessibilityProperties.description = value;
		accessibilityPropertiesChanged = true;
		
		invalidateProperties();
	}
	
	//----------------------------------
	//  accessibilityName
	//----------------------------------
	
	/**
	 *  @private
	 */
	override public function set accessibilityName(value:String):void 
	{
		if (!Capabilities.hasAccessibility)
			return;
		
		if (!accessibilityProperties)
			accessibilityProperties = new AccessibilityProperties();
		
		accessibilityProperties.name = value;
		accessibilityPropertiesChanged = true;
		
		invalidateProperties();
	}
	
	//----------------------------------
	//  accessibilityProperties
	//----------------------------------
	
	/**
	 *  @private
	 *  Storage for the accessibilityProperties property.
	 */
	private var _accessibilityProperties:AccessibilityProperties = null;

	/**
	 *  @private
	 */
	private var accessibilityPropertiesChanged:Boolean = false;
	
	/**
	 *  @private
	 */
	override public function get accessibilityProperties():AccessibilityProperties
	{
		return _accessibilityProperties;
	}
	
	/**
	 *  @private
	 */
	override public function set accessibilityProperties(
									value:AccessibilityProperties):void
	{
		_accessibilityProperties = value;
		accessibilityPropertiesChanged = true;
		
		invalidateProperties();
	}
	
	//----------------------------------
	//  accessibilityShortcut
	//----------------------------------
	
	/**
	 *  @private
	 */
	override public function set accessibilityShortcut(value:String):void
	{
		if (!Capabilities.hasAccessibility)
			return;		
		
		if (!accessibilityProperties)
			accessibilityProperties = new AccessibilityProperties();
		
		accessibilityProperties.shortcut = value;
		accessibilityPropertiesChanged = true;
		
		invalidateProperties();
	}

	//----------------------------------
    //  baselinePosition
    //----------------------------------
    
    /**
     *  @private
     */
    override public function get baselinePosition():Number
    {
        return getBaselinePositionForPart(textDisplay as IVisualElement);
    }
    
    //----------------------------------
    //  enabled
    //----------------------------------
    
    /**
     *  @private
     */
    override public function set enabled(value:Boolean):void
    {
        if (textDisplay)
            textDisplay.enabled = value;
        
        if (value == super.enabled)
            return;
        
        super.enabled = value;
    }

    //----------------------------------
    //  maxWidth
    //----------------------------------

    /**
     *  @private
     */
    override public function get maxWidth():Number
    {
        var richEditableText:RichEditableText = textDisplay as RichEditableText;

        if (richEditableText)
            return richEditableText.maxWidth;
            
        // want the default to be default max width for UIComponent
        var v:* = textDisplay ? undefined : textDisplayProperties.maxWidth;
        return (v === undefined) ? super.maxWidth : v;        
    }

    /**
     *  @private
     */
    override public function set maxWidth(value:Number):void
    {
        if (textDisplay)
        {
            var richEditableText:RichEditableText = textDisplay as RichEditableText;
            
            if (richEditableText)
                richEditableText.maxWidth = value;
            textDisplayProperties = BitFlagUtil.update(
                uint(textDisplayProperties), MAX_WIDTH_PROPERTY_FLAG, true);
        }
        else
        {
            textDisplayProperties.maxWidth = value;
        }

        // Generate an UPDATE_COMPLETE event.
        invalidateProperties();                    
    }

    //----------------------------------
    //  prompt
    //----------------------------------
    
    /**
     *  @default null
     *
     *  Text to be displayed if/when the actual
     *  text property is a null or empty string.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get prompt():String
    {
        return getPrompt();
    }
    
    /**
     *  @private
     */
    public function set prompt(value:String):void
    {
        setPrompt(value);
    }
    
	//----------------------------------
	//  tabIndex
	//----------------------------------

    /**
     *  @private
     *  Storage for the tabIndex property.
     */
    private var _tabIndex:int = -1;
	
    /**
     *  @private
     */
    override public function get tabIndex():int
    {
        return _tabIndex;
    }
    
    /**
     *  @private
     */
    override public function set tabIndex(
                                    value:int):void
    {
        _tabIndex = value;
        accessibilityPropertiesChanged = true;
        
        invalidateProperties();
    }
    
    //----------------------------------
    //  typicalText
    //----------------------------------
    
    /**
     *  @default null
     *
     *  @see spark.components.RichEditableText#typicalText
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get typicalText():String
    {
        return getTypicalText();
    }
    
    /**
     *  @private
     */
    public function set typicalText(value:String):void
    {
        setTypicalText(value);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties proxied to textDisplay
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  displayAsPassword
    //----------------------------------
    
    /**
     *  @copy spark.components.RichEditableText#displayAsPassword
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get displayAsPassword():Boolean
    {
        if (textDisplay)
            return textDisplay.displayAsPassword;

        // want the default to be false
        var v:* = textDisplayProperties.displayAsPassword
        return (v === undefined) ? false : v;
    }

    /**
     *  @private
     */
    public function set displayAsPassword(value:Boolean):void
    {
        if (textDisplay)
        {
            textDisplay.displayAsPassword = value;
            textDisplayProperties = BitFlagUtil.update(
                                    uint(textDisplayProperties), 
                                    DISPLAY_AS_PASSWORD_PROPERTY_FLAG, true);
        }
        else
        {
            textDisplayProperties.displayAsPassword = value;
        }

        // Generate an UPDATE_COMPLETE event.
        invalidateProperties();                    
    }

    //----------------------------------
    //  editable
    //----------------------------------

    /**
     *  @copy spark.components.RichEditableText#editable
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get editable():Boolean
    {
        if (textDisplay)
            return textDisplay.editable;
            
        // want the default to be true
        var v:* = textDisplayProperties.editable;
        return (v === undefined) ? true : v;
    }

    /**
     *  @private
     */
    public function set editable(value:Boolean):void
    {
        if (textDisplay)
        {
            textDisplay.editable = value;
            textDisplayProperties = BitFlagUtil.update(
                uint(textDisplayProperties), EDITABLE_PROPERTY_FLAG, true);
        }
        else
        {
            textDisplayProperties.editable = value;
        }

        // Generate an UPDATE_COMPLETE event.
        invalidateProperties();                    
    }

    //----------------------------------
    //  enableIME
    //----------------------------------

    /**
     *  @copy spark.components.RichEditableText#enableIME
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get enableIME():Boolean
    {
        return editable;
    }

    //----------------------------------
    //  imeMode
    //----------------------------------

    /**
     *  @copy spark.components.RichEditableText#imeMode
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
     public function get imeMode():String
    {
        var richEditableText:RichEditableText = textDisplay as RichEditableText;
                
        if (richEditableText)        
            return richEditableText.imeMode;
            
        // want the default to be null
        var v:* = textDisplay ? undefined : textDisplayProperties.imeMode;
        return (v === undefined) ? null : v;
    }

    /**
     *  @private
     */
    public function set imeMode(value:String):void
    {
        var richEditableText:RichEditableText = textDisplay as RichEditableText;

        if (textDisplay)
        {
			if (richEditableText)
            	richEditableText.imeMode = value;
            textDisplayProperties = BitFlagUtil.update(
                uint(textDisplayProperties), IME_MODE_PROPERTY_FLAG, true);
        }
        else
        {
            textDisplayProperties.imeMode = value;
        }

        // Generate an UPDATE_COMPLETE event.
        invalidateProperties();                    
    }

    //----------------------------------
    //  maxChars
    //----------------------------------
    
    [Inspectable(minValue="0.0")]    

    /**
     *  @copy spark.components.RichEditableText#maxChars
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get maxChars():int 
    {
        if (textDisplay)
            return textDisplay.maxChars;
            
        // want the default to be 0
        var v:* = textDisplayProperties.maxChars;
        return (v === undefined) ? 0 : v;
    }
    
    /**
     *  @private
     */
    public function set maxChars(value:int):void
    {
        if (textDisplay)
        {
            textDisplay.maxChars = value;
            textDisplayProperties = BitFlagUtil.update(
                uint(textDisplayProperties), MAX_CHARS_PROPERTY_FLAG, true);
        }
        else
        {
            textDisplayProperties.maxChars = value;
        }

        // Generate an UPDATE_COMPLETE event.
        invalidateProperties();                    
    }

    //----------------------------------
    //  restrict
    //----------------------------------

    /**
     *  @copy spark.components.RichEditableText#restrict
     * 
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get restrict():String 
    {
        if (textDisplay)
            return textDisplay.restrict;
            
        // want the default to be null
        var v:* = textDisplayProperties.restrict;
        return (v === undefined) ? null : v;
    }
    
    /**
     *  @private
     */
    public function set restrict(value:String):void
    {
        if (textDisplay)
        {
            textDisplay.restrict = value;
            textDisplayProperties = BitFlagUtil.update(
                uint(textDisplayProperties), RESTRICT_PROPERTY_FLAG, true);
        }
        else
        {
            textDisplayProperties.restrict = value;
        }

        // Generate an UPDATE_COMPLETE event.
        invalidateProperties();                    
    }

    //----------------------------------
    //  selectable
    //----------------------------------

    /**
     *  @copy spark.components.RichEditableText#selectable
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get selectable():Boolean
    {
        if (textDisplay)
            return textDisplay.selectable;
            
        // want the default to be true
        var v:* = textDisplayProperties.selectable;
        return (v === undefined) ? true : v;
    }

    /**
     *  @private
     */
    public function set selectable(value:Boolean):void
    {
        if (textDisplay)
        {
            textDisplay.selectable = value;
            textDisplayProperties = BitFlagUtil.update(
                uint(textDisplayProperties), SELECTABLE_PROPERTY_FLAG, true);
        }
        else
        {
            textDisplayProperties.selectable = value;
        }
        
        // Generate an UPDATE_COMPLETE event.
        invalidateProperties();                    
    }

    //----------------------------------
    //  selectionActivePosition
    //----------------------------------

    /**
     *  @private
     */
    [Bindable("selectionChange")]
    
    /**
     *  @copy spark.components.RichEditableText#selectionActivePosition
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get selectionActivePosition():int
    {
        return textDisplay ? textDisplay.selectionActivePosition : -1;
    }

    //----------------------------------
    //  selectionAnchorPosition
    //----------------------------------

    /**
     *  @private
     */
    [Bindable("selectionChange")]
    
    /**
     *  @copy spark.components.RichEditableText#selectionAnchorPosition
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get selectionAnchorPosition():int
    {
        return textDisplay ? textDisplay.selectionAnchorPosition : -1;
    }

    //----------------------------------
    //  selectionHighlighting
    //----------------------------------

    [Inspectable(category="General", enumeration="always,whenActive,whenFocused", defaultValue="whenFocused")]
    
    /**
     *  @copy spark.components.RichEditableText#selectionHighlighting
     *  
     *  @default TextSelectionHighlighting.WHEN_FOCUSED
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get selectionHighlighting():String 
    {
        var richEditableText:RichEditableText = textDisplay as RichEditableText;
        
        if (richEditableText)
            return richEditableText.selectionHighlighting;
            
        // want the default to be "when focused"
        var v:* = textDisplay ? undefined : textDisplayProperties.selectionHighlighting;
        return (v === undefined) ? TextSelectionHighlighting.WHEN_FOCUSED : v;
    }
    
    /**
     *  @private
     */
    public function set selectionHighlighting(value:String):void
    {
        if (textDisplay)
        {
            var richEditableText:RichEditableText = textDisplay as RichEditableText;
            
            if (richEditableText)
                richEditableText.selectionHighlighting = value;
            textDisplayProperties = BitFlagUtil.update(
                                    uint(textDisplayProperties), 
                                    SELECTION_HIGHLIGHTING_FLAG, true);
        }
        else
        {
            textDisplayProperties.selectionHighlighting = value;
        }

        // Generate an UPDATE_COMPLETE event.
        invalidateProperties();                    
    }

    //----------------------------------
    //  text
    //----------------------------------
    
    [Inspectable(category="General")]
    
    /**
     *  @copy spark.components.RichEditableText#text
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get text():String
    {
        if (textDisplay)
            return textDisplay.text;
            
        // If there is no textDisplay, it isn't possible to set one of
        // text, textFlow or content and then get it in another form.
                    
        // want the default to be the empty string
        var v:* = textDisplayProperties.text;
        return (v === undefined) ? "" : v;
    }

    /**
     *  @private
     */
    public function set text(value:String):void
    {
        if (textDisplay)
        {
            textDisplay.text = value;
            textDisplayProperties = BitFlagUtil.update(
                uint(textDisplayProperties), TEXT_PROPERTY_FLAG, true);
        }
        else
        {
            textDisplayProperties.text = value;

            // Of 'text', 'textFlow', and 'content', the last one set wins.  So
            // if we're holding onto the properties until the skin is loaded
            // make sure only the last one set is defined.
            textDisplayProperties.content = undefined;
            textDisplayProperties.textFlow = undefined;
        }

        // Generate an UPDATE_COMPLETE event.
        invalidateProperties();                    
     }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	override protected function commitProperties():void
	{
		super.commitProperties();
		
		if (accessibilityPropertiesChanged)
		{
			if (textDisplay)
			{
				textDisplay.accessibilityProperties = _accessibilityProperties;
                textDisplay.tabIndex = _tabIndex;             
                
				// Note: Calling updateProperties() on players that don't
				// support accessibility will throw an RTE.
				if (Capabilities.hasAccessibility)
					Accessibility.updateProperties();
			}
			
			accessibilityPropertiesChanged = false;
		}
	}

    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);

        if (instance == promptDisplay)
        {
            var newPromptDisplayProperties:uint = 0;
            if (promptDisplayProperties.prompt !== undefined)
            {
                promptDisplay.text = promptDisplayProperties.prompt;
                newPromptDisplayProperties = BitFlagUtil.update(
                    uint(newPromptDisplayProperties), PROMPT_TEXT_PROPERTY_FLAG, true);
            }
            promptDisplayProperties = newPromptDisplayProperties;
        }
        
        if (instance == textDisplay)
        {
            // Copy proxied values from textDisplayProperties (if set) to 
            //textDisplay.
            textDisplayAdded();            

            // Focus on this, rather than the inner RET component.
            textDisplay.focusEnabled = false;

            // Start listening for various events from the RichEditableText.

            textDisplay.addEventListener(SelectionEvent.SELECTION_CHANGE,
                                         textDisplay_selectionChangeHandler);

            textDisplay.addEventListener(TextOperationEvent.CHANGING, 
                                         textDisplay_changingHandler);

            textDisplay.addEventListener(TextOperationEvent.CHANGE,
                                         textDisplay_changeHandler);

            textDisplay.addEventListener(FlexEvent.ENTER,
                                         textDisplay_enterHandler);

            textDisplay.addEventListener(FlexEvent.VALUE_COMMIT,
                                         textDisplay_valueCommitHandler);
        }
    }

    /**
     *  @private
     */
    override protected function partRemoved(partName:String, 
                                            instance:Object):void
    {
        super.partRemoved(partName, instance);

        if (instance == textDisplay)
        {
            // Copy proxied values from textDisplay (if explicitly set) to 
            // textDisplayProperties.                        
            textDisplayRemoved();            
            
            // Stop listening for various events from the RichEditableText.

            textDisplay.removeEventListener(SelectionEvent.SELECTION_CHANGE,
                                            textDisplay_selectionChangeHandler);

            textDisplay.removeEventListener(TextOperationEvent.CHANGING,
                                            textDisplay_changingHandler);

            textDisplay.removeEventListener(TextOperationEvent.CHANGE,
                                            textDisplay_changeHandler);

            textDisplay.removeEventListener(FlexEvent.ENTER,
                                            textDisplay_enterHandler);

            textDisplay.removeEventListener(FlexEvent.VALUE_COMMIT,
                                            textDisplay_valueCommitHandler);
        }
        
        if (instance == promptDisplay)
        {
            var newPromptDisplayProperties:Object = {};
            
            if (BitFlagUtil.isSet(uint(promptDisplayProperties), 
                PROMPT_TEXT_PROPERTY_FLAG))
            {
                newPromptDisplayProperties.prompt = 
                    textDisplay.text;
            }
            promptDisplayProperties = newPromptDisplayProperties;
        }
    }
    
    /**
     *  @private
     */
    override protected function getCurrentSkinState():String
    {
        if (focusManager && focusManager.getFocus() != focusManager.findFocusManagerComponent(this) && 
            prompt != null && prompt != "")
        {
            if (text.length == 0)
            {
                if (enabled && skin && skin.hasState("normalWithPrompt"))
                    return "normalWithPrompt";
                if (!enabled && skin && skin.hasState("disabledWithPrompt"))
                    return "disabledWithPrompt";
            }
        }
        return enabled ? "normal" : "disabled";
    }

    /**
     *  @private
     *  Focus should always be on the internal RichEditableText.
     */
    override public function setFocus():void
    {
        if (textDisplay)
            textDisplay.setFocus();
    }

    /**
     *  @private
     */
    override protected function isOurFocus(target:DisplayObject):Boolean
    {
        return target == textDisplay || super.isOurFocus(target);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function addHandlers():void
    {
        addEventListener(TouchInteractionEvent.TOUCH_INTERACTION_STARTING, touchInteractionStartingHandler);
    }
    
    /**
     *  @copy spark.components.RichEditableText#insertText()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function insertText(text:String):void
    {
        if (!textDisplay)
            return;

        textDisplay.insertText(text);
        
        // This changes text so generate an UPDATE_COMPLETE event.
        invalidateProperties();
    }

    /**
     *  @copy spark.components.RichEditableText#appendText()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function appendText(text:String):void
    {
        if (!textDisplay)
            return;

        textDisplay.appendText(text);
        
        // This changes text so generate an UPDATE_COMPLETE event.
        invalidateProperties();
    }
    
    /**
     *  @copy spark.components.RichEditableText#selectRange()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function selectRange(anchorIndex:int, activeIndex:int):void
    {
        if (!textDisplay)
            return;

        textDisplay.selectRange(anchorIndex, activeIndex);

        // This changes the selection so generate an UPDATE_COMPLETE event.
        invalidateProperties();
    }

    /**
     *  @copy spark.components.RichEditableText#selectAll()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function selectAll():void
    {
        if (!textDisplay)
            return;

        textDisplay.selectAll();

        // This changes the selection so generate an UPDATE_COMPLETE event.
        invalidateProperties();
    }

    /**
     *  @private
     */
    mx_internal function setContent(value:Object):void
    {        
        if (textDisplay)
        {
            var richEditableText:RichEditableText = textDisplay as RichEditableText;
            
            if (richEditableText)
            {
                richEditableText.content = value;
                textDisplayProperties = BitFlagUtil.update(
                    uint(textDisplayProperties), CONTENT_PROPERTY_FLAG, true);
            }
        }
        else
        {
            textDisplayProperties.content = value;
            
            // Of 'text', 'textFlow', and 'content', the last one set wins.  So
            // if we're holding onto the properties until the skin is loaded
            // make sure only the last one set is defined.
            textDisplayProperties.text = undefined;
            textDisplayProperties.textFlow = undefined;
        }

        // Generate an UPDATE_COMPLETE event.
        invalidateProperties();                    
     }

    /**
     *  @private
     */
    mx_internal function getHeightInLines():Number
    {
        var richEditableText:RichEditableText = textDisplay as RichEditableText;

        if (richEditableText)
            return richEditableText.heightInLines;
            
        // want the default to be NaN
        var v:* = textDisplay ? undefined : textDisplayProperties.heightInLines;        
        return (v === undefined) ? NaN : v;
    }

    /**
     *  @private
     */
    mx_internal function setHeightInLines(value:Number):void
    {
        if (textDisplay)
        {
            var richEditableText:RichEditableText = textDisplay as RichEditableText;

            if (richEditableText)
                richEditableText.heightInLines = value;
            textDisplayProperties = BitFlagUtil.update(
                uint(textDisplayProperties), 
                HEIGHT_IN_LINES_PROPERTY_FLAG, true);
        }
        else
        {
            textDisplayProperties.heightInLines = value;
        }

        // Generate an UPDATE_COMPLETE event.
        invalidateProperties();                    
    }

    /**
     *  @see #prompt
     *
     *  @private
     */
    mx_internal function getPrompt():String
    {
        if (promptDisplay)
        {
            if (BitFlagUtil.isSet(uint(promptDisplayProperties), 
                PROMPT_TEXT_PROPERTY_FLAG))
                return promptDisplay.text;
            return null;
        }
        
        // want the default to be null
        var v:* = promptDisplay ? undefined : promptDisplayProperties.prompt;
        return (v === undefined) ? null : v;
    }
    
    /**
     *  @private
     */
    mx_internal function setPrompt(value:String):void
    {
        if (promptDisplay)
        {
            promptDisplay.text = value;
            promptDisplayProperties = BitFlagUtil.update(
                uint(promptDisplayProperties), 
                PROMPT_TEXT_PROPERTY_FLAG, true);
        }
        else
            promptDisplayProperties.prompt = value;
        
        // Generate an UPDATE_COMPLETE event.
        invalidateProperties();                    
    }
    
    /**
     *  @private  
     */
    mx_internal function getTextFlow():TextFlow 
    {
        var richEditableText:RichEditableText = textDisplay as RichEditableText;
        
        if (richEditableText)
            return richEditableText.textFlow;
            
        // If there is no textDisplay, it isn't possible to set one of
        // text, textFlow or content and then get it in another form.

        // want the default to be null
        var v:* = textDisplay ? undefined : textDisplayProperties.textFlow;
        return (v === undefined) ? null : v;
    }
    
    /**
     *  @private
     */
    mx_internal function setTextFlow(value:TextFlow):void
    {
        if (textDisplay)
        {
            var richEditableText:RichEditableText = textDisplay as RichEditableText;
            
            if (richEditableText)
                richEditableText.textFlow = value;
            textDisplayProperties = BitFlagUtil.update(
                                    uint(textDisplayProperties), 
                                    TEXT_FLOW_PROPERTY_FLAG, true);
        }
        else
        {
            textDisplayProperties.textFlow = value;

            // Of 'text', 'textFlow', and 'content', the last one set wins.  So
            // if we're holding onto the properties until the skin is loaded
            // make sure only the last one set is defined.
            textDisplayProperties.text = undefined;
            textDisplayProperties.content = undefined;
        }

        // Generate an UPDATE_COMPLETE event.
        invalidateProperties();                    
    }

	/**
	 *  @see RichEditableText#typicalText
	 *
	 *  @private
	 */
	mx_internal function getTypicalText():String
	{
		var richEditableText:RichEditableText = textDisplay as RichEditableText;
		
		if (richEditableText)
			return richEditableText.typicalText;
		
		// want the default to be null
		var v:* = textDisplay ? undefined : textDisplayProperties.typicalText;
		return (v === undefined) ? null : v;
	}
	
	/**
	 *  @private
	 */
	mx_internal function setTypicalText(value:String):void
	{
		if (textDisplay)
		{
			var richEditableText:RichEditableText = textDisplay as RichEditableText;
			
			if (richEditableText)
				richEditableText.typicalText = value;
			textDisplayProperties = BitFlagUtil.update(
				uint(textDisplayProperties), 
				TYPICAL_TEXT_PROPERTY_FLAG, true);
		}
		else
		{
			textDisplayProperties.typicalText = value;
		}
		
		// Generate an UPDATE_COMPLETE event.
		invalidateProperties();                    
	}

	/**
     *  The default width for the Text components, measured in characters.
     *  The width of the "M" character is used for the calculation.
     *  So if you set this property to 5, it will be wide enough
     *  to let the user enter 5 ems.
     *
     *  @private
     */
    mx_internal function getWidthInChars():Number
    {
        var richEditableText:RichEditableText = textDisplay as RichEditableText;

        if (richEditableText)
            return richEditableText.widthInChars
            
        // want the default to be NaN
        var v:* = textDisplay ? undefined : textDisplayProperties.widthInChars;
        return (v === undefined) ? NaN : v;
    }

    /**
     *  @private
     */
    mx_internal function setWidthInChars(value:Number):void
    {
        if (textDisplay)
        {
            var richEditableText:RichEditableText = textDisplay as RichEditableText;

            if (richEditableText)
                richEditableText.widthInChars = value;
            textDisplayProperties = BitFlagUtil.update(
                uint(textDisplayProperties), 
                WIDTH_IN_CHARS_PROPERTY_FLAG, true);
        }
        else
        {
            textDisplayProperties.widthInChars = value;
        }

        // Generate an UPDATE_COMPLETE event.
        invalidateProperties();                    
    }
    
    /**
     *  @private
     *  Copy values stored locally into textDisplay now that textDisplay 
     *  has been added.
     */
    private function textDisplayAdded():void
    {        
        var newTextDisplayProperties:uint = 0;
        var richEditableText:RichEditableText = textDisplay as RichEditableText;
        
        if (textDisplayProperties.content !== undefined && richEditableText)
        {
            richEditableText.content = textDisplayProperties.content;
            newTextDisplayProperties = BitFlagUtil.update(
                uint(newTextDisplayProperties), CONTENT_PROPERTY_FLAG, true);
        }
 
        if (textDisplayProperties.displayAsPassword !== undefined)
        {
            textDisplay.displayAsPassword = 
                textDisplayProperties.displayAsPassword
            newTextDisplayProperties = BitFlagUtil.update(
                uint(newTextDisplayProperties), 
                DISPLAY_AS_PASSWORD_PROPERTY_FLAG, true);
        }

        if (textDisplayProperties.editable !== undefined)
        {
            textDisplay.editable = textDisplayProperties.editable;
            newTextDisplayProperties = BitFlagUtil.update(
                uint(newTextDisplayProperties), EDITABLE_PROPERTY_FLAG, true);
        }

        if (textDisplayProperties.heightInLines !== undefined && richEditableText)
        {
            richEditableText.heightInLines = textDisplayProperties.heightInLines;
            newTextDisplayProperties = BitFlagUtil.update(
                uint(newTextDisplayProperties), 
                HEIGHT_IN_LINES_PROPERTY_FLAG, true);
        }

        if (textDisplayProperties.imeMode !== undefined && richEditableText)
        {
            richEditableText.imeMode = textDisplayProperties.imeMode;
            newTextDisplayProperties = BitFlagUtil.update(
                uint(newTextDisplayProperties), IME_MODE_PROPERTY_FLAG, true);
        }

        if (textDisplayProperties.maxChars !== undefined)
        {
            textDisplay.maxChars = textDisplayProperties.maxChars;
            newTextDisplayProperties = BitFlagUtil.update(
                uint(newTextDisplayProperties), MAX_CHARS_PROPERTY_FLAG, true);
        }

        if (textDisplayProperties.maxHeight !== undefined && richEditableText)
        {
            richEditableText.maxHeight = textDisplayProperties.maxHeight;
            newTextDisplayProperties = BitFlagUtil.update(
                uint(newTextDisplayProperties), MAX_HEIGHT_PROPERTY_FLAG, true);
        }
        
        if (textDisplayProperties.maxWidth !== undefined && richEditableText)
        {
            richEditableText.maxWidth = textDisplayProperties.maxWidth;
            newTextDisplayProperties = BitFlagUtil.update(
                uint(newTextDisplayProperties), MAX_WIDTH_PROPERTY_FLAG, true);
        }

        if (textDisplayProperties.restrict !== undefined)
        {
            textDisplay.restrict = textDisplayProperties.restrict;
            newTextDisplayProperties = BitFlagUtil.update(
                uint(newTextDisplayProperties), RESTRICT_PROPERTY_FLAG, true);
        }

        if (textDisplayProperties.selectable !== undefined)
        {
            textDisplay.selectable = textDisplayProperties.selectable;
            newTextDisplayProperties = BitFlagUtil.update(
                uint(newTextDisplayProperties), SELECTABLE_PROPERTY_FLAG, true);
        }

        if (textDisplayProperties.selectionHighlighting !== undefined && richEditableText)
        {
            richEditableText.selectionHighlighting = 
                textDisplayProperties.selectionHighlighting;
            newTextDisplayProperties = BitFlagUtil.update(
                uint(newTextDisplayProperties), 
                SELECTION_HIGHLIGHTING_FLAG, true);
        }
            
        if (textDisplayProperties.text != null)
        {
            textDisplay.text = textDisplayProperties.text;
            newTextDisplayProperties = BitFlagUtil.update(
                uint(newTextDisplayProperties), TEXT_PROPERTY_FLAG, true);
        }

        if (textDisplayProperties.textFlow !== undefined && richEditableText)
        {
            richEditableText.textFlow = textDisplayProperties.textFlow;
            newTextDisplayProperties = BitFlagUtil.update(
                uint(newTextDisplayProperties), TEXT_FLOW_PROPERTY_FLAG, true);
        }

		if (textDisplayProperties.typicalText !== undefined && richEditableText)
		{
			richEditableText.typicalText = textDisplayProperties.typicalText;
			newTextDisplayProperties = BitFlagUtil.update(
				uint(newTextDisplayProperties), 
				TYPICAL_TEXT_PROPERTY_FLAG, true);
		}
		
        if (textDisplayProperties.widthInChars !== undefined && richEditableText)
        {
            richEditableText.widthInChars = textDisplayProperties.widthInChars;
            newTextDisplayProperties = BitFlagUtil.update(
                uint(newTextDisplayProperties), 
                WIDTH_IN_CHARS_PROPERTY_FLAG, true);
        }
            
        // Switch from storing properties to bit mask of stored properties.
        textDisplayProperties = newTextDisplayProperties;    
    }
    
    /**
     *  @private
     *  Copy values stored in textDisplay back to local storage since 
     *  textDisplay is about to be removed.
     */
    private function textDisplayRemoved():void
    {        
        var newTextDisplayProperties:Object = {};
        var richEditableText:RichEditableText = textDisplay as RichEditableText;
        
        if (BitFlagUtil.isSet(uint(textDisplayProperties), 
                              DISPLAY_AS_PASSWORD_PROPERTY_FLAG))
        {
            newTextDisplayProperties.displayAsPassword = 
                textDisplay.displayAsPassword;
        }

        if (BitFlagUtil.isSet(uint(textDisplayProperties), 
                              EDITABLE_PROPERTY_FLAG))
        {
            newTextDisplayProperties.editable = textDisplay.editable;
        }
        
        if (BitFlagUtil.isSet(uint(textDisplayProperties), 
                              HEIGHT_IN_LINES_PROPERTY_FLAG) && richEditableText)
        {
            newTextDisplayProperties.heightInLines = richEditableText.heightInLines;
        }

        if (BitFlagUtil.isSet(uint(textDisplayProperties), 
                              IME_MODE_PROPERTY_FLAG) && richEditableText)
        {
            newTextDisplayProperties.imeMode = richEditableText.imeMode;
        }
        
        if (BitFlagUtil.isSet(uint(textDisplayProperties), 
                              MAX_CHARS_PROPERTY_FLAG))
        {
            newTextDisplayProperties.maxChars = textDisplay.maxChars;
        }

        if (BitFlagUtil.isSet(uint(textDisplayProperties), 
            MAX_HEIGHT_PROPERTY_FLAG) && richEditableText)
        {
            newTextDisplayProperties.maxHeight = richEditableText.maxHeight;
        }

        if (BitFlagUtil.isSet(uint(textDisplayProperties), 
                              MAX_WIDTH_PROPERTY_FLAG) && richEditableText)
        {
            newTextDisplayProperties.maxWidth = richEditableText.maxWidth;
        }

        if (BitFlagUtil.isSet(uint(textDisplayProperties), 
                              RESTRICT_PROPERTY_FLAG))
        {
            newTextDisplayProperties.restrict = textDisplay.restrict;
        }
        
        if (BitFlagUtil.isSet(uint(textDisplayProperties), 
                              SELECTABLE_PROPERTY_FLAG))
        {
            newTextDisplayProperties.selectable = textDisplay.selectable;
        }

        if (BitFlagUtil.isSet(uint(textDisplayProperties), 
                              SELECTION_HIGHLIGHTING_FLAG) && richEditableText)
        {
            newTextDisplayProperties.selectionHighlighting = 
                richEditableText.selectionHighlighting;
        }
            
        // Text is special.            
        if (BitFlagUtil.isSet(uint(textDisplayProperties), TEXT_PROPERTY_FLAG))
            newTextDisplayProperties.text = textDisplay.text;

        // Content is just a setter.  So if it was set, get the textFlow
        // instead.        
        if (BitFlagUtil.isSet(uint(textDisplayProperties), 
                TEXT_FLOW_PROPERTY_FLAG) || 
            BitFlagUtil.isSet(uint(textDisplayProperties), 
                CONTENT_PROPERTY_FLAG) && richEditableText)
        {
            newTextDisplayProperties.textFlow = richEditableText.textFlow;
        }

        if (BitFlagUtil.isSet(uint(textDisplayProperties), 
                              TYPICAL_TEXT_PROPERTY_FLAG) && richEditableText)
        {
            newTextDisplayProperties.typicalText = richEditableText.typicalText;
        }
            
		if (BitFlagUtil.isSet(uint(textDisplayProperties), 
			WIDTH_IN_CHARS_PROPERTY_FLAG) && richEditableText)
		{
			newTextDisplayProperties.widthInChars = richEditableText.widthInChars;
		}
		
        // Switch from storing bit mask to storing properties.
        textDisplayProperties = newTextDisplayProperties;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function focusInHandler(event:FocusEvent):void
    {
        if (event.target == this)
        {
            // call setFocus on ourselves to pass focus to the
            // textDisplay.  This situation occurs when the
            // player occasionally takes over the first TAB
            // on a newly activated Window with nothing currently
            // in focus
            setFocus();
            return;
        }

        // Only editable text should have a focus ring.
        if (enabled && editable && focusManager)
            focusManager.showFocusIndicator = true;

        invalidateSkinState();
        
        super.focusInHandler(event);
    }
 
    /**
     *  @private
     */
    override protected function focusOutHandler(event:FocusEvent):void
    {
        if (event.target == this)
            return;
        
        invalidateSkinState();
        
        super.focusOutHandler(event);
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Called when the RichEditableText dispatches a 'selectionChange' event.
     */
    private function textDisplay_selectionChangeHandler(event:Event):void
    {
        // Redispatch the event that came from the RichEditableText.
        dispatchEvent(event);
    }

    /**
     *  Called when the RichEditableText dispatches a 'change' event
     *  after an editing operation.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    private function textDisplay_changeHandler(event:Event):void
    {        
        //trace(id, "textDisplay_changeHandler", textDisplay.text);
        
        // The text component has changed.  Generate an UPDATE_COMPLETE event.
        invalidateDisplayList();
        
        // Redispatch the event that came from the RichEditableText.
        dispatchEvent(event);
    }

    /**
     *  @private
     *  Called when the RichEditableText dispatches a 'changing' event
     *  before an editing operation.
     */
    private function textDisplay_changingHandler(event:TextOperationEvent):void
    {
        // Redispatch the event that came from the RichEditableText.
        var newEvent:Event = event.clone();
        dispatchEvent(newEvent);
        
        // If the event dispatched from this component is canceled,
        // cancel the one from the RichEditableText, which will prevent
        // the editing operation from being processed.
        if (newEvent.isDefaultPrevented())
            event.preventDefault();
    }

    /**
     *  @private
     *  Called when the RichEditableText dispatches an 'enter' event
     *  in response to the Enter key.
     */
    private function textDisplay_enterHandler(event:Event):void
    {
        // Redispatch the event that came from the RichEditableText.
        dispatchEvent(event);
    }

    /**
     *  @private
     *  Called when the RichEditableText dispatches an 'valueCommit' event
     *  when values are changed programmatically or by user interaction.
     *  Before the textDisplay part is loaded, any properties set are held
     *  in textDisplayProperties.  We don't want to dispatch 'valueCommit' when 
     *  there isn't a textDisplay since since the event will be dispatched by 
     *  RET when the textDisplay part is added.
     */
    private function textDisplay_valueCommitHandler(event:Event):void
    {
        // Redispatch the event that came from the RichEditableText.
        dispatchEvent(event);
    }
    
    /**
     *  @private
     */
    private function touchInteractionStartingHandler(event:TouchInteractionEvent):void
    {
        // This implementation prevents the scroll from happening, which means
        // the touch interaction will be interpreted by the text (ie selection).
        if (selectable || editable)
            event.preventDefault();
    }
}

}
