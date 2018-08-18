let s:debug = 0

function! gitstatus#GetStatus(...)
  let a:branchFormat  = get(a:000, 0, '[%s]')
  let a:statusFormat  = get(a:000, 1, '[%s]')
  let status          = ''
  let fileDir         = fnamemodify(resolve(expand('%:p')), ':h')
  let cmd             = 'git -C '. shellescape(fileDir) . ' branch'
  let cmd             .= ' | grep -m 1 ''^\*\s'''
  let cmd             .= ' | cut -c 3-'
  let branch          = trim(system(cmd))

  if branch !=# ''
    let cmd           = 'git -C ' . shellescape(fileDir)
    let cmd           .= ' status --porcelain '
    let cmd           .= shellescape(resolve(expand('%:p')))
    let porcelain     = system(cmd)

    let status  = strcharpart(porcelain, 2, 1) ==# ' '
                \ ? strcharpart(porcelain, 0, 2)
                \ : '  '
  endif

  return printf(a:branchFormat, branch) . printf(a:statusFormat, status)
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
