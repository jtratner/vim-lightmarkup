:function! F1(...)
:    echo a:0
:    echo a:000
: call    F2(a:000)
:endfunction

:function! F2(...)
:    let [args] = a:000 " unpack list (given already packed by previous function)
:    let numargs = len(args)
:    echo numargs
:    echo args
:endfunction
