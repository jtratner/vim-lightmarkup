

" Functions defined here:
" Under/overlining funcs:
" =======================
"
" LM.GetFillChar(...)
" ---------------------
" - used for all the following uncs
" - converts input into character to be filled in
" LMUnderline(...)
" ------------------
"  - creates an underline matched precisely to the width of the entry
"  - arguments are as used for
" LMHLine
" ---------
"  - creates a horizontal line = &tw if &tw > 0 else 80
" LMDoubleLine
"  - creates an over and underline on object
"
" Global variables
" ==================
" g:LMCharacterList            "Ordered list of characters for decorating
" g:LMAutoReplace              "Deactivate autoreplace with 0, default 1
" g:ConfirmSearchAndReplace  "0 for no prompting, 1 to prompt for confirmation
"                            "of replacements
" g:LMHLineDefaultWidth      "width of hline if no textwdith set. Default is
"                            "80 characters

" TODO: Add support for detecting the presence of 'comment string' (which
" means, specifically - ^#\s*, ^\s*#\s*, where everything there should be
" ignored.
" TODO: merge all the vimrc files between branches.
" TODO: (longterm) write separate scripts for different filetypes
" (particularly ft=help)
" TODO: make autoreplace check for existence of lines above and below
" consisting only of AT LEAST ONE character in LMCharacterList (and only one
" type of character) and whitespace. -- easiest to just do something like
" this:
"   Check above and below for:
"       - does line consist of only LMCharacterList + whitespace?
"       -   Y --> check that only one type of character in line
"       -         Y --> remove that line (if bottom): if above and below
"                       match, possibly remove above too, if they don't, only
"                       remove below. (start with just removing bottom line)
"       -         N --> keep line (and possibly add newlines)
"       -   N --> keep line(and possibly add newlines)
"   Check for whitespace below (AFTER finished with autoreplace and inserting
"   formatting):
"       - is line below [^$]?
"           Y --> Don't add a newline
"           N --> add a newline
"   (HLine does not autoreplace or check for newlines)
"   DoubleLine, Underline - do both checks
"   Table - does first check, does not check for newlines
" TODO: remove formatting command (uses 1+2 above, maybe not check 2)
" TODO: write func to handle default choice, newline choice, etc
" TODO: auto list writing (command within list goes to sublevel and aligns
" with above; newline at end of list creates the next list item)
" TODO: help files
" TODO: help tags
" TODO: autoload file loading plugins and setting external functions
" TODO: write function that lines up all the lines below it (if a list form)
" until it gets to a blank line (continues lining up each list item. Logic:
"       START LINE:
"           Is it in format of list? either: ^\s{0,}\*\s\{1,3}(\S\{1,})\|^\-\s\{1,3}(\S\{1,})\|\+\s\{1,3}(\S\{1,})
"                                        OR
"                                        ^\s\{0,}#\.\s\{1,3}(\S\{1,})\|^\s\{0,}\d\.\s{1,3}(\S\{1,})
"
"   conditions: 1. check above and below
"               2. if above and below, decide what to do next
"               3. if above and below match characters

" wrapper class
let s:LM = {}

" set default global variables

" default character list
if !exists('g:LMCharacterList')
    let g:LMCharacterList=['=','-','"','^','*']
endif

g:PythonDocumentationOverline=['#','*']
g:PythonDocumentationUnderline=['=','-','^','"']

"set length to character list length
let s:CharacterListLength=len(g:LMCharacterList)

" General Strategy
" 1. save cursor position
" 2. get current line number
" 3. check surrounding line numbers as appropriate:
"       a - Underline+Title (check a:line + 1 and a:line - 1)
"           1. check possible underline first, if it exists, only remove above
"           character if it is (A) same length as below and (B) same character
"       b - Table (first gets the whole paragraph and tries to check every
"       line, checks each line for spaces>2-3 and stores the length of each
"       delimited space found in order. replaces stored # if finds longer space grouping
"       matches each set of spaces and replaces with the longest # spaces
"       required

" for given input, return the corresponding fill character
" usage: call a line-generating function, send to GetFillCharacter then
" convert to character as appropriate (# -> index on character list, otherwise
" just the inputted character)

function! LMGetFillCharacter(...)
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
function! LMUnderline(...)

endfunction

"makes a double line with same syntax as |LMUnderline|
" sample call:
" :LMDoubleLine =
"
" ========
" My Title
" ========
" $

"function! LMDoubleLine(...)

"endfunction

" makes a table header:
" treats spaces as follows:
"  single space: considers one title
"  multiple spaces: considers it a column divider and puts spaces in the
"   table header
" ====  ====  ========================  =====
" Col1  Col2  Column Title With Spaces  Col4
" ====  ====  ========================  =====
" $
function! LMTable(...)
endfunction

command! -nargs=* LMHLine :call s:LMHLine(<f-args>)


" creates a horizontal line with length = textwidth
"   (if textwidth = 0, uses 80)
" e.g. LMHLine =
" ==========================================================================
" TODO: Write LMHLine :P
function! LMHLine(...)
    " convert character with GetFillCharacter
    let char = GetFillCharacter(a:000)
    " check textwidth
    if &tw <= 0
        " if no text-width, use the default
        let width = g:LMHLineDefaultWidth
    else
        let width = &tw
    endif
    " set the line according to input
    let line = repeat(char,width)
    " insert underneat current line
    exe "normal! 0o<ESC>p"
endfunction


function! Boxline(...)
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

:command! -nargs=* Tes :call RunTestFunction(<f-args>)

function! LMUnderline(...)
    " call GetFillCharacter
    char = GetFillCharacter(a:000)
endfunction

function! Underline(...)
    let charorder=['','=','-','"','^','*']
    let indices=['1','2','3','4','5']
    if index(indices,a:char) >=0
        let character=charorder[a:char]
    else
        let character=a:char
    endif
    let line=repeat(character, col('$')-1)
    exe "normal o".line."\<Esc>o\<Esc>o"
endfunction

" AutoReplace
" takes in a line number and checks if that line is a markup line
" (specifically it returns a set of values
function! AutoReplace(linenum,fun)
    " Check if linenum is a line that's entirely a single character in the set
    " of format characters and any characters provided by user. If in Markdown
    " mode, also checks if the current line starts with '#'
    
endfunction

function! RunTestFunction(...)
    " make sure that fill characters matches numbers and characters when added
    " from list
    for char in g:LMCharacterList
        echo char
endfunction
