" ttagecho.vim -- Show current tag information
" @Author:      Thomas Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-10-28.
" @Last Change: 2007-11-06.
" @Revision:    0.2.112
" GetLatestVimScripts: 2055 0 ttagecho.vim

if &cp || exists("loaded_ttagecho")
    finish
endif
if !exists('g:loaded_tlib') || g:loaded_tlib < 20
    echoerr 'tlib >= 0.20 is required'
    finish
endif
let loaded_ttagecho = 2

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


if !exists('g:ttagecho_restore_showmode')
    " If 'showmode' is set, |ttagecho#OverParanthesis()| will 
    " temporarily unset the option when triggered in insert mode. The 
    " original value will be restored on the next CursorHold(I) events.
    " Set this variable to -1, if you don't want this to happen. In this 
    " case you might need to set 'cmdheight' to something greater than 
    " 1.
    let g:ttagecho_restore_showmode = 0 "{{{2
endif


if !exists('g:ttagecho_balloon_limit')
    " The number of items to be displayed in the balloon popup. It will be 
    " evaluated with |eval()|, which is why it can also be a vim expression.
    let g:ttagecho_balloon_limit = '&lines * 2 / 3'   "{{{2
endif


if !exists('g:ttagecho_tagwidth')
    " The width of the tag "column". It will be evaluated with |eval()|, which 
    " is why it can also be a vim expression.
    let g:ttagecho_tagwidth = '&co / 3'  "{{{2
endif


if !exists('g:ttagecho_matchbeginning')
    " If true, match only the beginning of a tag (i.e. don't add '$' to 
    " the regexp).
    let g:ttagecho_matchbeginning = 0   "{{{2
endif


augroup TTagecho
    autocmd!
    if exists('loaded_hookcursormoved')
        for s:pattern in g:ttagecho_parentheses_patterns
            exec 'autocmd BufNewFile,BufReadPost,FileType '. s:pattern .' call hookcursormoved#Register("parenthesis_round_open", "ttagecho#OverParanthesis")'
            exec 'autocmd InsertLeave '. s:pattern .' if g:ttagecho_restore_showmode == 1 | set showmode | echo | endif'
        endfor
        if has('balloon_eval')
            for s:pattern in g:ttagecho_balloon_patterns
                exec 'autocmd BufNewFile,BufReadPost,FileType '. s:pattern .' set ballooneval bexpr=ttagecho#Balloon()'
            endfor
        endif
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

0.2
- Customize display: g:ttagecho_tagwidth
- g:ttagecho_matchbeginning
- Check for has('balloon_eval')
- Restore showmode only on InsertLeave events (not on CursorHold(I) events).

0.3
- Check only opening parentheses (require hookcursormoved 0.5)
- Use [bg]:tlib_tags_extra if defined.
- Require tlib >= 0.20
- g:ttagecho_substitute became g:tlib_tag_substitute
- Removed support for: [bg]:ttagecho_more_tags (use [bg]:tlib_tags_extra 
instead)

