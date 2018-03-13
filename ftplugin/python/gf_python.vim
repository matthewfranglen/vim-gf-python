" gf_python.vim - Execute text as shell commands
" Maintainer: Matthew Franglen
" Version:    0.0.7
" Heavily based on default python filetype plugin file

if exists("b:did_ftplugin") | finish | endif
let b:did_ftplugin = 1
let s:keepcpo= &cpo
set cpo&vim

function! ToPythonPath(module) abort
    let path_name = substitute(a:module, '\.', '/', 'g')

    for p in split(&path, ',')
        for name in [path_name, path_name . '.py', path_name . '/__init__.py']
            if filereadable(p . '/' . name)
                return name
            endif
        endfor
    endfor

    return path_name
endfunction

let &l:path = system("python -c 'import os.path, sys; sys.stdout.write(\",\".join(path for path in sys.path if os.path.isdir(path)))'")
let &l:suffixesadd = '.py,/__init__.py'
let &l:includeexpr = 'ToPythonPath(v:fname)'

setlocal cinkeys-=0#
setlocal indentkeys-=0#
setlocal include=^\\s*\\(from\\\|import\\)
setlocal comments=b:#,fb:-
setlocal commentstring=#\ %s

setlocal omnifunc=pythoncomplete#Complete

set wildignore+=*.pyc

let b:next_toplevel='\v%$\|^(class\|def\|async def)>'
let b:prev_toplevel='\v^(class\|def\|async def)>'
let b:next='\v%$\|^\s*(class\|def\|async def)>'
let b:prev='\v^\s*(class\|def\|async def)>'

execute "nnoremap <silent> <buffer> ]] :call <SID>Python_jump('n', '". b:next_toplevel."', 'W')<cr>"
execute "nnoremap <silent> <buffer> [[ :call <SID>Python_jump('n', '". b:prev_toplevel."', 'Wb')<cr>"
execute "nnoremap <silent> <buffer> ]m :call <SID>Python_jump('n', '". b:next."', 'W')<cr>"
execute "nnoremap <silent> <buffer> [m :call <SID>Python_jump('n', '". b:prev."', 'Wb')<cr>"

execute "onoremap <silent> <buffer> ]] :call <SID>Python_jump('o', '". b:next_toplevel."', 'W')<cr>"
execute "onoremap <silent> <buffer> [[ :call <SID>Python_jump('o', '". b:prev_toplevel."', 'Wb')<cr>"
execute "onoremap <silent> <buffer> ]m :call <SID>Python_jump('o', '". b:next."', 'W')<cr>"
execute "onoremap <silent> <buffer> [m :call <SID>Python_jump('o', '". b:prev."', 'Wb')<cr>"

execute "xnoremap <silent> <buffer> ]] :call <SID>Python_jump('x', '". b:next_toplevel."', 'W')<cr>"
execute "xnoremap <silent> <buffer> [[ :call <SID>Python_jump('x', '". b:prev_toplevel."', 'Wb')<cr>"
execute "xnoremap <silent> <buffer> ]m :call <SID>Python_jump('x', '". b:next."', 'W')<cr>"
execute "xnoremap <silent> <buffer> [m :call <SID>Python_jump('x', '". b:prev."', 'Wb')<cr>"

if !exists('*<SID>Python_jump')
  fun! <SID>Python_jump(mode, motion, flags) range
      if a:mode == 'x'
          normal! gv
      endif

      normal! 0

      let cnt = v:count1
      mark '
      while cnt > 0
          call search(a:motion, a:flags)
          let cnt = cnt - 1
      endwhile

      normal! ^
  endfun
endif

if has("browsefilter") && !exists("b:browsefilter")
    let b:browsefilter = "Python Files (*.py)\t*.py\n" .
                \ "All Files (*.*)\t*.*\n"
endif

if !exists("g:python_recommended_style") || g:python_recommended_style != 0
    " As suggested by PEP8.
    setlocal expandtab shiftwidth=4 softtabstop=4 tabstop=8
endif

" First time: try finding "pydoc".
if !exists('g:pydoc_executable')
    if executable('pydoc')
        let g:pydoc_executable = 1
    else
        let g:pydoc_executable = 0
    endif
endif
" If "pydoc" was found use it for keywordprg.
if g:pydoc_executable
    setlocal keywordprg=pydoc
endif

let &cpo = s:keepcpo
unlet s:keepcpo
