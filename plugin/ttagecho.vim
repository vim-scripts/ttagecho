" ttagecho.vim -- Show current tag information
" @Author:      Thomas Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-10-28.
" @Last Change: 2007-10-30.
" @Revision:    0.1.81
" GetLatestVimScripts: 0 0 ttagecho.vim

if &cp || exists("loaded_ttagecho")
    finish
endif
let loaded_ttagecho = 1

let s:save_cpo = &cpo
set cpo&vim


if !exists('g:ttagecho_parentheses_patterns')
    " If hookcursormoved (vimscript #) is installed, display tag 
    " information when moving over parantheses for these filetypes.
    " :read: let g:ttagecho_parentheses_patterns = [] "{{{2
    let g:ttagecho_parentheses_patterns = [
                \ '*.c',
                \ '*.h',
                \ '*.java',
                \ '*.js',
                \ '*.php',
                \ '*.rb',
                \ '*.vim',
                \ ]
endif


if !exists('g:ttagecho_balloon_patterns')
    " Set 'balloonexpr' for buffers that match these patterns.
    let g:ttagecho_balloon_patterns = g:ttagecho_parentheses_patterns  "{{{2
    " let g:ttagecho_balloon_patterns = ['*'] "{{{2
endif


if !exists('g:ttagecho_substitute')
    " Filter the expression through |substitute()| for these filetypes. 
    " This applies only if the tag cmd field (see |taglist()|) is used.
    " :read: let g:ttagecho_substitute = {} "{{{2
    let g:ttagecho_substitute = {
                \ 'java': [['\s*{\s*$', '', '']],
                \ 'ruby': [['\<\(def\|class\|module\)\>\s\+', '', '']],
                \ 'vim':  [
                \   ['^\s*\(let\|fu\%[nction]!\?\|com\%[mand]!\?\(\s\+-\S\+\)*\)\s*', '', ''],
                \   ['"\?\s*{{{\d.*$', '', ''],
                \ ],
                \ }
endif


" If 'showmode' is set, |ttagecho#OverParanthesis()| will temporarily 
" unset the option when triggered in insert mode. The original value 
" will be restored on the next CursorHold(I) events.
" Set this variable to -1, if you don't want this to happen. In this 
" case you might need to set 'cmdheight' to something greater than 1.
let g:ttagecho_restore_showmode = 0 "{{{2


if !exists('g:ttagecho_more_tags')
    " A comma-separated list of additional tag files (see 'tags') that will 
    " be used, when invoked with a <bang>. Can also be buffer-local.
    " This variable can be used to scan voluminous tag files (eg general 
    " SDK/standard library tags) only when really needed while normally 
    " using the project tags only.
    let g:ttagecho_more_tags = '' "{{{2
endif


if !exists('g:ttagecho_balloon_limit')
    let g:ttagecho_balloon_limit = &lines   "{{{2
endif


augroup TTagecho
    autocmd!
    if exists('loaded_hookcursormoved')
        for s:pattern in g:ttagecho_parentheses_patterns
            exec 'autocmd BufNewFile,BufReadPost,FileType '. s:pattern .' call hookcursormoved#Register("parenthesis_round", "ttagecho#OverParanthesis")'
            exec 'autocmd CursorHold,CursorHoldI,InsertLeave '. s:pattern .' if g:ttagecho_restore_showmode == 1 | set showmode | echo | endif'
        endfor
        for s:pattern in g:ttagecho_balloon_patterns
            exec 'autocmd BufNewFile,BufReadPost,FileType '. s:pattern .' set ballooneval bexpr=ttagecho#Balloon()'
        endfor
        unlet s:pattern
    endif
augroup END


" :display: TTagecho[!] [TAGS_RX]
" Show the tag in the echo area. If invoked repeatedly, this command 
" will loop through matching tags.
command! -bang -nargs=1 -bar TTagecho call ttagecho#Echo(<q-args>, 0, !empty('<bang>'))

" :display: TTagechoAll[!] [TAGS_RX]
" Show all matches.
command! -bang -nargs=1 -bar TTagechoAll call ttagecho#Echo(<q-args>, -1, !empty('<bang>'))

" :display: TTagechoWord[!]
" Show information for the word under cursor.
command! -bang TTagechoWord call ttagecho#EchoWord(!empty('<bang>'))

" :display: TTagechoWords[!]
" Show all matches for the word under cursor.
command! -bang TTagechoWords call ttagecho#EchoWords(!empty('<bang>'))


let &cpo = s:save_cpo
unlet s:save_cpo

finish
CHANGES:
0.1
- Initial release

