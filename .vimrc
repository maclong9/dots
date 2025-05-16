vim9script

# Basic configuration
autocmd FileType netrw setlocal nu rnu
colorscheme habamax 
g:netrw_banner = 0 
g:netrw_liststyle = 3
set ai noswf nu re=0 rnu sw=2 scl=yes ts=2 
syntax enable

# Set transparent background
autocmd VimEnter,ColorScheme * {
  hi Normal guibg=NONE ctermbg=NONE
  hi NonText guibg=NONE ctermbg=NONE
  hi LineNr guibg=NONE ctermbg=NONE
  hi SignColumn guibg=NONE ctermbg=NONE
  hi VertSplit guibg=NONE ctermbg=NONE
}

# :G for git
command! -nargs=+ G execute "!git" <q-args> 

# Character pairs for surround functionality
var pairs = { 
	'<': '>',
	'"': '"',
	'{': '}',
	'[': ']',
	'(': ')',
	"'": "'",
	'`': '`'
}

# Locate opening and closing pair characters around cursor position
def g:FindPair(open: string, close: string): list<any>
  var cursorPos = getpos('.')
  var searchPattern = escape(open, '[]^$.*')
  if search(searchPattern, 'bW') == 0
    echo "No '" .. open .. "' found before cursor!"
    return [[-1, -1, -1, -1], [-1, -1, -1, -1]]
  endif
  var startPos = getpos('.')
  if open == '"' || open == "'"
    if search(escape(open, '"'), 'W') == 0
      echo "No closing '" .. open .. "' found after cursor!"
      setpos('.', cursorPos)
      return [[-1, -1, -1, -1], [-1, -1, -1, -1]]
    endif
  elseif open == '<'
    if search('>', 'W') == 0
      echo "No closing '>' found after cursor!"
      setpos('.', cursorPos)
      return [[-1, -1, -1, -1], [-1, -1, -1, -1]]
    endif
  else
    normal %
  endif
  var endPos = getpos('.')
  setpos('.', cursorPos)
  return [startPos, endPos]
enddef

# Add surrounding characters to visual selection with optional spacing
def g:AddSurround(char: string, add_spaces: bool = v:true)
  var pair = pairs[char]
  var cursorPos = getpos('.')
  var startPos = getpos("'<")
  var endPos = getpos("'>")
  if startPos[1] == 0 || endPos[1] == 0
    echo "No visual selection found!"
    return
  endif
  var space = add_spaces ? " " : ""
  setpos('.', endPos)
  execute "normal! a" .. space .. pair .. "\<Esc>"
  setpos('.', startPos)
  execute "normal! i" .. char .. space .. "\<Esc>"
  setpos('.', cursorPos)
enddef
command! -nargs=1 AddSurround call g:AddSurround(<f-args>)

# Replace existing surrounding characters with new ones
def g:ChangeSurround(old_open: string, new_open: string, new_close: string)
  var cursorPos = getpos('.')
  var [startPos, endPos] = g:FindPair(old_open, pairs[old_open])
  if startPos[1] == -1
    return
  endif
  setpos('.', endPos)
  execute "normal! r" .. new_close
  setpos('.', startPos)
  execute "normal! r" .. new_open
  setpos('.', cursorPos)
enddef
command! -nargs=+ ChangeSurround call g:ChangeSurround(<f-args>)

# Remove surrounding character pairs
def g:DeleteSurround(open: string)
  var cursorPos = getpos('.')
  var [startPos, endPos] = g:FindPair(open, pairs[open])
  if startPos[1] == -1
    return
  endif
  setpos('.', endPos)
  normal x
  setpos('.', startPos)
  normal x
  setpos('.', cursorPos)
enddef
command! -nargs=1 DeleteSurround call g:DeleteSurround(<f-args>)

# Readline-style keyboard shortcuts for command mode
var readline_mappings = {
  '<C-A>': '<Home>',      # Beginning of line
  '<C-B>': '<Left>',      # Back one character
  '<C-D>': '<Del>',       # Delete character under cursor
  '<C-E>': '<End>',       # End of line
  '<C-F>': '<Right>',     # Forward one character
  '<C-H>': '<BS>',        # Backspace
  '<C-K>': '<C-\>e getcmdpos() == 1 ? "" : getcmdline()[:getcmdpos()-2]<CR>', # Kill to end
  '<C-U>': '<C-U>',       # Delete to beginning
  '<Esc>b': '<C-Left>',   # Back one word
  '<Esc>f': '<C-Right>'   # Forward one word
}
for [key, value] in items(readline_mappings)
  execute "cnoremap " .. key .. " " .. value
endfor

# Quick pane navigation mappings
var direction_keys = ['h', 'j', 'k', 'l']
for key in direction_keys
  execute "nnoremap <C-" .. key .. "> <C-w>" .. key 
endfor

# Surround mappings
var chars = ['<', '"', '{', '[', '(', "'", '`']
for c in chars
  var m = c == '<' ? '<lt>' : c
  var a = c == "'" ? "''" : c
	# Add surround mappings
  execute "vnoremap <silent> a" .. m .. " :<C-u>call g:AddSurround('" .. a .. "')<CR>"
	# Delete surround mappings
  execute "nnoremap <silent> ds" .. m .. " :call g:DeleteSurround('" .. a .. "')<CR>"
  # Change surround mappings
  for n in chars
    var nm = n == '<' ? '<lt>' : n
    var new_open = n == "'" ? "''" : n
    var new_close = pairs[n] == "'" ? "''" : pairs[n]
    execute "nnoremap <silent> cs" .. m .. nm .. " :call g:ChangeSurround('" .. a .. "', '" .. new_open .. "', '" .. new_close .. "')<CR>"
  endfor
endfor

# Comment markers by filetype
g:comment_markers = {
	'vim': '"',
	'vim9': '#',
	'default': '//'
}

# Determine appropriate comment style based on filetype and vim9script detection
def g:GetCommentMarker(): string
  var ft = &filetype
  var marker = g:comment_markers->get(ft, g:comment_markers['default'])

  # Special case for detecting vim9script in vim files
  if ft == 'vim' && getline(1) =~ 'vim9script'
    marker = g:comment_markers['vim9']
  endif

  return marker
enddef

# Toggle comments on current line or selection
def g:ToggleComment()
  var firstline = line(".")
  var lastline = line(".")
  var marker = g:GetCommentMarker()
  var start_pattern = '^[ \t]*' .. escape(marker, '*/[]^$.')

  # Process each line in the range
  for lnum in range(firstline, lastline)
    var line = getline(lnum)
    if line =~ '^\s*$'
      continue # Skip empty lines
    endif

    if line =~ start_pattern
      setline(lnum, substitute(line, start_pattern .. '\s\?', '', '')) # Remove comment
    else
      var indent = matchstr(line, '^\s*')
      setline(lnum, indent .. marker .. ' ' .. substitute(line, '^\s*', '', '')) # Add comment
    endif
  endfor
enddef

# Comment toggling mappings
nnoremap <silent> <leader>c :call g:ToggleComment()<CR> 
xnoremap <silent> <leader>c :call g:ToggleComment()<CR>

var data_dir = has('nvim') ? stdpath('data') .. '/site' : expand('~/.vim')
if empty(glob(data_dir .. '/autoload/plug.vim'))
  silent! execute '!curl -fLo ' .. data_dir .. '/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
