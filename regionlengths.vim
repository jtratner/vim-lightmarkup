" TODO: harmonize use of variables by the simple and complicated complex tables


" These two functions should be called on entry and exit to LightMarkup
" In other words, all commands should be of form:
" command! LMsomething :call SaveEnvironment()<CR>:<line1>,<line2>call LMsomething<CR>:call RestoreEnvironment
" TODO: this doesn't work,fix it.
function! SaveEnvironment()
    if !exists("b:saved_environment")
        " TODO: save cursor position too
        let cursorpos = getpos('.')
        echo cursorpos
        let b:saved_environment = ":set tw=".&tw.":set fo=".&fo.":set fdm=".&fdm.":call setpos('.', ".string(cursorpos)." )"
        echo b:saved_environment
    endif
endfunction
function! RestoreEnvironment()
    if exists("b:saved_environment")
        exe b:saved_environment
        echo b:saved_environment
    endif
    " erase the variable so that if SaveEnvironment called again will restore
    unlet b:saved_environment
endfunction

" Kudos to Christian Brabandt for this simple solution to summing a list
function! SumList(lst)
    if len(a:lst) == 0
        "empty list defined as sum of 0 (by me)
        return 0
    elseif type(a:lst) == type(0)
        return a:lst
    elseif (len(a:lst) == 1) && (type(a:lst) == type([]))
        " if only one item, convert it to a number (best way to be sure a number is returned, methinks)
        return str2nr(string(a:lst[0]))
    else
        return eval(join(a:lst,' + '))
    endif
endfunction

let g:LMColSep = '|'
" PadItem(str,length, [prepad,[postpad,[spacer)
" str - string to be padded
" length - the length to pad it to
" prepad, postpad (optional) - strings to place
" pads given item in addition can give the following extra arguments:
" prepad: str
" postpad: str
" spacer: str (to pad with - single character only for nwo)
" where prepad and postpad are text to be added before and after
" NOTE: PadItem does not count the length of prepad or postpad in its spacing,
" so be aware of that when using it with other positioning
function! PadItem(str,length,...)
    " string should be padded with length - strlen(str) spacers
    let prepad=get(a:000,0,'')
    let postpad=get(a:000,1,'')
    let spacer=get(a:000,2,' ')
    " finally, insert the spacer
    return prepad.a:str.repeat(spacer,a:length - strlen(a:str)).postpad
endfunction


function! NestedLength(lst)
    " need this copy here so we don't overwrite the list of lines grabbed from
    " text
    return map(copy(a:lst), 'len(v:val)')
endfunction

" GetMaxLengths(nested_list)
" takes in a list of lists and returns the maximum length of each index of nested list
" the nested lists do NOT have to be the same length
" e.g.
" [[1,2],[12,12]] would return [2,2]
" [[1234,12,3],[123456789,1]] would return [9,2,1]
" [[1],[2],[[],[],32],[[],[],[],[]]] would return [1,0,2,0]
" within LightMarkup, used to get the length of each region for table formatting

function! GetMaxLengths(nested_list)
    " minifunction to get the length of the list of lists
    " make a list of lengths of each region
    let nested_lengths = map(copy(a:nested_list), 'NestedLength(v:val)')
    let col_widths = []
    " go line by line
    for line in nested_lengths
        " set i to zero so we can sync our place with col_width
        for iter in range(0,len(line)-1)
            " if the current region is longer than the current value for the region, store it
            " NOTE: using get() here to avoid list index errors (returns 0 if doesn't exist)
            " if col_widths doesn't have the current item, then store the
            " rest and stop going through line
            if (get(col_widths, iter, "NONE") == "NONE")
                call extend(col_widths, line[iter :])
                break
            endif
            let col_widths[iter] = col_widths[iter] < line[iter] ? line[iter] : col_widths[iter]
        endfor
    endfor
    return col_widths
endfunction

"separator to use for initial table detection
let g:LMDefaultSeparator='\s\{2,}'


