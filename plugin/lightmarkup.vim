" TODO: (longterm) write separate scripts for different filetypes
" (particularly ft=help)

" wrapper class
let s:LM = {}

" set default global variables

" default character list
if !exists('g:LMCharacterList')
    let g:LMCharacterList=['=','-','"','^','*']
endif

"set length to character list length
let CharacterListLength=len(g:LMCharacterList)

" g:LMAutoReplace *LM-auto-replace*
"   {1} - replaces 
if !exists('g:LMAutoReplace')
    let g:LMAutoReplace=1
endif

" default character to insert if no function given
" uses LMCharacterList[1] if none given.
if !exists('g:LMDefaultCharacter')
    let g:LMDefaultCharacter=1
endif
"user-accessible functions

" *LMUnderline*
" makes a single underline underneath words
" :LMUnderline {char}   "where {char} is either a header level or a
"                       character to underline
" e.g.
" :LMUnderline =
"
" My Title
" ========
" $
function! s:LMUnderline(...)
    return copy(s:LM.Underline)
endfunction

"makes a double line with same syntax as |LMUnderline|
" sample call:
" :LMDoubleLine =
"
" ========
" My Title
" ========
" $

function! s:LMDoubleLine(...)
    
endfunction

" makes a table header:
" treats spaces as follows:
"  single space: considers one title
"  multiple spaces: considers it a column divider and puts spaces in the
"   table header
" ====  ====  ========================  =====
" Col1  Col2  Column Title With Spaces  Col4
" ====  ====  ========================  =====
" $
function! s:LMTable(...)
endfunction

" creates a horizontal line with length = textwidth
"   (if textwidth = 0, uses 80)
" e.g. LMHLine =
" ==========================================================================
" TODO: Write LMHLine :P
function! s:LMHLine(...)
    " convert character with GetFillCharacter
    " check textwidth
    " create a horizontal line to textwidth
    "
endfunction

" for given input, return the corresponding fill character
" usage: call a line-generating function, send to GetFillCharacter then
" convert to character as appropriate (# -> index on character list, otherwise
" just the inputted character)
function! LM.GetFillCharacter(...)
    " unpack arguments given from other functions
    let [args] = a:000
    let numargs = len(args)
    if numargs == 0:
        let character = g:LMDefaultCharacter
    elseif numargs == 1:
        let character = args[0]
    else:
        echoerr "LightMarkup - Error: Too many arguments given. Only one argument is accepted."
    if 0 < a:char <= CharacterListLength
        " if char is a number within the current list indices, return the
        " corresponding index
        return g:LMCharacterList[a:char - 1]
    else
        " otherwise return the character
        return a:char
    endif
endfunction

function! s:Boxline(...)
    :let charorder=['','=','-','"'] "make the indexes line up by starting with an empty string
    :let indices=['1','2','3']
    if index(indices,a:char) >=0
        :let character=charorder[a:char]
    else
        :let character=a:char
    endif
    :exe "normal mt"
    :let line=repeat(character, col('$')-1)
    :exe "normal O".line
    :exe "normal 't"
    :exe "normal o".line."\<Esc>o\<Esc>o"
endfunction

function! s:Underline(...)
    :let charorder=['','=','-','"','^','*']
    :let indices=['1','2','3','4','5']
    if index(indices,a:char) >=0
        :let character=charorder[a:char]
    else
        :let character=a:char
    endif
    :let line=repeat(character, col('$')-1)
    :exe "normal o".line."\<Esc>o\<Esc>o"
endfunction
