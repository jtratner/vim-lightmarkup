let g:LMMinQuote=3
command! ConvertLinkRefs :exec ':%s/`[^`]\{'.g:LMMinQuote.'},}`_/[\1][\1]/gc'
command! ConvertLinkDefs :%s/^\.\.\s_[^:]*\s{0,}:\s\(.*\)$/[\1]: \2
