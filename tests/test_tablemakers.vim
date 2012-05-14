.. vim:fdm=marker:tw=80:ft=rst:foldlevel=1:
.. REGIONLENGTHTESTS {{{1

.. TableTest1 {{{2

!  -  /  $
Here is my table  It uses two spaces to delimit  Whee
adfaweoiae aeoefa  aw;eoifawe;fo                            awoeifjaw;e  aweofiajwe;fi awe fao; More
spacing  weheee  a we;foiawe;f fa  fa wefoaief  aoiwe ofiea
This line should                                                            NOT make it go very longest
1  2  3  4  5  6  7  8  9  10
1  2  3  4  5  6  7  8  ______________________________
+-------------------+-------------------------------+------------------+-----------------------------+-------------+---+---+---+--------------------------------+----+
| -                 | !                             | /                | $                           |                                                                
+-------------------+-------------------------------+------------------+-----------------------------+-------------+---+---+---+--------------------------------+----+
| Here is my table  | It uses two spaces to delimit | Whee             |                                                                                              
+-------------------+-------------------------------+------------------+-----------------------------+-------------+---+---+---+--------------------------------+----+
| adfaweoiae aeoefa | aw;eoifawe;fo                 | awoeifjaw;e      | aweofiajwe;fi awe fao; More |                                                                
+-------------------+-------------------------------+------------------+-----------------------------+-------------+---+---+---+--------------------------------+----+
| spacing           | weheee                        | a we;foiawe;f fa | fa wefoaief                 | aoiwe ofiea |                                                  
+-------------------+-------------------------------+------------------+-----------------------------+-------------+---+---+---+--------------------------------+----+
| This line should  | NOT make it go very longest   |                                                                                                                 
+-------------------+-------------------------------+------------------+-----------------------------+-------------+---+---+---+--------------------------------+----+
| 1                 | 2                             | 3                | 4                           | 5           | 6 | 7 | 8 | 9                              | 10 |
+-------------------+-------------------------------+------------------+-----------------------------+-------------+---+---+---+--------------------------------+----+
| 1                 | 2                             | 3                | 4                           | 5           | 6 | 7 | 8 | ______________________________ |     
+-------------------+-------------------------------+------------------+-----------------------------+-------------+---+---+---+--------------------------------+----+

.. TableTest1 Output {{{2

This should be the region lengths for the given table above:
[17,29,16,27,11,1,1,1,30,2]

.. TableTest2 (Easier) {{{2

Col1  Col2  Col3
some more text here  definition  more text
.. START PAD TESTS {{{1

pad command

'apple',10,"'","'"

produces
'apple     '

pad command

'fraker g',15,'| ','|'

prodcues
| fraker g      |

pad command
'',20,'| ','|'

produces
|                     |

pad command
'',0

produces

(nothing)


.. STARTABLETESTS {{{1

.. Input for create table: {{{2

here is my table     it uses two spaces to delimit    whee
adfaweoiae aeoefa    aw;eoifawe;fo                    awoeifjaw;e         aweofiajwe;fi awe fao; more
spacing              weheee                           a we;foiawe;f fa    fa wefoaief                    aoiwe ofiea
this line should     not make it go very longest
1                    2                                3                   4                              5
1                    2                                3                   4                              5

.. simple table : {{{2

here is my table     it uses two spaces to delimit    whee
adfaweoiae aeoefa    aw;eoifawe;fo                    awoeifjaw;e         aweofiajwe;fi awe fao; more
spacing              weheee                           a we;foiawe;f fa    fa wefoaief                    aoiwe ofiea
this line should     not make it go very longest
1                    2                                3                   4                              5
1                    2                                3                   4                              5


.. Complex table: {{{2

Here is my table     It uses two spaces to delimit    Whee
adfaweoiae aeoefa    aw;eoifawe;fo                    awoeifjaw;e         aweofiajwe;fi awe fao; More
spacing              weheee                           a we;foiawe;f fa    fa wefoaief                    aoiwe ofiea
This line should     NOT make it go very longest
1                    2                                3                   4                              5
1                    2                                3                   4                              5

.. Fixup table test: {{{2

