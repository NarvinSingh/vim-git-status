let s:debug = 0

function! gitstatus#GetStatus(...)
  let a:branchFormat  = get(a:000, 0, '[%s]')
  let a:statusFormat  = get(a:000, 1, '[%s]')
  let status          = ''
  let curDir          = trim(system('pwd'))
  let fileDir         = fnamemodify(resolve(expand('%:p')), ':h')
  let chgDir          = curDir ==# fileDir ? 0 : 1
  let cmd             = chgDir ? 'cd ' . shellescape(fileDir) . '; ' : ''
  let cmd             .= 'git branch | grep -m 1 ''^\*\s'' | cut -c 3-'
  let cmd             .= chgDir ? '; cd ' . shellescape(curDir) : ''
  let currentBranch   = trim(system(cmd))

  if currentBranch !=# ''
    let cmd           = chgDir ? 'cd ' . shellescape(fileDir) . '; ' : ''
    let cmd           .= 'git status --porcelain '
                      \   . shellescape(resolve(expand('%:p')))
    let cmd           .= chgDir ? '; cd ' . shellescape(curDir) : ''
    let fullStatus    = system(cmd)

    let status = printf(
      \ a:statusFormat,
      \ strcharpart(fullStatus, 2, 1) ==# ' '
      \   ? strcharpart(fullStatus, 0, 2)
      \   : '  ')
  endif

  return currentBranch . status
endfunction

let s:statusLine = ''
let s:statusLines = {}

function! gitstatus#GetBufferStatus()
  return get(s:statusLines, bufnr('%'), '')
endfunction

augroup gitstatus
  autocmd!
  autocmd BufEnter,BufWritePost *
    \ let s:statusLines[bufnr('%')] = gitstatus#GetStatus()
augroup END