" given a first and last line, and a separator regex, returns the given lines
" split by regex
function! GetLinesAndSplit(first,last,separator)
    let separator=a:separator
    let linelist = []
    for i in range(a:first, a:last)
        " TODO: possibly change this so it keeps the spacing too,
        " allowing for detection of multiple blank columns (for now
        " that's not happening, and it will just assume a blank column
        " is not formatted (so basically this only converts simple
        " tables)
        let linelist += [split(getline(i),separator,1)]
    endfor
    return linelist
endfunction

function! PadRegions(line,col_widths,sep,space)
    " slightly ugly to do it this way, but I don't have to rely on tlib zip,
    " which is a bonus
    let iter = 0
    " can't change the value of function arguments, so have to copy to store
    " in a new reference (possibly) TODO: make sure this is true
    let newline = a:sep
    for region in a:line
        let newline = newline .a:space. PadItem(region,a:col_widths[iter]) .a:space.a:sep
        let iter += 1
    endfor
    " add the rest of the columns in as white space and swap out the last character
    if len(a:col_widths) > iter
        for col_width in a:col_widths[iter : ]
            " need to add 3 spaces for appropriate in-between spacing
            let newline = newline . PadItem('',col_width) . '   '
        endfor
        let newline = newline[0:len(newline)-2] . a:sep
    endif
    return newline
endfunction

"creates the row-separators for an rst complex table, given input
" col_widths - width of each column
" optional: col_marker [0] - default: '+'; default: '-'
" TODO: decide whether to make this universal or not
function! ComplexRowSep(col_widths,...)
    let col_marker = get(a:000, 0, '+')
    let fill_char = get(a:000, 1, '-')
    return col_marker . join(map(a:col_widths, "repeat(fill_char, v:val + 2 )"), col_marker) . col_marker
endfunction
" creates a simple table format as defined in rst syntax currently
" overwrites existing lines with new table adds padding as well as
" formats to
" Table looks like the following
" +------+----+---+
" | text | te | e |
" +------+----+---+
" found column widths were:
"    4      2   1
" actual column widths are:
"    8      6   5   (colwidth + 4)
" rowseparators defined by: +. repeat('-',colwidth + 4-2) . +
function! MakeComplexTable() range
    let linelist = GetLinesAndSplit(a:firstline,a:lastline, g:LMSpaceExpr)
    " THIS IS ALL UI-INDEPENDENT
    let col_widths = GetMaxLengths(linelist)
    let newlinelist = []
    " go line by line and pad them according to max_length
    for line in linelist
        " TODO: just add rowsep in here instead
        let newlinelist += [PadRegions(line,col_widths,g:LMColSep,' ')]
    endfor
    " to make the top of the table, just join dashes equal to the maxlength of
    " so it's actually colwidth-1+len(spacers) [-1 for the '+' sign]
    " position cursor at beginning of first column of last line
    call cursor(a:lastline, 1)
    let rowsep=ComplexRowSep(col_widths,'+','-')
    " To insert the carriage return key, you need to type IN INSERT MODE:
    " CTRL-V CTRL-M (check out :help ins-special-keys for more.) This took so
    " long to figure out and it was on Stack Overflow the whole time. :P
    let joined = join(map(newlinelist, 'v:val . "" . rowsep'), '')
    " which is why I find it incredibly strange that it works here :P
    let cmd = rowsep."".joined
    " BELOW HERE IS UI-DEPENDENT
    exe "normal! :set tw=0\<Esc> o\<Esc>i".cmd
endfunction

function! AddTableRow()
    " TODO: figure out hwo to give this fxn a count
    " What this line does: grabs a full-line of formatted table. (leaves it
    " there), then inserts on the next line that same line, but substituted
    " s.t. you get the pipe character and finally inserts another line of
    " well-formatted table
    :.s/\(\s*+[+-]\{4,}\)\_$/\1\n\=subsitute('+',substitute('-*',submatch(1),' '),g:LMColSep)\n\1/
endfunction

