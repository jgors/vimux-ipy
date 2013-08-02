vimux-ipy
=============

This is a vim plugin for added python functionality built on top 
of [vimux](https://github.com/benmills/vimux/); thus, it assumes 
that the vimux plugin is installed as well.  Also, it is adapted 
from [vimux-pyutils](https://github.com/julienr/vimux-pyutils), 
though I add some features & abstract away many details to get 
everything up and running somewhat quicker.


There are two main uses:

+ First, it allows a block of visual-mode selected python code to be 
sent from vim to a tmux buffer split running iPython.  

+ Second, "cells" of code can be sent from vim to the running iPython tmux 
split.  Regarding this use case, the idea here is to be able to have code 
block execution similiar to that found in the iPython Notebook, though 
being able to stay within vim.  Additionally, if the `cell_delim`
arg (explained below) is set such that it is the same as what the iPython 
notebook uses to delimit its code cells, then the script can be uploaded & 
opened as an iPython notebook, and the iPython NB environment will 
recognize the delimited cell blocks.

The workflow for this would be: 

+ start a tmux session, 
+ open desired python script with vim,
+ then execute the command to open the iPython tmux pane split (eg. `Leader vip`),
+ now visually selected code and/or delimited blocks(/cells) of code 
can be sent from the python script in vim to the tmux pane running iPython.



Key mappings
-----------
###### key mappings that are enabled by placing the code into .vimrc:

-----------
##### To open the iPython tmux split [`Leader vip`]: 

`map <Leader>vip :call VimuxIpy()<CR>`

After the iPython tmux split is created, these keybindings are made:

* Jump down into the tmux pane in copy(/vim) mode

`Leader vi`

* Close the vim tmux split

`Leader vq`

* Interrupt any command running in the tmux pane

`Leader ve`

* Insert the same cell block delimiter that iPython uses to seperate their
code blocks in the iPython notebook [`# <codeblock>`]

`Leader vc`

-----------
##### To send & execute visually selected code in the iPython tmux split [`Leader e`]: 

`vmap <silent> <Leader>e :python run_visual_code()<CR>` 

-----------
##### To execute the current "cell" in the iPython tmux split [`Leader c`]: 

`noremap <silent> <Leader>c :python run_cell(save_position=False, cell_delim='####')<CR>` 

Note, a cell is similar to an iPython Notebook code cell and is defined as a code block 
spanning from one `cell_delim` to the next `cell_delim` (explained below).

Two arguments can be passed into `run_cell`:

* `save_position`: [default `False`]

    If set True, then the cursor will stay at the current location after the code cell 
    is executed.  If False, then the cursor will jump ahead to the beginning of
    the next code cell block.

* `cell_delim`: [default `'####'`]

    Code cells are delimited by the `cell_delim` argument -- this specifies what 
    should seperate the code cell blocks.  Note, there should be a `cell_delim` 
    at the beginning of the first code cell, as well as at the end of the last code cell.

    This arg can be set such that it is the same as what the 
    iPython notebook uses to delimit its code cells:  `cell_delim='# <codecell>'`  
    Meaning, if cells are seperated with this as the cell_delim, then the script can 
    be uploaded & opened as an iPython notebook, and the iPython NB environment will 
    recognize the delimited code cell blocks -- NOTE, in order to be able to upload 
    a script delimited in this way to the iPython notebook environment, the first 
    thing at the very top of the script needs to be: 
    `# <nbformat>3</nbformat>`

    for more details see:
    
    [ipython notebook format stable](http://ipython.org/ipython-doc/stable/interactive/htmlnotebook.html#the-notebook-format)

    [ipython notebook format dev](http://ipython.org/ipython-doc/dev/interactive/htmlnotebook.html#notebook-json-file-format)
