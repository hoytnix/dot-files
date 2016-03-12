" Vim color file
" Based on: http://colorsublime.com/theme/Seahorse

set background=dark

hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "seahorse"

" Sets the highlighting for the given group
fun s:HL(group, fg, bg, attr)
  if a:fg != ""
    " echo "['" . a:fg . "', " . s:rgb(a:fg) . "]"
    exec "hi " . a:group . " ctermfg=" . a:fg
  endif
  if a:bg != ""
    " echo  "['" . a:bg . "', " . s:rgb(a:bg) . "]"
    exec "hi " . a:group . " ctermbg=" . a:bg
  endif
  if a:attr != ""
    exec "hi " . a:group . " cterm=" . a:attr
  endif
endfun

" Color codes

let s:bg     = '235' "#25262B
let s:grey   = '59'  "#65666B
let s:white  = '188'
let s:purple = '177'
let s:green  = '156'
let s:pink   = '212'
let s:cyan   = '117'
let s:yellow = '228' "#ffff87

call s:HL("Normal", s:white, s:bg, "")
call s:HL("Comment", s:grey, "", "")
call s:HL("ColorColumn", "", s:grey, "")



"""
""" P Y T H O N
"""

" Pink
" Import    import from as
" Operator  and in is not or
" Exception try except finally
call s:HL("pythonImport", s:pink, "", "")
call s:HL("pythonInclude", s:pink, "", "")
call s:HL("pythonOperator", s:pink, "", "")
call s:HL("pythonException", s:pink, "", "")

" Yellow
" Strings, Multi-line comments
call s:HL("pythonString", s:yellow, "", "")

" Purple
" Boolean True False 
" Numbers Floats
call s:HL("pythonBoolean", s:purple, "", "")
call s:HL("pythonNumber", s:purple, "", "")
call s:HL("pythonFloat", s:purple, "", "")

" Green
" Function 
" Statement   def class with pass break continue return assert yield
" Repeat      for while
" Conditional if elif else
" @decorators
call s:HL("pythonFunction", s:green, "", "")
call s:HL("pythonStatement", s:green, "", "")
call s:HL("pythonRepeat", s:green, "", "")
call s:HL("pythonConditional", s:green, "", "")
call s:HL("pythonDecorator", s:green, "", "")
call s:HL("pythonDottedNamed", s:green, "", "")

" Cyan
" Builtin   print file range input
call s:HL("pythonBuiltinFunc", s:cyan, "", "")

" Error Detection
" Whitespace
hi pythonSpaceError ctermbg=255



"""
""" J I N J A  2
"""

" Gree


"
" Delete Helper Functions: {{{
delf s:HL
" }}}
