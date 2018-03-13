" gf_python.vim - Execute text as shell commands
" Maintainer: Matthew Franglen
" Version:    0.0.7

if exists('g:loaded_gf_python') || &compatible
  finish
endif
let g:loaded_gf_python = 1

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
