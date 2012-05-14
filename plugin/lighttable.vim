" TODO: set desert as theme for vim files
" take line
" do autoreplace beforehand if desired (meaning remove above and below)
" search the line as follows:
" 
" anycharacters+singlespaces, find location of multiple spaces on line

py << EOF

import re
import vim

def make_table(current_line)
    """ 
    Creates a reStructuredText table.
    =================================

    INPUT: a single line. If the line has text in it, creates a table
    where two spaces are assumed to be column separators"


EOF


