////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components.supportClasses
{
import flash.geom.Rectangle;

import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;

public class GridDimensions 
{
    include "../../core/Version.as";
    
    /**
     *  @private
     *  Restrict a number to a particular min and max.
     */
    private static function bound(a:Number, min:Number, max:Number):Number
    {
        if (a < min)
            a = min;
        else if (a > max)
            a = max;
        
        return a;
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    private var rowList:GridRowList = new GridRowList();
    private var _columnWidths:Vector.<Number>;

    //cache for cumulative y values.
    private var startY:Number = 0;
    private var recentNode:GridRowNode = null;
    
    private const typicalCellWidths:Array = new Array();
    private const typicalCellHeights:Array = new Array();
    private var isFirstTypicalCellHeight:Boolean = true;
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor
     */
    public function GridDimensions()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  rowCount
    //----------------------------------
    
    private var _rowCount:int = 0;
    
    /**
     *  The number of rows in the Grid. If this is decreased, the 
     *  excess rows will be removed.
     */
    public function get rowCount():int
    {
        return _rowCount;
    }
    
    /**
     *  @private
     */
    public function set rowCount(value:int):void
    {
        if (value == _rowCount)
            return;
        
        _rowCount = value;
        // FIXME (klin): remove a range of indices...
    }
    
    //----------------------------------
    //  columnCount
    //----------------------------------
    
    private var _columnCount:int = 0;
    
    /**
     *  The number of columns in the Grid. If this is decreased, the 
     *  excess columns will be removed.
     */
    public function get columnCount():int
    {
        return _columnCount;
    }
    
    /**
     *  @private
     */
    public function set columnCount(value:int):void
    {
        if (value == _columnCount)
            return;
        
        _columnCount = rowList.numColumns = value;
        
        var i:int;
        
        if (!_columnWidths)
        {
            _columnWidths = new Vector.<Number>(_columnCount);
            
            for (i = 0; i < _columnCount; i++)
                _columnWidths[i] = NaN;
        }
        else
        {
            var temp:int = _columnWidths.length;
            _columnWidths.length = _columnCount;
            
            if (temp < _columnCount)
            {
                for (i = temp; i < _columnCount; i++)
                    _columnWidths[i] = NaN;
                
                if (_columnCount == 0)
                {
                    clearTypicalCellWidthsAndHeights();
                }
                else
                {
                    typicalCellWidths.length = _columnCount;
                    typicalCellHeights.length = _columnCount;
                }

            }
        }
    }

    //----------------------------------
    //  rowGap
    //----------------------------------
    
    /**
     *  The gap between rows.
     * 
     *  @default 0 
     */
    public var rowGap:Number = 0;
    
    //----------------------------------
    //  columnGap
    //----------------------------------
    
    /**
     *  The gap between columns. 
     *      
     *  @default 0 
     */
    public var columnGap:Number = 0;
    
    //----------------------------------
    //  defaultRowHeight
    //----------------------------------
    
    private var _defaultRowHeight:Number = 22;
    
    /**
     *  The default height of a row. The defaultRowHeight is always
     *  bounded by the minRowHeight and maxRowHeight.
     */
    public function get defaultRowHeight():Number
    {
        return _defaultRowHeight;
    }
    
    /**
     *  @private
     */
    public function set defaultRowHeight(value:Number):void
    {
        if (value == _defaultRowHeight)
            return;
        
        _defaultRowHeight = bound(value, _minRowHeight, _maxRowHeight);
        
        // reset recent node.
        recentNode = null;
    }
    
    //----------------------------------
    //  defaultColumnWidth
    //----------------------------------
    
    /**
     *  The default width of a column.
     */
    public var defaultColumnWidth:Number = 150;
    
    //----------------------------------
    //  fixedRowHeight
    //----------------------------------
    
    private var _fixedRowHeight:Number = NaN;
    
    /**
     *  If fixedRowHeight is set, calling getRowHeight will return
     *  its value for every row. Individual cell heights are not
     *  affected, but calling getCellBounds will return bounds
     *  respecting fixedRowHeight. The fixedRowHeight is always
     *  bounded by the minRowHeight and maxRowHeight.
     * 
     *  @default NaN
     */
    public function get fixedRowHeight():Number
    {
        return _fixedRowHeight;
    }
    
    /**
     *  @private
     */
    public function set fixedRowHeight(value:Number):void
    {
        if (value == _fixedRowHeight)
            return;
        
        _fixedRowHeight = bound(value, _minRowHeight, _maxRowHeight);
    }
    
    //----------------------------------
    //  minRowHeight
    //----------------------------------
    
    private var _minRowHeight:Number = 0;
    
    /**
     *  The minimum height of each row.
     * 
     *  @default 0
     */
    public function get minRowHeight():Number
    {
        return _minRowHeight;
    }
    
    /**
     *  @private
     */
    public function set minRowHeight(value:Number):void
    {
        if (value == _minRowHeight)
            return;
        
        _minRowHeight = value;
        _defaultRowHeight = Math.max(_defaultRowHeight, _minRowHeight);
        _fixedRowHeight = Math.max(_fixedRowHeight, _minRowHeight);
    }
    
    //----------------------------------
    //  maxRowHeight
    //----------------------------------
    
    private var _maxRowHeight:Number = 10000;
    
    /**
     *  The maximum height of each row.
     * 
     *  @default 10000
     */
    public function get maxRowHeight():Number
    {
        return _maxRowHeight;
    }
    
    /**
     *  @private
     */
    public function set maxRowHeight(value:Number):void
    {
        if (value == _maxRowHeight)
            return;
        
        _maxRowHeight = value;
        _defaultRowHeight = Math.min(_defaultRowHeight, _maxRowHeight);
        _fixedRowHeight = Math.min(_fixedRowHeight, _maxRowHeight);
    }

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Returns the height of the row at the given index. Returns the
     *  fixedRowHeight if set. If not, returns the height specified by
     *  setRowHeight. If no height has been specified, returns the
     *  natural height of the row (maximum height of its cells. If the
     *  cells haven't been cached, returns defaultRowHeight.
     *  The return value is always bounded by the minRowHeight and
     *  maxRowHeight.
     */
    public function getRowHeight(row:int):Number
    {
        // Unless setRowHeight is called, return the max cell height for this row
        var height:Number = defaultRowHeight;
        
        if (!isNaN(fixedRowHeight))
        {
            height = fixedRowHeight;
        }
        else
        {
            var node:GridRowNode = rowList.find(row);
            if (node)
            {
                if (!isNaN(node.fixedHeight))
                    height = node.fixedHeight;
                else if (!isNaN(node.maxCellHeight))
                    height = node.maxCellHeight;
            }
        }
        
        return bound(height, minRowHeight, maxRowHeight);
    }
    
    /**
     *  Sets the height of a given row. This height takes precedence over
     *  the natural height of the row (determined by the maximum of its 
     *  cell heights) and the defaultRowHeight. However, fixedRowHeight
     *  takes precedence over this height.
     */
    public function setRowHeight(row:int, height:Number):void
    {
        if (!isNaN(fixedRowHeight))
            return;
        
        var node:GridRowNode = rowList.find(row);
        
        if (node)
        {
            node.fixedHeight = bound(height, minRowHeight, maxRowHeight);
        }
        else
        {
            node = rowList.insert(row);
            
            if (node)
                node.fixedHeight = bound(height, minRowHeight, maxRowHeight);
        }
    }

    /**
     *  Returns the width of the column at the given index. Returns
     *  the width specified by setColumnWidth. If no width has been
     *  specified, returns the defaultColumnWidth.
     */
    public function getColumnWidth(col:int):Number
    {    
        var w:Number = NaN;
        
        // out of bounds col will throw an error..should we handle it?
        if (_columnWidths)
            w = _columnWidths[col];
        
        if (!isNaN(w))
            return w;
        
        return this.defaultColumnWidth;
    }
    
    /**
     *  Sets the height of a given row. This height takes precedence over
     *  the natural height of the row (determined by the maximum of its 
     *  cell heights) and the defaultRowHeight. However, fixedRowHeight
     *  takes precedence over this height.
     */
    public function setColumnWidth(col:int, width:Number):void
    {
        // out of bounds col will throw an error..should we handle it?
        if (_columnWidths)
            _columnWidths[col] = width;
    }

    /**
     *  Returns the height of the specified cell. Returns the height
     *  set by setCellHeight. If the height has not been specified,
     *  returns NaN.
     */
    public function getCellHeight(row:int, col:int):Number
    {
        var node:GridRowNode = rowList.find(row);
        
        if (node)
            return node.getCellHeight(row);
        
        return NaN;
    }
    
    /**
     *  Sets the height of the specified cell.
     */
    public function setCellHeight(row:int, col:int, height:Number):void
    {
        if (!isNaN(fixedRowHeight))
            return;
        
        var node:GridRowNode = rowList.insert(row);
        
        if (node)
        {
           if (node.setCellHeight(col, height))
                recentNode = null;
        }
    }
    
    /**
     *  Returns the layout bounds of the specified cell. The cell height
     *  and width are determined by its row's height and column's width.
     */
    public function getCellBounds(row:int, col:int):Rectangle
    {
        // TBD: provide optional return value (Rectangle) parameter
        if (row < 0 || row >= rowCount || col < 0 || col >= columnCount)
            return null;
        
        var x:Number = getCellX(row, col);
        var y:Number = getCellY(row, col);
        
        var width:Number = getColumnWidth(col);
        var height:Number = getRowHeight(row);
        
        return new Rectangle(x, y, width, height);
    }
    
    /**
     *  Returns the X coordinate of the origin of the specified cell.
     */
    public function getCellX(row:int, col:int):Number
    {
        if (!_columnWidths)
            return col * (defaultColumnWidth + columnGap);
        
        var x:Number = 0;
        
        for (var i:int = 0; i < col; i++)
        {
            var temp:Number = _columnWidths[i];
            
            if (isNaN(temp))
                x += defaultColumnWidth + columnGap;
            else
                x += temp + columnGap;
        }
        
        return x;
    }
    
    /**
     *  Returns the Y coordinate of the origin of the specified cell.
     */
    public function getCellY(row:int, col:int):Number
    {        // no cache so we use default heights for each row.
        if (!isNaN(fixedRowHeight))
            return row * (fixedRowHeight + rowGap);
        
        if (rowList.length == 0)
            return row * (defaultRowHeight + rowGap);
        
        var node:GridRowNode = rowList.first;
        var y:Number = 0;
        var index:int = 0;
        
        while (node)
        {
            // success case: row index is <= to node's index.
            if (row <= node.rowIndex)
            {
                y += (row - index) * (defaultRowHeight + rowGap);
                return y;
            }
            
            // otherwise, row index is > node's index
            
            // case if node index is much greater than current index.
            if (node.rowIndex > index)
            {
                y += (node.rowIndex - index) * (defaultRowHeight + rowGap);
                index += node.rowIndex - index; // index == node.rowIndex
            }
            
            // index is now equal to node's index but row index is > node's index so we add node.
            y += node.maxCellHeight;
            index++;
            node = node.next;
        }
        
        // no more nodes, so we just add the rest.
        y += (row - index) * (defaultRowHeight + rowGap);
        return y;
    }
    
    /**
     *  Returns the layout bounds of the specified row.
     */
    public function getRowBounds(row:int):Rectangle
    {
        // TBD: provide optional return value (Rectangle) parameter    
        if ((row < 0) || (row >= rowCount))
            return null;  // TBD: return empty Rectangle instead
        
        const x:Number = getCellX(row, 0);
        const y:Number = getCellY(row, 0);
        const rowWidth:Number = getCellX(row, columnCount - 1) + getColumnWidth(columnCount - 1) - x;
        const rowHeight:Number = getRowHeight(row);
        return new Rectangle(x, y, rowWidth, rowHeight);
    }
    
    /**
     *  Returns the layout bounds of the specified column.
     */
    public function getColumnBounds(col:int):Rectangle
    {
        // TBD: provide optional return value (Rectangle) parameter
        if ((col < 0) || (col >= columnCount))
            return null;  // TBD: return empty Rectangle instead

        const x:Number = getCellX(0, col);
        const y:Number = getCellY(0, col);
        const colWidth:Number = getColumnWidth(col);
        const colHeight:Number = getCellY(rowCount - 1, col) + getCellHeight(rowCount - 1, col) - y;
        return new Rectangle(x, y, colWidth, colHeight);
    }
    
    /**
     *  Returns the index of the row at the specified coordinates. If
     *  the coordinates lie in a gap area, the index returned is the
     *  previous row.
     * 
     *  @return The index of the row at the coordinates provided. If the
     *  coordinates are out of bounds, return -1.
     */
    public function getRowIndexAt(x:Number, y:Number):int
    {
        if (y < 0)
            return -1;
        
        if (!isNaN(fixedRowHeight))
            return y / (fixedRowHeight + rowGap);
        
        if (rowList.length == 0)
            return y / (defaultRowHeight + rowGap);
        
        if (y == 0)
        {
            recentNode = null;
            return 0;
        }
        
        // initialize first node.
        if (!recentNode)
        {
            recentNode = rowList.first;
            startY = recentNode.rowIndex * (defaultRowHeight + rowGap);
        }
        
        var index:int;
        
        // if we are already at the right row, then use the index.
        if (isYInRow(y, startY, recentNode))
            index = recentNode.rowIndex;
        else if (y < startY)
            index = getPrevRowIndexAt(y, recentNode, startY);
        else
            index = getNextRowIndexAt(y, recentNode, startY);
        
        return index;
    }
    
    /**
     *  Checks if a certain y value lies in a row's bounds.
     */
    private function isYInRow(y:Number, startY:Number, node:GridRowNode):Boolean
    {
        var end:Number = startY + node.maxCellHeight;
        
        // don't add gap for last row.
        if (node.rowIndex != rowCount - 1)
            end += rowGap;
        
        // if y is between cumY and cumY + rowHeight - 1 then y is in the row.
        if (y >= startY && y < end)
            return true;
        
        return false;
    }
    
    /**
     *  Returns the index of the row that contains the specified y value.
     *  The row will be before startNode.
     *  
     *  @param y the target y value
     *  @param startNode the node to search from
     *  @param startY the cumulative y value from the first row to startNode
     * 
     *  @return the index of the row that contains the y value.
     */
    private function getPrevRowIndexAt(y:Number, startNode:GridRowNode, startY:Number):int
    {
        var node:GridRowNode = startNode;
        var prevNode:GridRowNode = null;
        var index:int = node.rowIndex;
        var currentY:Number = startY;
        var prevY:Number;
        var targetY:Number = y;
        
        while (node)
        {
            // check the current node.
            if (isYInRow(targetY, currentY, node))
                break;
            
            // calculate previous y.
            prevNode = node.prev;
            
            if (!prevNode)
            {
                prevY = 0;
            }
            else
            {
                prevY = currentY;
                
                var indDiff:int = node.rowIndex - prevNode.rowIndex;
                
                // subtract default row heights if difference is greater than one.
                if (indDiff > 1)
                    prevY -= (indDiff - 1) * (defaultRowHeight + rowGap);
            }
            
            // check if target Y is in range.
            if (targetY < currentY && targetY >= prevY)
            {
                index = index - Math.ceil(Number(currentY - targetY)/(defaultRowHeight + rowGap));
                break;
            }

            // subtract previous node's height and its gap.
            currentY = prevY - prevNode.maxCellHeight - rowGap;
            node = node.prev;
            index = node.rowIndex;
        }
        
        this.recentNode = node;
        this.startY = currentY;
        
        return index;
    }
    
    /**
     *  Returns the index of the row that contains the specified y value.
     *  The row will be after startNode.
     *  
     *  @param y the target y value
     *  @param startNode the node to search from
     *  @param startY the cumulative y value from the first row to startNode
     * 
     *  @return the index of the row that contains the y value.
     */
    private function getNextRowIndexAt(y:Number, startNode:GridRowNode, startY:Number):int
    {
        var node:GridRowNode = startNode;
        var nextNode:GridRowNode = null;
        var index:int = node.rowIndex;
        var nodeY:Number = startY;
        var currentY:Number = startY;
        var nextY:Number;
        var targetY:Number = y;

        while (node)
        {
            // check the current node.
            if (isYInRow(targetY, nodeY, node))
                break;
            
            // currentY increments to end of the current node.
            currentY += node.maxCellHeight;
            if (node.rowIndex != rowCount - 1)
                currentY += rowGap;
            
            // calculate end of next section.
            nextNode = node.next;
            nextY = currentY;
            
            var indDiff:int;
            
            if (!nextNode)
            {
                indDiff = rowCount - 1 - node.rowIndex;
                // the y at the end doesn't have a rowGap, but includes the final pixel.
                nextY += indDiff * (defaultRowHeight + rowGap) - rowGap + 1;
            }
            else
            {
                indDiff = nextNode.rowIndex - node.rowIndex;
                nextY += (indDiff - 1) * (defaultRowHeight + rowGap);
            }
            
            // check if target Y is within default row heights range.
            if (targetY >= currentY && targetY < nextY)
            {
                index = index - Math.ceil(Number(currentY - targetY)/(defaultRowHeight + rowGap));
                break;
            }
            
            // if no next node and we didn't find the target, then the row doesn't exist.
            if (!nextNode)
            {
                index = -1;
                break;
            }
            
            // move y values ahead to next node.
            nodeY = currentY = nextY;
            
            node = node.next;
            index = node.rowIndex;
        }
        
        this.recentNode = node;
        this.startY = nodeY;
        
        return index;
    }
    
    /**
     *  Returns the index of the column at the specified coordinates. If
     *  the coordinates lie in a gap area, the index returned is the
     *  previous column. Returns -1 if the coordinates are out of bounds.
     */
    public function getColumnIndexAt(x:Number, y:Number):int
    {
        if (!_columnWidths)
            return x / (defaultColumnWidth + columnGap);
        
        var cur:Number = x;
        var i:int;
        
        for (i = 0; i < _columnCount; i++)
        {
            var temp:Number = _columnWidths[i];
            
            if (isNaN(temp))
                cur -= defaultColumnWidth + columnGap;
            else
                cur -= temp + columnGap;
            
            if (cur < 0)
                return i;
        }
        
        return -1;
    }
    
    /**
     *  Returns the total layout width of the content including gaps.   If 
	 *  columnCountOverride is specified, then the overall width of as many columns
	 *  is returned.
     */
    public function getContentWidth(columnCountOverride:int = -1):Number
    {
		const nCols:int = (columnCountOverride == -1) ? columnCount : columnCountOverride;
		
        if (!_columnWidths)
            return (nCols * (defaultColumnWidth + columnGap)) - columnGap;
        
        var width:Number = 0;
        
        for (var i:int = 0; i < nCols; i++)
        {
            if ((i >= _columnWidths.length) || isNaN(_columnWidths[i]))
                width += defaultColumnWidth + columnGap;
            else
                width += _columnWidths[i] + columnGap;
        }
        
        return width - columnGap;
    }
    
    /**
     *  Returns the total layout height of the content including gaps.  If 
	 *  rowHeightOverride is specified, then the overall height of as many rows
	 *  is returned.
     */
    public function getContentHeight(rowCountOverride:int = -1):Number
    {
		const nRows:int = (rowCountOverride == -1) ? rowCount : rowCountOverride;
		
        if (!isNaN(fixedRowHeight))
            return (nRows * (fixedRowHeight + rowGap)) - rowGap;
        
        if (rowList.length == 0)
            return (nRows * (defaultRowHeight + rowGap)) - rowGap;
        
        var height:Number = 0;
        var node:GridRowNode = rowList.first;
        var numRows:int = 0;
        
        while (node)
        {
            height += node.maxCellHeight;
            numRows++;
            node = node.next;
        }
        
        return height + ((nRows - numRows) * (defaultRowHeight) + (nRows - 1) * rowGap);
    }
    
    /**
     *  Return the preferred bounds width of the grid's typicalItem when rendered with the item renderer 
     *  for the specified column.  If no value has yet been specified, return NaN.
     */
    public function getTypicalCellWidth(columnIndex:int):Number
    {
        return typicalCellWidths[columnIndex];
    }
    
    /**
     *  Sets the preferred bounds width of the grid's typicalItem for the specified column.
     */
    public function setTypicalCellWidth(columnIndex:int, value:Number):void
    {
        typicalCellWidths[columnIndex] = value;
    }
    
    /**
     *  Return the preferred bounds height of the grid's typicalItem when rendered with the item renderer 
     *  for the specified column.  If no value has yet been specified, return NaN.
     */    
    public function getTypicalCellHeight(columnIndex:int):Number
    {
        return typicalCellHeights[columnIndex];
    }
    
    /**
     *  Sets the preferred bounds height of the grid's typicalItem for the specified column.
     */    
    public function setTypicalCellHeight(columnIndex:int, value:Number):void
    {
        typicalCellHeights[columnIndex] = value;
        
        // if this is the first cell height, set default to it
        if (isFirstTypicalCellHeight)
        {
            this.defaultRowHeight = value;
            isFirstTypicalCellHeight = false;
        }
        else
        {
            // otherwise, find the max of the typical cell heights.
            var max:Number = 0;
            for (var i:int = 0; i < typicalCellHeights.length; i++)
                max = Math.max(max, typicalCellHeights[i]);
            this.defaultRowHeight = max;
        }
    }
    
    public function clearTypicalCellWidthsAndHeights():void
    {
        typicalCellWidths.length = 0;
        typicalCellHeights.length = 0;
        defaultRowHeight = 22;
        isFirstTypicalCellHeight = true;
    }
        
    /**
     *  Inserts count number of rows starting from startRow. This shifts
     *  any rows after startRow down by count and will increment 
     *  rowCount.
     */
    public function insertRows(startRow:int, count:int):void
    {
        var startNode:GridRowNode = rowList.findNearest(startRow);
        var tempNode:GridRowNode;
        
        // shift indices by count.
        if (startNode)
            tempNode = startNode.next;
        while (tempNode)
        {
            tempNode.rowIndex += count;
            tempNode = tempNode.next;
        }
        
        this.rowCount += count;
    }
    
    /**
     *  Inserts count number of columns starting from startColumn. This
     *  shifts any columns after startColumn down by count and will
     *  increment columnCount. 
     */
    public function insertColumns(startColumn:int, count:int):void
    {
    }
    
    /**
     *  Removes count number of rows starting from startRow. This
     *  shifts any rows after startRow up by count and will
     *  decrement rowCount.
     */
    public function removeRows(startRow:int, count:int):void
    {
    }
    
    /**
     *  Removes count number of columns starting from startColumn. This
     *  shifts any columns after startColumn up by count and will
     *  decrement columnCount.
     */
    public function removeColumns(startColumn:int, count:int):void
    {
    }
    
    /**
     *  Moves count number of rows from the fromRow index to the toRow
     *  index. This operation will not affect rowCount.
     */
    public function moveRows(fromRow:int, toRow:int, count:int):void
    {
    }
    
    /**
     *  Moves count number of columns from the fromCol index to the toCol
     *  index. This operation will not affect colCount.
     */
    public function moveColumns(fromCol:int, toCol:int, count:int):void
    {
    }
    
    /**
     *  Removes all cells and sets rowCount to 0.
     */
    public function clear():void
    {
        rowCount = 0;
        rowList.removeAll();
        this.recentNode = null;
        this.startY = 0;
    }

    /**
     *  Handles changes in the dataProvider.
     */
    public function dataProviderCollectionChanged(event:CollectionEvent):Boolean 
    {
        switch (event.kind)
        {
            case CollectionEventKind.ADD:    return dataProviderCollectionAdd(event);
            case CollectionEventKind.REMOVE: return dataProviderCollectionRemove(event);
                
            case CollectionEventKind.REPLACE:
            case CollectionEventKind.MOVE:
            case CollectionEventKind.REFRESH:
            case CollectionEventKind.RESET:
            case CollectionEventKind.UPDATE:
                break;
        }
        
        return false;
    }
    
    /**
     *  @private
     */
    private function dataProviderCollectionAdd(event:CollectionEvent):Boolean
    {
        rowCount +=  event.items.length;
        return true;
    }
    
    /**
     *  @private
     */
    private function dataProviderCollectionRemove(event:CollectionEvent):Boolean
    {
        rowCount -= event.items.length;
        return true;
    }
}
}