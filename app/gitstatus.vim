let s:debug = 0

function! gitstatus#GetBranch(...)
  let a:format      = get(a:000, 0, '[%s]')
  let currentBranch = ''
  let curDir        = trim(system('pwd'))
  let fileDir       = expand('%:p:h')
  let chgDir        = curDir ==# fileDir ? 0 : 1
  let cmd           = chgDir ? 'cd ' . shellescape(fileDir) . '; ' : ''
  let cmd           .= 'git branch'
  let cmd           .= chgDir ? '; cd ' . shellescape(curDir) : ''
  let branches      = split(system(cmd), '\n')

  for branch in branches
    if strcharpart(branch, 0, 1) ==# '*'
        let currentBranch = printf(a:format, strcharpart(branch, 2))
        break
    endif
  endfor

  return currentBranch
endfunction

function! gitstatus#GetStatus(...)
  let a:format      = get(a:000, 0, '[%s]')
  let status        = ''
  let cmd           = 'git status --porcelain ' . shellescape(expand('%:p'))
  let fullStatus    = system(cmd)

  if strcharpart(fullStatus, 2, 1) ==# ' '
   let status = printf(a:format, strcharpart(fullStatus, 0, 2))
  endif

  return status
endfunction

let s:statusLine = ''

function! gitstatus#GetStatusLine()
  return s:statusLine
endfunction

augroup gitstatus
  autocmd!
  autocmd BufEnter,BufWritePost *
    \ let s:statusLine = gitstatus#GetBranch() . gitstatus#GetStatus()
augroup END

