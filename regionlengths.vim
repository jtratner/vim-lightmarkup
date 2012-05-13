
function! Nestedlength(lst)
    return map(a:lst, 'len(v:val)')
endfunction

function! FindRegionLengths() range
    echo a:firstline
    echo a:lastline
    echo a:lastline-a:firstline
    let linelist = []
    for i in range(a:firstline, a:lastline)
        let linelist += [split(getline(i), '\s\{2,}')]
    endfor
    echo linelist
    " First, get all the internal lengths so we can work with them quickly
    let lineregions = map(copy(linelist), 'Nestedlength(v:val)')
    " Then work with region lengths to get both the number of items and the
    " max length in each region

    " initialize to first entry of lineregions
    let numregions = len(lineregions[0])
    let regionlengths = lineregions[0]
    for theline in lineregions[1:]
        let thelinelength = len(theline)
        " basically, lets me avoid checking the length of the list endless
        " times
        if thelinelength <= numregions
            " for each line, compare the numbers to num regions
            for i in range(0,numregions-1)
                " store line's region length if longer than the line
                if theline[i] > regionlengths[i]
                    let regionlengths[i] = theline[i]
                endif
            endfor
        " add any additional regions to the list
        else
            for j in range(numregions, len(theline)-1)
                let regionlengths[j] = theline[j]
                let numregions += 1
            endfor
        endif
    endfor
    echo regionlengths
endfunction

command! -range MatchList call ReturnListOfMatches()
