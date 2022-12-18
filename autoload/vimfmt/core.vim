
function! vimfmt#core#format(lines, opts = {}) abort
  let opts = {
    \ 'display_progress': get(a:opts, 'display_progress', v:false),
    \ 'indent_string': get(a:opts, 'indent_string', repeat(' ' , 2)),
    \ }
  let input_chars = empty(a:lines) ? [] : split(join(a:lines, "\n"), '\zs')
  let xs = s:format_step1(input_chars, opts)
  let output = s:format_step2(xs, opts)
  if opts.display_progress
    redraw
    echo printf('[vimfmt] done!')
  endif
  return empty(xs) ? [] : split(output, "\n", v:true)
endfunction

function! s:format_step1(input_chars, opts) abort
  let xs = []
  let i = 0
  let ok = v:true
  while ok && (i < len(a:input_chars))
    let ok = v:false
    for name in [
        \ 's:consume_linebreaks',
        \ 's:consume_command',
        \ 's:consume_untileol',
        \ ]
      let x = call(name, [a:input_chars[i:]])
      if !empty(x)
        let ok = v:true
        let i += len(x.raw)
        let xs += [x]
        break
      endif
    endfor
    if a:opts.display_progress
      redraw
      echo printf('[vimfmt] progress: %d%%', float2nr(i * 100.0 / len(a:input_chars)))
    endif
  endwhile
  return xs
endfunction

