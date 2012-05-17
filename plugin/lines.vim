" Returns a list of numbers corresponding to lines matching from given lnum
" output: normal mode: [] - false, [1] - underline, [1,-1] - under + overline
" markdown mode: [] - false, [0] - hash marks, where # is #marks at start,
" [1] - underline
" Rules
" 1. line must be > 3 characters, match charlist and be only 1 type of character (no spaces in between)
" 2. if line above, lines must match above and below
"
" Use cases:
" a - check if underlined ( give LMAutoReplace just lnum and
" ^\s[g:LMCharacterList] (but also all the same characters
" b - check if under/overlined (give LMAutoReplace lnum for . - 1 and . + 1)
" c - Markdown: check if a header (give lnum and
"
" returns '1' if remvoed, '0' otherwise
let g:DefaultSearchStr = '\{3,}\s*\_$'
let s:SearchEscapeList ='\^'
"TODO: figure out how to deal with '"' character in searching/escaping/etc
let g:LMCharacterList = ['=','-','^']
function! SetSearchStr()
    if !exists('b:LMMode')
        let b:SearchStr = g:DefaultSearchStr
    elseif b:LMMode == 'markdown'
        let b:SearchStr = ['^#*\s\{1,}\S','\{3,}\s*\_$']
    else
        " TODO: create other modes :P
        let b:SearchStr = g:DefaultSearchStr
    endif
endfunction

function! LMCheckForHeaders(lnum, ...)
    if !exists('b:SearchStr')
        "TODO: use markdown mode
        let b:SearchStr = g:DefaultSearchStr
    endif
    " for normal/rst mode
    " escape charlist for use in regex
    let charlist = map(copy(get(a:000, 0, g:LMCharacterList)), 'escape(v:val, s:SearchEscapeList)')
    let searchstr = get(a:000, 1, b:SearchStr)
    " join together s.t. will do a branched search
    let header_search = join(map(copy(charlist), 'v:val.searchstr'), '\|')
    echo header_search
    let nextline = getline(a:lnum+1)
    let prevline = getline(a:lnum-1)
    " initialize output
    let output = []
    " only want to get matches at *start* of string
    if match(nextline, header_search) == 0
        let output = add(output, 1)
        if match(prevline, header_search) == 0 && nextline[0] == prevline[0]
            let output = add(output,-1)
        endif
    endif
    return output
endfunction



"Uncomment the following lines and you should find that LMCheckForHeaders
"should return [] for anything but the next few lines, should return [1] for
"next line, [1,-1] three lines below, [] on two lines below (on the hline) and
"again [1] on the line before the HLine

"================================

"================================


"================================

