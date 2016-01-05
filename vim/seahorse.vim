" Vim color file
" Based on: http://colorsublime.com/theme/Seahorse

set background=dark

hi clear
if exists("syntax_on")
    syntax reset
endif
let g:colors_name = "seahorse"

hi Normal   ctermfg=188 ctermbg=234 "#25262B
hi Comment  ctermfg=59              "#65666B

hi ColorColumn ctermbg=59

" from import
hi pythonImport    ctermfg=212
hi pythonInclude   ctermfg=212

hi pythonString    ctermfg=228 "ffff87
hi pythonBoolean   ctermfg=177 "True False
hi pythonNumber    ctermfg=177
hi pythonFloat     ctermfg=177

hi pythonFunction  ctermfg=156 "222

hi pythonStatement ctermfg=156 "def class with pass break continue return
hi pythonRepeat ctermfg=156 "for while
hi pythonConditional ctermfg=156 "if elif else
hi pythonOperator ctermfg=212 "and in is not or
hi pythonBuiltinFunc ctermfg=117 "print file range input
hi pythonException ctermfg=212 "try except finally

hi pythonDecorator ctermfg=156 "@
hi pythonDottedName ctermfg=156 "@...

hi pythonSpaceError ctermbg=255