" For right now, just does the most basic change possible: takes the current
" row, assumes it is spaced with '|' characters, uses that as the baseline and
" then formats the entire table with ONLY that many columns, stretching them
" as necessary.
" function! ReformatTable() range

" Returns a list that is either: (1) a singleton - the item padded or (2) a
" list of strings, where each line is the continuation of the previous line
" (just wrapped to 'length')
function! PadAndWrapItem(str,length,...)
    " string should be padded with length - strlen(str) spacers
    let prepad=get(a:000,0,'')
    let postpad=get(a:000,1,'')
    let spacer=get(a:000,2,' ')
    " finally, insert the spacer
    if len(a:str) > a:length
        " note: you have to use length -1 , else you'll get an infinite loop
        return PadAndWrapItem(a:str[0 : a:length - 1],a:length,prepad,postpad,spacer) + PadAndWrapItem(a:str[a:length : ],a:length,prepad,postpad,spacer)
    else
        return [prepad.spacer.a:str.repeat(spacer,a:length - strlen(a:str)).spacer.postpad]
    endif
endfunction

" returns a list that is either (1) a singleton (the line as a string padded
" or (2) a list of strings, where the additional lines are the continuation of
" the previous lines
" extrapre and extrapost describe how to fill added columns
" If you want to produce a table where empty columns get separators just pass extrapost with 'a:sep'
function! PadAndWrapLine(line,col_widths,sep,space,...)
    " slightly ugly to do it this way, but I don't have to rely on tlib zip,
    " which is a bonus
    let iter = 0
    let numrows = 0
    let padded = []
    let extrapre = get(a:000,0,'')
    let extrapost = get(a:000,1,' ') " default should be one space (b/c in place of separator)
    if (len(a:space) > 1) || (len(a:sep) > 1) || (len(a:space) == 0) || (len(a:space) == 0)
        echoerr "Table spacer and separator must be at least a single character"
    endif

    " goal: make a list of lists with a known number of rows 1 -> means not
    " wrapped, 2 -> means  1 additional row, etc.
    for region in a:line
        " get the padded items and add separators to them
        let newpad = PadAndWrapItem(region,a:col_widths[iter], '',a:sep,a:space)
        " update numrows if necessary
        let numrows = len(newpad) > numrows ? len(newpad) : numrows
        " added the padded item to teh growing list
        let padded += [newpad]
        let iter += 1
    endfor
    "get the first items of every element, to make into a full row
    let firstrow = map(copy(padded), 'v:val[0]')
    if len(a:col_widths) > iter
        for col_width in a:col_widths[iter : ]
            " for the rest of these items, don't want the separator, so we'll put
            " space instad (so that there is basically nothing in the table)
            let firstrow += PadAndWrapItem('',col_width,extrapre,extrapost,a:space)
        endfor
        " need this to add a separator to the very end if additional columns were added
        let firstrow[-1] = firstrow[-1][0:len(firstrow[-1])-2] . a:sep
    endif
    " make a blank row by subbing out everything but separator from the first
    " row
    let blankrow = map(copy(firstrow), "substitute(v:val, '[^\\".a:sep."]', a:space, 'g')")
    let rows = [join([a:sep,join(firstrow,'')],'')]
    for row in range(0,numrows - 1)[1 : ]
        "initialize with blank row
        let thisrow = copy(blankrow)
        " see if there is actually a wrap-row here
        for iter in range(0,len(blankrow) - 1)
            let thiselement = get(get(padded, iter,[]), row, 0)
            if type(thiselement) != type(0)
               let thisrow[iter] = thiselement
            endif
        endfor
        " after all that, store it with the list of rows
        let rows += [join([a:sep,join(thisrow, '')],'')]
    endfor

    return rows
    " add the rest of the columns in as white space for the moment
endfunction

function! SpaceColumns(col_widths, max_width)
    total_real_width = 
endfunction

