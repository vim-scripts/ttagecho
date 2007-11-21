" ttagecho.vim
" @Author:      Thomas Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-10-28.
" @Last Change: 2007-11-19.
" @Revision:    0.0.148

if &cp || exists("loaded_ttagecho_autoload")
    finish
endif
let loaded_ttagecho_autoload = 1


let s:echo_constraints = ''
let s:echo_index       = -1
let s:echo_tags        = []


" :def: function! ttagecho#Expr(rx, ?many_lines=0, ?bang=0, ?compact=0)
" Return a string representing the tags matching rx.
function! ttagecho#Expr(rx, ...) "{{{3
    let many_lines = a:0 >= 1 ? a:1 : 0
    let bang       = a:0 >= 2 ? a:2 : 0
    let compact    = a:0 >= 3 ? a:3 : 0
    let constraint = a:rx . bang
    " TLogVAR a:rx, many_lines, bang, compact
    if s:echo_constraints != constraint
	    let s:echo_constraints = constraint
        let s:echo_index       = -1
        let s:echo_tags = tlib#tag#Collect({'name': a:rx}, bang, 0)
	endif
    if !empty(s:echo_tags)
        let max_index    = len(s:echo_tags)
        let s:echo_index = (s:echo_index + 1) % max_index
        " TLogVAR tag
        if many_lines != 0
            let lines = len(s:echo_tags)
            if many_lines > 0 && many_lines < lines
                let lines = many_lines
                let extra = '...'
            else
                let extra = ''
            endif
            " TLogVAR many_lines, lines
            let rv = map(range(lines), 's:FormatTag(v:val + 1, max_index, s:echo_tags[v:val], many_lines, compact)')
            if !empty(extra)
                call add(rv, extra)
            endif
            return join(rv, "\n")
        else
            let tag = s:echo_tags[s:echo_index]
            return s:FormatTag(s:echo_index + 1, max_index, tag, many_lines, compact)
        endif
    endif
    return ''
endf


function! s:FormatName(tag) "{{{3
    if exists('*TTagechoFormat_'. &filetype)
        let name = TTagechoFormat_{&filetype}(a:tag)
    else
        let name = tlib#tag#Format(a:tag)
    endif
    return name
endf


function! s:FormatTag(index, max_index, tag, many_lines, compact) "{{{3
    let name = s:FormatName(a:tag)
    let wd = a:compact && !a:many_lines ? '' : '-'. eval(g:ttagecho_tagwidth)
    " TLogVAR a:compact, a:max_index, wd
    let fmt  = '%s: %'. wd .'s | %s'
    if a:max_index == 1
        let rv = printf(fmt, a:tag.kind, name, fnamemodify(a:tag.filename, ":t"))
    else
        let rv = printf('%0'. len(a:max_index) .'d:'. fmt, a:index, a:tag.kind, name, fnamemodify(a:tag.filename, ":t"))
    endif
    return rv
endf


function! s:WordRx(word) "{{{3
    let rv = '\V\C\^'. escape(a:word, '\')
    if !g:ttagecho_matchbeginning
        let rv .= '\$'
    endif
    return rv
endf


" Echo the tag(s) matching rx.
function! ttagecho#Echo(rx, many_lines, bang) "{{{3
    " TLogVAR a:rx, a:many_lines, a:bang
    let expr = ttagecho#Expr(a:rx, a:many_lines, a:bang)
    if empty(expr)
        echo
    else
        echohl Type
        if a:many_lines != 0
            echo expr
        else
            echo strpart(expr, 0, &columns - &fdc - 10)
        endif
        echohl NONE
    endif
endf


" Echo one match for the tag under cursor.
function! ttagecho#EchoWord(bang) "{{{3
    " TLogVAR a:bang
    call ttagecho#Echo('\V\C\^'. expand('<cword>') .'\$', 0, a:bang)
endf


" Echo all matches for the tag under cursor.
function! ttagecho#EchoWords(bang) "{{{3
    " TLogVAR a:bang
    call ttagecho#Echo('\V\C\^'. expand('<cword>') .'\$', -1, a:bang)
endf


" Echo the tag in front of an opening round parenthesis.
function! ttagecho#OverParanthesis(mode) "{{{3
    let line = strpart(getline('.'), 0, col('.') - 1)
    let text = matchstr(line, '\a\+\ze\((.\{-}\)\?$')
    " TLogVAR text, line
    if &showmode && a:mode == 'i' && g:ttagecho_restore_showmode != -1 && &cmdheight == 1
        let g:ttagecho_restore_showmode = 1
        " TLogVAR g:ttagecho_restore_showmode
        set noshowmode
    endif
    " TLogDBG 'Do the echo'
    call ttagecho#Echo(s:WordRx(text), 0, 0)
endf


" Return tag information for the tag under the mouse pointer (see 'balloonexpr')
function! ttagecho#Balloon() "{{{3
    let line = getline(v:beval_lnum)
    let text = matchstr(line, '\w*\%'. v:beval_col .'c\w*')
    return ttagecho#Expr(s:WordRx(text), eval(g:ttagecho_balloon_limit), 0, 1)
endf

