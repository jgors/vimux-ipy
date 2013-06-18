if !has('python')
  echo "Error: Requires vim compiled with +python"
  finish
endif

python << endpython
import vim
import re


def run_visual_code():
    """
    copy & paste the currently selected code into the tmux split.
    the code is unindented so the first selected line has 0 indentation,
    thus can select a statement from inside a function and it will run
    without indentation being off for python.
    """

    r = vim.current.range
    # Count indentation on first selected line
    firstline = vim.current.buffer[r.start]
    nindent = 0
    for i in xrange(0, len(firstline)):
        if firstline[i] == ' ':
            nindent += 1
        else:
            break

    # Shift the whole text by nindent spaces (so the first line has 0 indent)
    lines = vim.current.buffer[r.start:r.end+1]
    if nindent > 0:
        pat = '\s' * nindent
        lines = "\n".join([re.sub('^%s' % pat, '', l) for l in lines])
    else:
        lines = "\n".join(lines)

    # Add empty newline at the end
    lines += "\n\n"

    # multiple solutions to copy that to tmux

    # 1. With %cpaste
    vim.command(':call VimuxRunCommand("%cpaste\n", 0)')
    vim.command(':call VimuxRunCommand("%s", 0)' % lines)
    vim.command(':call VimuxRunCommand("\n--\n", 0)')


    # 2. With %paste from the system clipboard
    #try:
        #set_register('+', lines)
        #set_register('*', lines)
    #except vim.error:
        #pass
    #vim.command(':call VimuxRunCommand("%paste\n", 0)')


    # 3. Directly send the raw text with vimux. 


    # Move cursor to the end of the selection
    vim.current.window.cursor=(r.end+1, 0)


def run_cell(save_position=False, cell_delim='####'):
    """
    This is to emulate the iPython Notebook's cell execution style.
    This calls run_visual_code to execute the range of the current cell.
    Cells are delimited by the cell_delim arg. 

    The :?%s?;/%s/ part creates a range by:
    ?%s? searches backwards for the cell_delim,
    then the ';' starts the range from the result of the 
    previous search (cell_delim) to the end of the 
    range at /%s/ (the next cell_delim).
    """
    
    if save_position:
        # Save cursor position
        (row, col) = vim.current.window.cursor

    # Run chunk on cell range
    vim.command(':?%s?;/%s/ :python run_visual_code()' % (cell_delim, cell_delim))

    if save_position:
        # Restore cursor position
        vim.current.window.cursor = (row, col)

endpython


function! VimuxIpy()
    " Put key bindings from Vimux plugin here:

    " Inspect tmux pane (jump down into the pane) in vim mode
    map <Leader>vi :VimuxInspectRunner<CR>
    
    " Close vim tmux split opened by VimuxRunCommand
    map <Leader>vq :VimuxCloseRunner<CR>
    
    " Interrupt any command running in the runner pane
    map <Leader>ve :VimuxInterruptRunner<CR>

    " Change pane height
    let g:VimuxHeight = "35"

    " Open a split with ipython by running the function
    exec VimuxRunCommand("clear; ipython --pylab")

endfunction 

