Getting line numbers:
current line: currline = line('.')
getting indent level: indent({lnum}) (check >-1)

autoformat options for indents and lists:
'n' |  option + set a format pattern: default is: (# followed by '.' ':' ')'
    - so set a different format pattern for lists (a{char}, b{char}, c{char},
    ^\s*\*\{1,}\s, #{char}, A{char} B{char}, number{char},) (formatted with
    formatlistpat) REQUIRES autoindent



I also need to define a function that stores all the formatting information
and resets it when changed (so literally set a script variable that grabs all
the formatting I use; call it if a fxn ends up changing any of those
variables, do shit, then have wrapper functions that call reset-options)

current changed variable types:
    tw, fo, formatlistpat, autoindent, '


handling tables: when you find a space region, just insert an esoteric string,
like maybe #@!, and then just let tabularize auto-handle the formatting

so select paragraph area, then do the following replacement:
:<>s/\(\s\{2,}\)/ #$%^ /g
(get the per line substitutions, store the greatest number, then make a string
of:
'= #$%^ ' * # line substitutions (to make the table header)
then Tabularize it (or steal the tabularize function to handle this :P)
then just create a line of '=' to desired spacing.

NOTE: perhaps easiest would be to build a line-by-line list of lengths, get
the longest length of each line, then just pad the lines (or, easier, grab all
the lines, split them on \{2,}

NOTE: to return the pattern back to the text, use \=\& (check out |sub-replace-special| for more)

=   =   =   =  
Here is my table   It uses two spaces to delimit   Whee
adfaweoiae aeoefa   aw;eoifawe;fo   awoeifjaw;e   aweofiajwe;fi awe fao; More
spacing   weheee   a we;foiawe;f fa   fa wefoaief   aoiwe ofiea

=                 #$%^ =                             #$%^ =                #$%^ =                      #$%^
Here is my table  #$%^ It uses two spaces to delimit #$%^ Whee
adfaweoiae aeoefa #$%^ aw;eoifawe;fo                 #$%^ awoeifjaw;e      #$%^ aweofiajwe;fi awe fao;
More spacing      #$%^ weheee                        #$%^ a we;foiawe;f fa #$%^ fa wefoaief            #$%^ aoiwe ofiea

function! ReturnListOfMatches(...)
    let firstline = a:firstline
    echo a:firstline
    echo a:lastline
    echo a:lastline-a:firstline
    let linelist = []
    for i in range(firstline, lastline)
        linelist.append(getline(i))
    endfor
    map(linelist, 'split('.v:val.', \s\{2,-})')
    echo map(copy(linelist), 'len('.v:val.')')
endfunction