function! s:format_step2(xs, opts) abort
  let output = ''
  let is_head = v:true
  let indent_count = 0
  let is_continuous = v:false
  let is_vim9 = v:false
  for i in range(0, len(a:xs) - 1)
    let x1 = a:xs[i]
    let x2 = get(a:xs, i + 1, {})
    if x1.kind == 'linebreaks'
      let output = output .. (is_head ? "\n" : x1.formated_text)
      let is_head = v:true
    else
      if is_head
        if s:match_command(x1, 'vim9s', 'cript')
          let is_vim9 = v:true
        endif
        let is_continuous = v:false
        if x1.kind == 'untileol'
          if     (!is_vim9 && (x1.formated_text =~# '^\s*"\?\\'))
              \ || (is_vim9 && (x1.formated_text =~# '^\s*#\?\\'))
            let is_continuous = v:true
          endif
        endif
        let indent_count = s:check_indent_count_dec(is_vim9, indent_count, x1, x2)
        let output = output
          \ .. repeat(a:opts.indent_string, indent_count + (is_continuous ? 1 : 0))
          \ .. matchstr(x1.formated_text, '^\s*\zs.*$')
        let indent_count = s:check_indent_count_inc(is_vim9, indent_count, x1, x2)
      else
        let output = output .. x1.formated_text
      endif
      let is_head = v:false
    endif
  endfor
  return output
endfunction

function! s:match_command(x, must, abbr = '') abort
  return get(a:x, 'formated_text', '') =~# ('^\s*' .. a:must .. (empty(a:abbr) ? '' : '\%[' .. a:abbr .. ']') .. '$')
endfunction

function! s:check_indent_count_inc(is_vim9, indent_count, x1, x2) abort
  let indent_count = a:indent_count
  if a:x1.kind == 'command'
    if       s:match_command(a:x1, 'fu', 'nction')
        \ || s:match_command(a:x1, 'if')
        \ || s:match_command(a:x1, 'el', 'se')
        \ || s:match_command(a:x1, 'elsei', 'f')
        \ || s:match_command(a:x1, 'for')
        \ || s:match_command(a:x1, 'wh', 'ile')
        \ || s:match_command(a:x1, 'try')
        \ || s:match_command(a:x1, 'cat', 'ch')
        \ || (s:match_command(a:x1, 'fina', 'lly') && (!a:is_vim9 || (a:is_vim9 && !s:match_command(a:x1, 'final'))))
      let indent_count += 1
    elseif s:match_command(a:x1, 'au', 'group') && !s:match_command(a:x2, 'END')
      let indent_count += 1
    elseif a:is_vim9
      if       s:match_command(a:x1, 'def')
          \ || s:match_command(a:x1, 'class')
          \ || s:match_command(a:x1, 'interface')
          \ || s:match_command(a:x1, 'enum')
        let indent_count += 1
      elseif s:match_command(a:x1, 'export')
        if s:match_command(a:x2, 'def')
            \ || s:match_command(a:x2, 'class')
            \ || s:match_command(a:x2, 'interface')
          let indent_count += 1
        endif
      endif
    endif
  endif
  return indent_count
endfunction

function! s:check_indent_count_dec(is_vim9, indent_count, x1, x2) abort
  let indent_count = a:indent_count
  if a:x1.kind == 'command'
    if       s:match_command(a:x1, 'endf', 'unction')
        \ || s:match_command(a:x1, 'en', 'dif')
        \ || s:match_command(a:x1, 'el', 'se')
        \ || s:match_command(a:x1, 'elsei', 'f')
        \ || s:match_command(a:x1, 'endfo', 'r')
        \ || s:match_command(a:x1, 'endw', 'hile')
        \ || s:match_command(a:x1, 'endt', 'ry')
        \ || s:match_command(a:x1, 'cat', 'ch')
        \ || (s:match_command(a:x1, 'fina', 'lly') && (!a:is_vim9 || (a:is_vim9 && !s:match_command(a:x1, 'final'))))
        \ || s:match_command(a:x1, 'enddef')
        \ || s:match_command(a:x1, 'endclass')
        \ || s:match_command(a:x1, 'endinterface')
        \ || s:match_command(a:x1, 'endenum')
      let indent_count -= 1
    elseif s:match_command(a:x1, 'au', 'group') && s:match_command(a:x2, 'END')
      let indent_count -= 1
    endif
  endif
  return indent_count
endfunction

function! s:consume_linebreaks(input_chars) abort
  let i = 0
  let n = 0
  while v:true
    let k = i
    while s:cmp_char_re(a:input_chars, k, '\s')
      let k += 1
    endwhile
    if s:cmp_char(a:input_chars, k, "\n")
      let i = k + 1
      let n += 1
    else
      break
    endif
  endwhile
  return s:make_retval(0 < n ? i : 0, 'linebreaks', a:input_chars[:i-1], repeat("\n", 2 < n ? 2 : n))
endfunction

function! s:consume_command(input_chars) abort
  let i = 0
  let ok = v:false
  let xs = []
  while s:cmp_char_re(a:input_chars, i, '\s')
    let xs += [a:input_chars[i]]
    let i += 1
  endwhile
  while v:true
    if s:cmp_char_re(a:input_chars, i, '[A-Za-z0-9_]')
      let xs += [a:input_chars[i]]
      let i += 1
      let ok = v:true
    else
      let ok2 = v:false
      let k = i
      if s:cmp_char(a:input_chars, k, "\n")
        let k += 1
        while s:cmp_char_re(a:input_chars, k, '\s')
          let k += 1
        endwhile
        if s:cmp_char(a:input_chars, k, '\')
          let k += 1
          if s:cmp_char_re(a:input_chars, k, '[A-Za-z0-9_]')
            let xs += [a:input_chars[k]]
            let k += 1
            let ok2 = v:true
          endif
        endif
      endif
      if ok2
        let i = k
        let ok = v:true
      else
        break
      endif
    endif
  endwhile
  return s:make_retval(ok ? i : 0, 'command', a:input_chars[:i-1], join(xs, ''))
endfunction

function! s:consume_untileol(input_chars) abort
  let i = 0
  while s:not_cmp_char(a:input_chars, i, "\n")
    let i += 1
  endwhile
  return s:make_retval(i, 'untileol', a:input_chars[:i-1], join(filter(a:input_chars[:i-1], { _,x -> x != "\n" }), ''))
endfunction

function! s:make_retval(i, kind, raw, formated_text) abort
  if 0 < a:i
    return { 'kind': a:kind, 'raw': a:raw, 'formated_text': a:formated_text, }
  else
    return {}
  endif
endfunction

function! s:cmp_char(input_chars, i, c) abort
  return get(a:input_chars, a:i, '') == a:c
endfunction

function! s:not_cmp_char(input_chars, i, c) abort
  return !s:cmp_char(a:input_chars, a:i, a:c) && (a:i < len(a:input_chars))
endfunction

function! s:cmp_char_re(input_chars, i, re) abort
  return get(a:input_chars, a:i, '') =~# a:re
endfunction
