" Should produce ['123','456','789'] (and expr should produce 1)

function! JTAssert(name, expr, assertion)
    exe "let expr = ".a:expr
    exe "let assertion = ".a:assertion
    if expr == assertion
        return 1
    else
"        echo a:name." Failed! \nExpected: ".string(assertion)." But found: ".string(expr)."\nInput: ".a:expr
        echo a:name." Failed! \nExpected: ".string(assertion)." But found: ".string(expr)
        return 0
    endif
endfunction

function! JTRunTests(list_of_tests)
    let test_outcome = map(a:list_of_tests, 'JTAssert(v:val[0],v:val[1],v:val[2])')
    if count(test_outcome,0) == 0
        echo "All ".count(test_outcome,1)." tests passed!"
    else
        echo count(test_outcome,1)." tests passed! ".count(test_outcome,0)." tests failed!"
    endif
endfunction

let TestList = [
    \ ['PadAndWrapItem-1 :' , "PadAndWrapItem('123456789',3,'','',' ')" , "[' 123 ',' 456 ',' 789 ']"],
    \ ['PadAndWrapItem-multi-padded :' , "PadAndWrapItem('123456789',3,'','|',' ')" , "[' 123 |',' 456 |',' 789 |']"],
    \ [ 'PadAndWrapItem-2 :' , "PadAndWrapItem('a',4,'|','|','!')" , "['|!a!!!!|']"],
    \ [ 'PadAndWrapItem-3 :' , "PadAndWrapItem('<CR>',6,'','',' ' )" , "[' <CR>   ']"],
    \ [ 'PadAndWrapItem-empty', "PadAndWrapItem('',3,'a','b','.')", "['a.....b']"],
    \ [ 'PadAndWrapItem-multi-padded', "PadAndWrapItem('123456789abcdefg',2,'@','!','.')", "
                                                                            \['@.12.!','@.34.!','@.56.!','@.78.!','@.9a.!','@.bc.!','@.de.!','@.fg.!']"],
    \ [ 'PadAndWrapLine-long' , "PadAndWrapLine(['a','b','123456789'],[2,2,3],'|',' ')" ,
                                                                \"['| a  | b  | 123 |' ,
                                                                \'|    |    | 456 |' , '|    |    | 789 |']"],
    \ [ 'PadAndWrapLine-short', "PadAndWrapLine([1],[1],'|',' ')","['| 1 |']"],
    \ [ 'PadAndWrapLine-normal', "PadAndWrapLine([12,1,1234],[3,2,5],'|',' ')", "['| 12  | 1  | 1234  |']"],
    \ [ 'PadAndWrapLine-multiline', "PadAndWrapLine([1234,4321,'abcd'],[1,1,1],'|',' ')", "['| 1 | 4 | a |', '| 2 | 3 | b |', '| 3 | 2 | c |', '| 4 | 1 | d |']"],
    \ [ 'PadAndWrapLine-extraspace', "PadAndWrapLine([12],[2,3,2],'|',' ')", "['| 12 |          |']"],
    \ [ 'PadAndWrapLine-multilineextraspace', "PadAndWrapLine([12,4567],[2,1,3,2],'|',' ')", "['| 12 | 4 |          |', '|    | 5 |          |', '|    | 6 |          |', '|    | 7 |          |']"],
    \ [ 'PadRegionsEmpty', "PadAndWrapLine([],[4,1,3],'!','.','','!')", "['!......!...!.....!']"],
    \ [ 'PadRegionsSingle', "PadAndWrapLine([1],[5],'!','.')", "['!.1.....!']"],
    \ [ 'ComplexRowSep-empty', "ComplexRowSep([],'','')", "''"],
    \ [ 'ComplexRowSep-simple', "ComplexRowSep([5],'+','-')", "'+-------+'"],
    \ [ 'ComplexRowSep-multi', "ComplexRowSep([1,2,3,4],'+','-')", "'+---+----+-----+------+'"],
    \ [ 'ComplexRowSep-defaults', "ComplexRowSep([4,5])", "'+------+-------+'"],
    \ [ 'SumList-empty', "SumList([])", "0"],
    \ [ 'SumList-single', "SumList([1])", "1"],
    \ [ 'SumList-single2', "SumList([3])", "3"],
    \ [ 'SumList-nolist', "SumList(3)", "3"],
    \ [ 'SumList-multi', "SumList([1,2,3,-4])", "2"],
    \]

:call JTRunTests(TestList)
