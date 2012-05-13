

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
    return map(a:lst, 'len(v:val)')
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
    let max_lengths = []
    " go line by line
    for line in nested_lengths
        " set i to zero so we can sync our place with max_lengths
        let i = 0
        for region in line
            " if the current region is longer than the current value for the region, store it
            " NOTE: using get() here to avoid list index errors (returns 0 if doesn't exist)
            let max_lengths[i] = (region > get(max_lengths, i) ? region : get(max_lengths, i))
            let i += 1
        endfor
    endfor
    return max_lengths
endfunction

"separator to use for initial table detection
let g:LMDefaultSeparator='\s\{2,}'

 
function! GetLinesAndSplit(first,last,...)
    echo a:first
    echo a:last
    echo a:last-a:first
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
    echo linelist
    return linelist
endfunction

" creates a simple table format as defined in rst syntax currently
" overwrites existing lines with new table adds padding as well as
" formats to 
function! MakeSimpleTable() range
    let linelist = GetLinesAndSplit(a:firstline,a:lastline)
    let max_lengths = GetMaxLengths(linelist)
    "TODO: do this with replace instead
    for line in linelist 
        let line=map(tlib#list#Zip(line,max_lengths),PadItem(v:val[0],v:val[1],'|','|')) 
        echo line
        "exe "normal! o\<Esc>R"
    endfor
endfunction

