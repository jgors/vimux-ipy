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
    """

    ### multiple ways to send code down to tmux split:
    # 1. With %paste from the system clipboard
    # 2. With %cpaste
    # 3. Send raw text with vimux 
    
    # just pick one
    use_paste = 0
    use_cpaste = 1
    use_raw = 0

    r = vim.current.range
    lines = vim.current.buffer[r.start:r.end+1]

    if use_paste:
        lines = "\n".join(lines)
        lines += "\n\n"

        # register might need to be set as * instead of +
        vim.command("let @*='%s'" % (lines.replace("'", "''")))
        vim.command(':call VimuxRunCommand("%paste\n", 0)')

    elif use_cpaste:
        # NOTE doesn't work with sending newline chars (eg. print 'hello \nworld')

        # the code is unindented so the first selected line has 0 indentation,
        # thus can select a statement from inside a function and it will run
        # without indentation being off for python.

        # Count indentation on first selected line
        firstline = vim.current.buffer[r.start]
        nindent = 0
        for i in xrange(0, len(firstline)):
            if firstline[i] == ' ':
                nindent += 1
            else:
                break

        # Shift the whole text by nindent spaces (so the first line has 0 indent)
        if nindent > 0:
            pat = '\s' * nindent
            lines = "\n".join([re.sub('^%s' % pat, '', l) for l in lines])
        else:
            lines = "\n".join(lines)


        # Add empty newline at the end
        lines += "\n\n"

        vim.command(':call VimuxRunCommand("%cpaste\n", 0)')
        vim.command(':call VimuxRunCommand("%s", 0)' % lines)
        vim.command(':call VimuxRunCommand("\n--\n", 0)')

    elif use_raw:
        # NOTE Doesn't work right with indentation

        lines = "\n".join(lines)
        lines += "\n\n"
        vim.command("let @+='%s'" % (lines.replace("'", "''")))
        vim.command(':call VimuxSendText(@+)')

    # Move cursor to the end of the selection
    vim.current.window.cursor=(r.end+1, 0)


def run_cell(save_position=False, cell_delim='####'):
    """
    This is to emulate the iPython Notebook's cell execution style.
    It calls run_visual_code to execute the range of the current cell;
    cells are delimited by the cell_delim arg.  

    The cell_delim arg can be set such that it is the same as what the 
    iPython notebook uses to delimit its code cells (cell_delim='# <codecell>')  
    Thus, if cells are seperated with this, then the script can be uploaded & 
    opened as an iPython notebook, and the iPython NB environment will 
    recognize the delimited cell blocks.  NOTE, in order for this to work, 
    the first thing at the top of the script needs to be: 
    # <nbformat>3</nbformat>

    (http://ipython.org/ipython-doc/stable/interactive/htmlnotebook.html#the-notebook-format)

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

    # this clears the highlighting from the delim search
    vim.command(':noh') 

    if save_position:
        # Restore cursor position
        vim.current.window.cursor = (row, col)

endpython


function! VimuxIpy(...)
    " Create key bindings
    
    " this drops a '# <codecell>' in to denote cell blocks
    nmap <Leader>vc :call Delim()<CR>
    command Delimiter :normal i# <codecell><ESC>
    function! Delim()
        :Delimiter
    endfunction

    " Put key bindings from Vimux plugin here:

    " Inspect tmux pane (jump down into the pane) in vim mode
    map <Leader>vi :VimuxInspectRunner<CR>
    
    " Close vim tmux split opened by VimuxRunCommand
    map <Leader>vx :VimuxCloseRunner<CR>
    
    " Interrupt any command running in the runner pane
    map <Leader>vq :VimuxInterruptRunner<CR>

    " Change pane height
    let g:VimuxHeight = "35"


    " Open a split with ipython by running the function
    
    " this seems hacky to me, but allows to have a defaut function
    " value in vim, so that if nothing is passed into VimuxIpy, then
    " it defaults to opening plain vanilla ipython, however, a string
    " could be passed in and that will open a different invocation of
    " ipython (eg. "ipython --profile=ssh")
    " http://stackoverflow.com/questions/6135404/default-value-of-function-parameter-in-vim-script
    if a:0 > 0
        let how_to_start_ipython = a:1
    else
        let how_to_start_ipython = "ipython"
    end

    let start_split = "clear; " . how_to_start_ipython
    exec VimuxRunCommand(start_split)

endfunction 

