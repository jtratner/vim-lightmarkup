" These two functions should be called on entry and exit to LightMarkup
" In other words, all commands should be of form:
" command! LMsomething :call ClearEnvironment()<CR>:<line1>,<line2>call LMsomething<CR>:call RestoreEnvironment
function! ClearEnvironment()
    if !exists("b:saved_environment")
        " TODO: save cursor position too
        let b:saved_environment = ":set tw=".&tw.":set fo=".&fo.":set fdm=".&fdm
    endif
    " Now set them all to 0/nothing
    exe ":set tw=0:set fo=:set fdm="
endfunction
function! RestoreEnvironment()
    if exists("s:saved_environment")
        exe s:saved_environment
        echo s:saved_environment
    endif
    " erase the variable so that if ClearEnvironment called again will restore
    unlet b:saved_environment
endfunction

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
    let col_width = []
    " go line by line
    for line in nested_lengths
        " set i to zero so we can sync our place with col_width
        for iter in range(0,len(line)-1)
            " if the current region is longer than the current value for the region, store it
            " NOTE: using get() here to avoid list index errors (returns 0 if doesn't exist)
            " if col_width doesn't have the current item, then store the
            " rest and stop going through line
            if (get(col_width, iter, "NONE") == "NONE")
                call extend(col_width, line[iter :])
                break
            endif
            let col_width[iter] = col_width[iter] < line[iter] ? line[iter] : col_width[iter]
        endfor
    endfor
    return col_width
endfunction

"separator to use for initial table detection
let g:LMDefaultSeparator='\s\{2,}'

 
function! GetLinesAndSplit(first,last,...)
    echo a:first
    echo a:last
    let separator=get(a:000,0,g:LMDefaultSeparator)
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
    " add the rest of the columns in as white space
    for col_width in a:col_widths[iter : ]
        " need to add 3 spaces for appropriate in-between spacing
        let newline = newline . PadItem('',col_width) . '   '
    endfor
    return newline
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
    let linelist = GetLinesAndSplit(a:firstline,a:lastline)
    let col_width = GetMaxLengths(linelist)
    let newlinelist = []
    " go line by line and pad them according to max_length
    for line in linelist
        " TODO: just add rowsep in here instead
        let newlinelist += [PadRegions(line,col_width,'|',' ')]
    endfor
    " to make the top of the table, just join dashes equal to the maxlength of
    " so it's actually colwidth-1+len(spacers) [-1 for the '+' sign]
    " position cursor at beginning of first column of last line
    call cursor(a:lastline, 1)
    let rowsep = map(col_width, "repeat('-', v:val + 2 )")
    let newrowsep = '+' . join(rowsep, '+') . '+'
    " To insert the carriage return key, you need to type IN INSERT MODE:
    " CTRL-V CTRL-M (check out :help ins-special-keys for more.) This took so
    " long to figure out and it was on Stack Overflow the whole time. :P
    let joined = join(map(newlinelist, 'v:val . "" . newrowsep'), '')
    " which is why I find it incredibly strange that it works here :P
    let cmd = newrowsep."".joined
    exe "normal! :set tw=0\<Esc> o\<Esc>i".cmd
endfunction

function! AddTableRow()
    " TODO: figure out hwo to give this fxn a count
    " What this line does: grabs a full-line of formatted table. (leaves it
    " there), then inserts on the next line that same line, but substituted
    " s.t. you get the pipe character and finally inserts another line of
    " well-formatted table
    :.s/\(\s*+[+-]\{4,}\)\_$/\1\n\=subsitute('+',substitute('-*',submatch(1),' '),'|')\n\1/
endfunction

" For right now, just does the most basic change possible: takes the current
" row, assumes it is spaced with '|' characters, uses that as the baseline and
" then formats the entire table with ONLY that many columns, stretching them
" as necessary. 
" function! ReformatTable() range

" 
function! CreateComplexTable(...)
endfunction