" CreateComplexTable
" no arguments - uses tw to make table
"first non-named arg: tablewidth
" additional args: explicit widths for first len(add'largs) cols
" TableType sets the manner in which the ComplexTable searches
" example options: '\s\{2,}' ('spaces'), '\s|\s' ('pipes')
let g:LMSpaceExpr = '\s\{2,}'
let g:LMPipeExpr = '\s|\s'
" list of abbreviations for table types
let g:LMTableSearches = {'spaces':g:LMSpaceExpr, 'space':g:LMSpaceExpr, 'pipes':g:LMPipeExpr, 'pipe':g:LMPipeExpr, '|':g:LMPipeExpr, ' ':g:LMSpaceExpr}

" TODO: have this restore cursor position and environment
function! CreateComplexTable(TableType,...) range
    " either given a matching string to a search or (hopefully) a regular
    " expression
    let b:LMTableSeparator = get(g:LMTableSearches, a:TableType, a:TableType)
    " initial arg is tablewidth, others are the defined cols; if TableWidth is 0, no spacing will occur
    let b:LMTableWidth = get(a:000, 0, &tw)
    let b:LMDefinedCols = a:000[1 : ] " returns [] or sublist
    if a:firstline - a:lastline == 0
        " if we weren't given a real range, get it using the paragraph textobject
        exe "normal! {j\<Esc>:let b:LMStartLine = line('.')}k:let b:LMEndLine = line('.')\<Esc>"
    else
        let b:LMStartLine = a:firstline
        let b:LMEndLine = a:lastline
    endif
    echo "Formatting ".b:LMStartLine.",".b:LMEndLine." by ".b:LMTableSeparator." using width of ".b:LMTableWidth." with cols of length ".string(b:LMDefinedCols)
    " grab lines from text and get col_widths, etc
    let lines = GetLinesAndSplit(b:LMStartLine,b:LMEndLine,b:LMTableSeparator)
    " BELOW HERE IS THE INTERNAL FUNCTION
    let col_widths = GetMaxLengths(lines)
    echo col_widths
    " Put defined columns in the col_widths for use in padding/wrapping (note
    " that if DefinedCols is *longer* than col_widths, additional blank
    " columns will be included in table
    if len(b:LMDefinedCols) > len(col_widths)
        echo "if clause"
        let col_widths = copy(b:LMDefinedCols)
    else
        echo "else clause"
        let iter = 0
        for defcol in b:LMDefinedCols
            let col_widths[iter] = defcol
            let iter += 1
        endfor
        " Now space out the rest of the columns s.t. they fit within given
        " parameters (if width == 0, no spacing will occur, just like tw, etc)
        if b:LMTableWidth > 0
            for spaced_column in SpaceColumns(col_widths[iter : ], b:LMTableWidth - sum(b:LMDefinedCols))
                let col_widths[iter] = spaced_column
                let iter += 1
            endfor
            unlet iter
        endif
    endif
    "TODO: make this easily changed
    let rowsep = ComplexRowSep(copy(col_widths),'+','-')
    " use PadAndWrapLine on every element to produce a grouped list of rows,
    " each group is a "wrapped_row" (in other words, spills over on to
    " multiple lines, so don't put row separators between them). Thus, we map
    " adding a row sep to each and finally joining them with 
    echo col_widths
    echo map(copy(lines), 'len(v:val)')
    let wrapped_rows = map(deepcopy(lines), "PadAndWrapLine(v:val,col_widths,'|',' ')")
    let joined_rows = map(wrapped_rows, "join(add(v:val,rowsep),'')")
    let cmd = rowsep . '' . join(joined_rows,'')
    echo cmd
    call cursor(a:lastline, 1)
    exe "normal! :set tw=0\<Esc> o\<Esc>i".cmd
endfunction

vmap <leader>w :CreateSpaceTable<CR>
map <leader>w :CreateSpaceTable<CR>
command! -range -nargs=* CreateSpaceTable <line1>,<line2>call CreateComplexTable('spaces',<f-args>)
command! -range -nargs=* CreatePipeTable <line1>,<line2>call CreateComplexTable('|',<f-args>)
