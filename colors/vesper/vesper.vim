" Vesper Vim Colorscheme
" Enhanced with macOS system appearance detection

highlight clear
if exists("syntax_on")
    syntax reset
endif

" Function to detect macOS system appearance
function! s:DetectMacOSAppearance()
    if has('mac') && executable('defaults')
        " Check if Dark Mode is enabled
        let l:dark_mode = system('defaults read -g AppleInterfaceStyle 2>/dev/null')
        return l:dark_mode =~? 'dark'
    endif
    return 0
endfunction

" Function to detect terminal background if available
function! s:DetectTerminalBackground()
    " Some terminals set this environment variable
    if exists('$COLORFGBG')
        " Format is usually "foreground;background"
        let l:colors = split($COLORFGBG, ';')
        if len(l:colors) >= 2
            let l:bg = str2nr(l:colors[-1])
            " Light backgrounds typically have higher values
            return l:bg > 7
        endif
    endif
    return 0
endfunction

" Determine if we should use dark mode (reversed logic for clarity)
let s:use_dark = 1  " Default to dark

" Priority order for detection:
" 1. Explicit user override
if exists('g:vesper_force_light')
    let s:use_dark = !g:vesper_force_light
" 2. Explicit user override for dark
elseif exists('g:vesper_force_dark')
    let s:use_dark = g:vesper_force_dark
" 3. Vim's background setting
elseif &background == 'light'
    let s:use_dark = 0
" 4. macOS system setting
elseif has('mac')
    let s:use_dark = s:DetectMacOSAppearance()
" 5. Terminal background detection
else
    let s:use_dark = !s:DetectTerminalBackground()
endif

" Set background and colorscheme name
if s:use_dark
    set background=dark
    let g:colors_name = "vesper"
else
    set background=light
    let g:colors_name = "vesper-light"
endif

" Helper function for highlights
function! s:hi(name, guifg, guibg, ctermfg, ctermbg, ...)
    let l:cmd = 'highlight ' . a:name
    if a:guifg != ''
        let l:cmd .= ' guifg=' . a:guifg
    endif
    if a:guibg != ''
        let l:cmd .= ' guibg=' . a:guibg
    endif
    if a:ctermfg != ''
        let l:cmd .= ' ctermfg=' . a:ctermfg
    endif
    if a:ctermbg != ''
        let l:cmd .= ' ctermbg=' . a:ctermbg
    endif
    if a:0 > 0
        let l:cmd .= ' ' . a:1
    endif
    execute l:cmd
endfunction

" Color definitions
if s:use_dark
    let s:bg = "#101010"
    let s:enhanced_surface = "#151515"
    let s:element_hover = "#282828"
    let s:element_active = "#282828"
    let s:element_selected = "#232323"
    let s:editor_active_line = "#151515"
    let s:search_match = "#575757"
    let s:text = "#FFFFFF"
    let s:text_muted = "#65737E"
    let s:text_placeholder = "#7E7E7E"
    let s:text_accent = "#FFC799"
    let s:border = "#505050"
    let s:border_focused = "#FFC799"
    let s:status_bar_bg = "#101010"
    let s:line_number = "#505050"
    let s:active_line_number = "#FFC799"
    let s:cursor = "#FFCFA8"
    let s:red = "#FF8080"
    let s:string = "#99FFE4"
    let s:comment = "#8b8b8b"
    let s:keyword = "#A0A0A0"

    let s:cterm_bg = "0"
    let s:cterm_text = "15"
    let s:cterm_text_muted = "8"
    let s:cterm_accent = "11"
    let s:cterm_status_bg = "0"
    let s:cterm_red = "9"
    let s:cterm_string = "14"
    let s:cterm_comment = "8"
