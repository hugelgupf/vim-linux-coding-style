" Vim plugin to fit the Akaros kernel coding style and help kernel development
" Maintainer:   Vivien Didelot <vivien.didelot@savoirfairelinux.com>
" Modified for Akaros: Christopher Koch <chris@kochris.com>
" License:      Distributed under the same terms as Vim itself.
"
" This script is inspired from an article written by Bart:
" http://www.jukie.net/bart/blog/vim-and-linux-coding-style
" and various user comments.
"
" For those who want to apply these options conditionally, you can define an
" array of patterns in your vimrc and these options will be applied only if
" the buffer's path matches one of the pattern. In the following example,
" options will be applied only if "/linux/" or "/kernel" is in buffer's path.
"
"   let g:linuxsty_patterns = [ "/linux/", "/kernel/" ]

if exists("g:loaded_akarossty")
    finish
endif
let g:loaded_akarossty = 1

set wildignore+=*.ko,*.mod.c,*.order,modules.builtin

augroup akarossty
    autocmd!

    autocmd FileType c,cpp call s:AkarosConfigure()
    autocmd FileType diff,kconfig setlocal tabstop=8
augroup END

function s:AkarosConfigure()
    let apply_style = 0

    if exists("g:akarossty_patterns")
        let path = expand('%:p')
        for p in g:akarossty_patterns
            if path =~ p
                let apply_style = 1
                break
            endif
        endfor
    else
        let apply_style = 1
    endif

    if apply_style
        call s:AkarosCodingStyle()
    endif
endfunction

command! AkarosCodingStyle call s:AkarosCodingStyle()

function! s:AkarosCodingStyle()
    call s:AkarosFormatting()
    call s:AkarosKeywords()
    call s:AkarosHighlighting()
endfunction

function s:AkarosFormatting()
    setlocal tabstop=4
    setlocal shiftwidth=4
    setlocal softtabstop=4
    setlocal textwidth=80
    setlocal noexpandtab

    setlocal cindent
    setlocal cinoptions=:0,l1,t0,g0,(0
endfunction

function s:AkarosKeywords()
    syn keyword cOperator likely unlikely
    syn keyword cType u8 u16 u32 u64 s8 s16 s32 s64
    syn keyword cType __u8 __u16 __u32 __u64 __s8 __s16 __s32 __s64
endfunction

function s:AkarosHighlighting()
    highlight default link AkarosError ErrorMsg

    syn match AkarosError / \+\ze\t/     " spaces before tab
    syn match AkarosError /\%81v.\+/     " virtual column 81 and more

    " Highlight trailing whitespace, unless we're in insert mode and the
    " cursor's placed right after the whitespace. This prevents us from having
    " to put up with whitespace being highlighted in the middle of typing
    " something
    autocmd InsertEnter * match AkarosError /\s\+\%#\@<!$/
    autocmd InsertLeave * match AkarosError /\s\+$/
endfunction

" vim: ts=4 et sw=4
