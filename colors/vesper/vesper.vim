" Vesper Vim Colorscheme
" Converted from Helix Vesper theme

" Reset all highlights and syntax
set background=dark
highlight clear
if exists("syntax_on")
    syntax reset
endif

" Set colorscheme name
let g:colors_name = "vesper"

" Core Colors from Palette
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

" UI Highlights
highlight Normal guifg=#FFFFFF guibg=#101010
highlight Cursor guifg=#FFCFA8 guibg=#FFCFA8
highlight CursorLine guibg=#2a2a2a ctermbg=8 gui=NONE cterm=NONE
highlight CursorLineNr guifg=#FFC799 guibg=#2a2a2a ctermbg=8 gui=NONE cterm=NONE
highlight LineNr guifg=#505050 guibg=#101010
highlight StatusLine guifg=#FFFFFF guibg=#101010
highlight StatusLineNC guifg=#65737E guibg=#101010
highlight VertSplit guifg=#505050 guibg=#101010
highlight Pmenu guifg=#FFFFFF guibg=#151515
highlight PmenuSel guifg=#101010 guibg=#FFC799
highlight PmenuSbar guifg=#FFC799 guibg=#151515
highlight Visual guibg=#232323
highlight Search guibg=#575757 guifg=#FFCFA8
highlight MatchParen guibg=#575757 guifg=#FFCFA8
highlight NonText guifg=#65737E
highlight SpecialKey guifg=#65737E
highlight Folded guifg=#FFFFFF guibg=#151515
highlight WildMenu guifg=#101010 guibg=#FFC799
highlight Title guifg=#FFCFA8 gui=bold
highlight TabLine guifg=#65737E guibg=#101010
highlight TabLineSel guifg=#FFFFFF guibg=#151515
highlight TabLineFill guibg=#101010


" Syntax Highlights
highlight Comment guifg=#8b8b8b
highlight Constant guifg=#FFFFFF
highlight String guifg=#99FFE4
highlight Character guifg=#99FFE4
highlight Number guifg=#FFFFFF
highlight Boolean guifg=#FFFFFF
highlight Float guifg=#FFFFFF
highlight Identifier guifg=#FFFFFF
highlight Function guifg=#FFCFA8
highlight Statement guifg=#A0A0A0
highlight Conditional guifg=#A0A0A0
highlight Repeat guifg=#A0A0A0
highlight Label guifg=#99FFE4
highlight Operator guifg=#A0A0A0
highlight Keyword guifg=#A0A0A0
highlight Exception guifg=#A0A0A0
highlight PreProc guifg=#A0A0A0
highlight Include guifg=#A0A0A0
highlight Define guifg=#A0A0A0
highlight Macro guifg=#A0A0A0
highlight PreCondit guifg=#A0A0A0
highlight Type guifg=#FFCFA8
highlight StorageClass guifg=#FFCFA8
highlight Structure guifg=#FFCFA8
highlight Typedef guifg=#FFCFA8
highlight Special guifg=#65737E
highlight SpecialChar guifg=#FFC799
highlight Tag guifg=#FFCFA8
highlight Delimiter guifg=#65737E
highlight SpecialComment guifg=#8b8b8b
highlight Debug guifg=#FFCFA8

" Markdown
highlight markdownHeading guifg=#FFCFA8 gui=bold
highlight markdownListMarker guifg=#65737E
highlight markdownBold guifg=#FFFFFF gui=bold
highlight markdownItalic guifg=#FFFFFF gui=italic
highlight markdownUrl guifg=#FFFFFF
highlight markdownLinkText guifg=#FFFFFF
highlight markdownBlockquote guifg=#8b8b8b
highlight markdownCode guifg=#99FFE4

" Diff
highlight DiffAdd guifg=#99FFE4
highlight DiffDelete guifg=#FF8080
highlight DiffChange guifg=#FFCFA8
highlight DiffText guifg=#FFCFA8 guibg=#282828

" Other
highlight Underlined guifg=#FFFFFF gui=underline
highlight Error guifg=#FF8080 guibg=#101010
highlight Todo guifg=#FFC799 guibg=#101010
highlight SpellBad guifg=#FF8080 gui=underline
highlight SpellCap guifg=#FFC799 gui=underline
highlight SpellRare guifg=#99FFE4 gui=underline
highlight SpellLocal guifg=#65737E gui=underline
