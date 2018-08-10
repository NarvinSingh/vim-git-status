let s:debug = 0

function! gitstatus#GetStatus(...)
  let a:branchFormat  = get(a:000, 0, '[%s]')
  let a:statusFormat  = get(a:000, 1, '[%s]')
  let currentBranch   = ''
  let status          = ''
  let curDir          = trim(system('pwd'))
  let fileDir         = expand('%:p:h')
  let chgDir          = curDir ==# fileDir ? 0 : 1
  let cmd             = chgDir ? 'cd ' . shellescape(fileDir) . '; ' : ''
  let cmd             .= 'git branch'
  let cmd             .= chgDir ? '; cd ' . shellescape(curDir) : ''
  let branches        = split(system(cmd), '\n')

  for branch in branches
    if strcharpart(branch, 0, 1) ==# '*'
        let currentBranch = printf(a:branchFormat, strcharpart(branch, 2))
        break
    endif
  endfor

  if currentBranch !=# ''
    let cmd           = chgDir ? 'cd ' . shellescape(fileDir) . '; ' : ''
    let cmd           .= 'git status --porcelain ' . shellescape(expand('%:p'))
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
"  autocmd FocusGained * echom 'FocusGained'
"  autocmd VimResized * echom 'VimResized'
"  autocmd CmdwinEnter * echom 'CmdwinEnter'
"  autocmd CmdwinLeave * echom 'CmdwinLeave'
"  autocmd FileChangedShell * echom 'FileChangedShell'
"  autocmd FileChangedShell * echom 'FileChangedShell'
"  autocmd ShellCmdPost * echom 'ShellCmdPost'
"  autocmd BufEnter * echom 'BufEnter'
"  autocmd BufReadPost * echom 'BufReadPost'
"  autocmd InsertLeave * echom 'InsertLeave'
augroup END
