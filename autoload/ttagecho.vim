" ttagecho.vim
" @Author:      Thomas Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-10-28.
" @Last Change: 2007-10-30.
" @Revision:    0.0.119

if &cp || exists("loaded_ttagecho_autoload")
    finish
endif
let loaded_ttagecho_autoload = 1


let s:echo_constraints = ''
let s:echo_index       = -1
let s:echo_tags        = []


function! ttagecho#Expr(rx, ...) "{{{3
    let many_lines = a:0 >= 1 ? a:1 : 0
    let bang       = a:0 >= 2 ? a:2 : 0
    let constraint = a:rx . bang
    " TLogVAR a:rx, many_lines, bang
    if s:echo_constraints != constraint
	    let s:echo_constraints = constraint
        let s:echo_index       = -1
        if bang
            " TLogDBG "BANG"
            let tags = &l:tags
            if empty(tags)
                setlocal tags<
            endif
            try
                if exists('b:ttagecho_more_tags') && !empty(b:ttagecho_more_tags)
                    let &l:tags .= ','. b:ttagecho_more_tags
                endif
                if !empty(g:ttagecho_more_tags)
                    let &l:tags .= ','. g:ttagecho_more_tags
                endif
                " TLogVAR &l:tags
                let s:echo_tags = taglist(a:rx)
            finally
                let &l:tags = tags
            endtry
        else
            " TLogDBG "NOBANG"
            let s:echo_tags = taglist(a:rx)
        endif
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
            let rv = map(range(lines), 's:FormatTag(v:val + 1, max_index, s:echo_tags[v:val], many_lines)')
            if !empty(extra)
                call add(rv, extra)
            endif
            return join(rv, "\n")
        else
            let tag = s:echo_tags[s:echo_index]
            return s:FormatTag(s:echo_index + 1, max_index, tag, many_lines)
        endif
    endif
    return ''
endf


function! s:FormatName(tag) "{{{3
    if exists('*TTagechoFormat_'. &filetype)
        let name = TTagechoFormat_{&filetype}(a:tag)
    elseif has_key(a:tag, 'signature')
        let name = a:tag.name . a:tag.signature
    elseif a:tag.cmd[0] == '/'
        let name = a:tag.cmd
        let name = substitute(name, '^/\^\?\s*', '', '')
        let name = substitute(name, '\s*\$\?/$', '', '')
        if has_key(g:ttagecho_substitute, &filetype)
            for [rx, rplc, sub] in g:ttagecho_substitute[&filetype]
                let name = substitute(name, rx, rplc, sub)
            endfor
        endif
    else
        let name = a:tag.name
    endif
    return name
endf


function! s:FormatTag(index, max_index, tag, many_lines) "{{{3
    let name = s:FormatName(a:tag)
    let fmt  = '%s: %-'. (&co / 2) .'s | %s'
    if a:max_index == 1
        let rv = printf(fmt, a:tag.kind, name, fnamemodify(a:tag.filename, ":t"))
    else
        let rv = printf('%0'. len(a:max_index) .'d:'. fmt, a:index, a:tag.kind, name, fnamemodify(a:tag.filename, ":t"))
    endif
    return rv
endf


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


function! ttagecho#EchoWord(bang) "{{{3
    " TLogVAR a:bang
    call ttagecho#Echo('\V\C\^'. expand('<cword>') .'\$', 0, a:bang)
endf


function! ttagecho#EchoWords(bang) "{{{3
    " TLogVAR a:bang
    call ttagecho#Echo('\V\C\^'. expand('<cword>') .'\$', -1, a:bang)
endf


function! ttagecho#OverParanthesis(mode) "{{{3
    let line = strpart(getline('.'), 0, col('.') - 1)
    let text = matchstr(line, '\w\+\ze\((.\{-}\)\?$')
    " TLogVAR text
    if &showmode && a:mode == 'i' && g:ttagecho_restore_showmode != -1 && &cmdheight == 1
        let g:ttagecho_restore_showmode = 1
        " TLogVAR g:ttagecho_restore_showmode
        set noshowmode
    endif
    " TLogDBG 'Do the echo'
    call ttagecho#Echo('\V\C\^'. text .'\$', 0, 0)
endf


function! ttagecho#Balloon() "{{{3
    let line = getline(v:beval_lnum)
    let text = matchstr(line, '\w*\%'. v:beval_col .'c\w*')
    return ttagecho#Expr('\V\C\^'. text .'\$', g:ttagecho_balloon_limit)
endf

