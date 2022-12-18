
function! vimfmt#tests#basics#run_tests() abort
  call assert_equal([], vimfmt#core#format([]))
  call s:legacy_run_tests()
  call s:vim9_run_tests()
endfunction

function! s:legacy_run_tests() abort
  call assert_equal([
    \ 'let x = 1'
    \ ], vimfmt#core#format([
    \ 'let x = 1']))

  call assert_equal([
    \ 'let x = 1'
    \ ], vimfmt#core#format([
    \ 'l',
    \ '  \et x = 1']))

  call assert_equal([
    \ 'let x = 1',
    \ '  \+ 2',
    \ '  \+ 3',
    \ 'let y = 1'
    \ ], vimfmt#core#format([
    \ 'let x = 1',
    \ '\+ 2',
    \ '\+ 3',
    \ 'let y = 1']))

  call assert_equal([
    \ 'if',
    \ 'endif'
    \ ], vimfmt#core#format([
    \ 'if',
    \ 'endif']))

  call assert_equal([
    \ 'if',
    \ 'else',
    \ 'endif'
    \ ], vimfmt#core#format([
    \ 'if',
    \ 'else',
    \ 'endif']))

  call assert_equal([
    \ 'if',
    \ 'elseif',
    \ 'else',
    \ 'endif'
    \ ], vimfmt#core#format([
    \ 'if',
    \ 'elseif',
    \ 'else',
    \ 'endif']))

  call assert_equal([
    \ 'while',
    \ 'endwhile'
    \ ], vimfmt#core#format([
    \ 'while',
    \'endwhile']))

  call assert_equal([
    \ 'try',
    \ 'endtry'
    \ ], vimfmt#core#format([
    \ 'try',
    \'endtry']))

  call assert_equal([
    \ 'try',
    \ 'catch',
    \ 'endtry'
    \ ], vimfmt#core#format([
    \ 'try',
    \ 'catch',
    \ 'endtry']))

  call assert_equal([
    \ 'try',
    \ 'catch',
    \ 'finally',
    \ 'endtry'
    \ ], vimfmt#core#format([
    \ 'try',
    \ 'catch',
    \ 'finally',
    \ 'endtry']))

  call assert_equal([
    \ 'augroup vimfmt',
    \ 'augroup END',
    \ 'let x = 2'
    \ ], vimfmt#core#format([
    \ 'augroup vimfmt',
    \ 'augroup END',
    \ 'let x = 2']))

  call assert_equal([
    \ 'augroup vimfmt',
    \ '  autocmd!',
    \ 'augroup END',
    \ 'let x = 2'
    \ ], vimfmt#core#format([
    \ 'augroup vimfmt',
    \ 'autocmd!',
    \ 'augroup END',
    \ 'let x = 2']))

  call assert_equal([
    \ 'augroup xxx',
    \ '  autocmd!',
    \ '  autocmd FileType vim',
    \ '    \ : if 1',
    \ '    \ |     echo 1234',
    \ '    \ | else',
    \ '    \ |     echo 5678',
    \ '    \ | endif',
    \ 'augroup END',
    \ ], vimfmt#core#format([
    \ 'augroup xxx',
    \ 'autocmd!',
    \ 'autocmd FileType vim',
    \ '\ : if 1',
    \ '\ |     echo 1234',
    \ '\ | else',
    \ '\ |     echo 5678',
    \ '\ | endif',
    \ 'augroup END']))

  call assert_equal([
    \ 'let xs = [',
    \ '  \ 1,',
    \ '  \ 2,',
    \ '  "\ 3,',
    \ '  \ ]'
    \ ], vimfmt#core#format([
    \ 'let xs = [',
    \ '\ 1,',
    \ '\ 2,',
    \ '"\ 3,',
    \ '\ ]']))

  call assert_equal([
    \ 'let hgoe =<< trim eval END',
    \ '        text text',
    \ 'text text',
    \ '    text text',
    \ 'END'
    \ ], vimfmt#core#format([
    \ '  let hgoe =<< trim eval END',
    \ '        text text',
    \ 'text text',
    \ '    text text',
    \ 'END']))

  call assert_equal([
    \ 'var hgoe =<< trim eval END',
    \ '        text text',
    \ 'text text',
    \ '    text text',
    \ 'END'
    \ ], vimfmt#core#format([
    \ '  var hgoe =<< trim eval END',
    \ '        text text',
    \ 'text text',
    \ '    text text',
    \ 'END']))

  call assert_equal([
    \ 'const hgoe =<< trim eval END',
    \ '        text text',
    \ 'text text',
    \ '    text text',
    \ 'END'
    \ ], vimfmt#core#format([
    \ '  const hgoe =<< trim eval END',
    \ '        text text',
    \ 'text text',
    \ '    text text',
    \ 'END']))

  call assert_equal([
    \ 'cons hgoe =<< trim eval END',
    \ '        text text',
    \ 'text text',
    \ '    text text',
    \ 'END'
    \ ], vimfmt#core#format([
    \ '  cons hgoe =<< trim eval END',
    \ '        text text',
    \ 'text text',
    \ '    text text',
    \ 'END']))

  call assert_equal([
    \ 'if 1',
    \ '  let x =<< trim eval END',
    \ '        text text',
    \ 'text text',
    \ '    text text',
    \ 'END',
    \ '  echo x',
    \ 'endif'
    \ ], vimfmt#core#format([
    \ 'if 1',
    \ '  let x =<< trim eval END',
    \ '        text text',
    \ 'text text',
    \ '    text text',
    \ 'END',
    \ 'echo x',
    \ 'endif']))

  call assert_equal([
    \ 'if 1',
    \ '  let x =<< trim eval END',
    \ '  text text',
    \ '  text text',
    \ '  text text',
    \ '  END',
    \ '  echo x',
    \ 'endif'
    \ ], vimfmt#core#format([
    \ 'if 1',
    \ '  let x =<< trim eval END',
    \ '        text text',
    \ 'text text',
    \ '    text text',
    \ '   END',
    \ 'echo x',
    \ 'endif']))

  call assert_equal([
    \ 'if 1',
    \ '  let x =<< END',
    \ '        text text',
    \ 'text text',
    \ '    text text',
    \ 'END',
    \ '  echo x',
    \ 'endif'
    \ ], vimfmt#core#format([
    \ 'if 1',
    \ '  let x =<< END',
    \ '        text text',
    \ 'text text',
    \ '    text text',
    \ 'END',
    \ 'echo x',
    \ 'endif']))