else
    let s:bg = "#F8F8F8"
    let s:enhanced_surface = "#EFEFEF"
    let s:element_hover = "#E0E0E0"
    let s:element_active = "#E0E0E0"
    let s:element_selected = "#E8E8E8"
    let s:editor_active_line = "#F0F0F0"
    let s:search_match = "#D0D0D0"
    let s:text = "#1A1A1A"
    let s:text_muted = "#6B7280"
    let s:text_placeholder = "#9CA3AF"
    let s:text_accent = "#D97706"
    let s:border = "#D1D5DB"
    let s:border_focused = "#D97706"
    let s:status_bar_bg = "#E5E5E5"
    let s:line_number = "#9CA3AF"
    let s:active_line_number = "#D97706"
    let s:cursor = "#DC2626"
    let s:red = "#DC2626"
    let s:string = "#059669"
    let s:comment = "#6B7280"
    let s:keyword = "#4B5563"

    let s:cterm_bg = "15"
    let s:cterm_text = "0"
    let s:cterm_text_muted = "8"
    let s:cterm_accent = "3"
    let s:cterm_status_bg = "7"
    let s:cterm_red = "1"
    let s:cterm_string = "2"
    let s:cterm_comment = "8"
endif

" Apply highlights
call s:hi('Normal', s:text, s:bg, s:cterm_text, s:cterm_bg)
call s:hi('Cursor', s:bg, s:cursor, s:cterm_bg, s:cterm_red)

if s:use_dark
    call s:hi('CursorLine', '', '#2a2a2a', '', '8', 'gui=NONE cterm=NONE')
    call s:hi('CursorLineNr', s:active_line_number, '#2a2a2a', s:cterm_accent, '8', 'gui=NONE cterm=NONE')
else
    call s:hi('CursorLine', '', '#E5E5E5', '', '7', 'gui=NONE cterm=NONE')
    call s:hi('CursorLineNr', s:active_line_number, '#E5E5E5', s:cterm_accent, '7', 'gui=NONE cterm=NONE')
endif

call s:hi('LineNr', s:line_number, s:bg, s:cterm_text_muted, s:cterm_bg)
call s:hi('StatusLine', s:text, s:status_bar_bg, s:cterm_text, s:cterm_status_bg, 'gui=bold cterm=bold')
call s:hi('Comment', s:comment, '', s:cterm_comment, '')
call s:hi('String', s:string, '', s:cterm_string, '')
call s:hi('Function', s:text_accent, '', s:cterm_accent, '')
call s:hi('Statement', s:keyword, '', s:cterm_text_muted, '')

" Commands for manual override
command! VesperLight let g:vesper_force_light = 1 | unlet! g:vesper_force_dark | colorscheme vesper
command! VesperDark let g:vesper_force_dark = 1 | unlet! g:vesper_force_light | colorscheme vesper
command! VesperAuto unlet! g:vesper_force_light | unlet! g:vesper_force_dark | colorscheme vesper

" Enhanced debug command to check detection
command! VesperDebug call s:DebugDetection()

function! s:DebugDetection()
    echo '=== Vesper Detection Debug ==='

    " Check platform
    echo 'Platform: has(mac)=' has('mac') ', has(unix)=' has('unix')

    " Check if defaults command exists
    echo 'defaults executable:' executable('defaults')

    " Raw system call
    if executable('defaults')
        let l:raw_output = system('defaults read -g AppleInterfaceStyle 2>&1')
        echo 'Raw defaults output: "' . substitute(l:raw_output, '\n', '\\n', 'g') . '"'
        echo 'Contains "dark":' (l:raw_output =~? 'dark')
    endif

    " Check environment variables
    echo 'COLORFGBG: "' . (exists('$COLORFGBG') ? $COLORFGBG : 'not set') . '"'
    echo 'TERM: "' . (exists('$TERM') ? $TERM : 'not set') . '"'
    echo 'TERM_PROGRAM: "' . (exists('$TERM_PROGRAM') ? $TERM_PROGRAM : 'not set') . '"'

    " Check Vim's background
    echo 'Vim &background: "' . &background . '"'

    " Function results
    echo 'DetectMacOSAppearance():' s:DetectMacOSAppearance()
    echo 'DetectTerminalBackground():' s:DetectTerminalBackground()
    echo 'Final s:use_dark:' s:use_dark
endfunction

" Auto-refresh on system changes (if supported)
if has('mac')
    augroup VesperAutoRefresh
        autocmd!
        " Refresh when gaining focus - catches system appearance changes
        autocmd FocusGained * if !exists('g:vesper_force_light') && !exists('g:vesper_force_dark') | colorscheme vesper | endif
    augroup END
endif
