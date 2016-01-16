" Version: 1.0
" Author:  Michihiro Okada <olux.888@gmail.com>
" License: VIM LICENSE

if exists('g:loaded_MatchPairBrace')
    finish
endif
let g:loaded_MatchPairBrace = 1

let s:save_cpo = &cpo
set cpo&vim

command! MatchPairBrace call MatchPairBrace#focus_change()
nnoremap <silent> <Plug>(focus_change) :<C-u>MatchPairBrace<CR>

let &cpo = s:save_cpo
unlet s:save_cpo