endfunction

function! s:vim9_run_tests() abort
  call assert_equal([
    \ 'try',
    \ 'final x = 2',
    \ 'catch',
    \ 'finally',
    \ 'endtry'
    \ ], vimfmt#core#format([
    \ 'try',
    \ 'final x = 2',
    \ 'catch',
    \ 'finally',
    \ 'endtry']))

  call assert_equal([
    \ 'vim9script',
    \ 'try',
    \ '  final x = 2',
    \ 'catch',
    \ 'finally',
    \ 'endtry'
    \ ], vimfmt#core#format([
    \ 'vim9script',
    \ 'try',
    \ 'final x = 2',
    \ 'catch',
    \ 'finally',
    \ 'endtry']))

  call assert_equal([
    \ 'def hoge',
    \ 'let x = 1',
    \ 'enddef'
    \ ], vimfmt#core#format([
    \ 'def hoge',
    \ 'let x = 1',
    \ 'enddef']))

  call assert_equal([
    \ 'vim9script',
    \ 'def hoge',
    \ '  let x = 1',
    \ 'enddef'
    \ ], vimfmt#core#format([
    \ 'vim9script',
    \ 'def hoge',
    \ 'let x = 1',
    \ 'enddef']))

  call assert_equal([
    \ 'export def hoge',
    \ 'let x = 1',
    \ 'enddef'
    \ ], vimfmt#core#format([
    \ 'export def hoge',
    \ 'let x = 1',
    \ 'enddef']))

  call assert_equal([
    \ 'vim9script',
    \ 'export def hoge',
    \ '  let x = 1',
    \ 'enddef'
    \ ], vimfmt#core#format([
    \ 'vim9script',
    \ 'export def hoge',
    \ 'let x = 1',
    \ 'enddef']))

  call assert_equal([
    \ 'class hoge',
    \ 'let x = 1',
    \ 'endclass'
    \ ], vimfmt#core#format([
    \ 'class hoge',
    \ 'let x = 1',
    \ 'endclass']))

  call assert_equal([
    \ 'vim9script',
    \ 'class hoge',
    \ '  let x = 1',
    \ 'endclass'
    \ ], vimfmt#core#format([
    \ 'vim9script',
    \ 'class hoge',
    \ 'let x = 1',
    \ 'endclass']))

  call assert_equal([
    \ 'export class hoge',
    \ 'let x = 1',
    \ 'endclass'
    \ ], vimfmt#core#format([
    \ 'export class hoge',
    \ 'let x = 1',
    \ 'endclass']))

  call assert_equal([
    \ 'vim9script',
    \ 'export class hoge',
    \ '  let x = 1',
    \ 'endclass'
    \ ], vimfmt#core#format([
    \ 'vim9script',
    \ 'export class hoge',
    \ 'let x = 1',
    \ 'endclass']))

  call assert_equal([
    \ 'interface hoge',
    \ 'let x = 1',
    \ 'endinterface'
    \ ], vimfmt#core#format([
    \ 'interface hoge',
    \ 'let x = 1',
    \ 'endinterface']))

  call assert_equal([
    \ 'vim9script',
    \ 'interface hoge',
    \ '  let x = 1',
    \ 'endinterface'
    \ ], vimfmt#core#format([
    \ 'vim9script',
    \ 'interface hoge',
    \ 'let x = 1',
    \ 'endinterface']))

  call assert_equal([
    \ 'export interface hoge',
    \ 'let x = 1',
    \ 'endinterface'
    \ ], vimfmt#core#format([
    \ 'export interface hoge',
    \ 'let x = 1',
    \ 'endinterface']))

  call assert_equal([
    \ 'vim9script',
    \ 'export interface hoge',
    \ '  let x = 1',
    \ 'endinterface'
    \ ], vimfmt#core#format([
    \ 'vim9script',
    \ 'export interface hoge',
    \ 'let x = 1',
    \ 'endinterface']))

  call assert_equal([
    \ 'let xs = [',
    \ '  \ 1,',
    \ '  \ 2,',
    \ '#\ 3,',
    \ '  \ ]'
    \ ], vimfmt#core#format([
    \ 'let xs = [',
    \ '\ 1,',
    \ '\ 2,',
    \ '#\ 3,',
    \ '\ ]']))

  call assert_equal([
    \ 'vim9script',
    \ 'let xs = [',
    \ '  \ 1,',
    \ '  \ 2,',
    \ '  #\ 3,',
    \ '  \ ]'
    \ ], vimfmt#core#format([
    \ 'vim9script',
    \ 'let xs = [',
    \ '\ 1,',
    \ '\ 2,',
    \ '#\ 3,',
    \ '\ ]']))
endfunction
