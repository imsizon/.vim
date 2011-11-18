Overview
========
Vim configuration copied and modified from https://github.com/rainux/.vim.

My .vimrc and plugins, plugins are installed as plugin bundles by [vundle](http://github.com/gmarik/vundle).

View .vimrc for key mappings and vundle.vim for installed plugin bundles.

Installation
============

Linux/Unix/Mac OS X
--------------------

Run the following commands in your terminal with bash/zsh:

    cd
    git clone git://github.com/imsizon/.vim.git
    cd .vim
    git submodule update --init
    cd
    ln -s .vim/.ctags .
    ln -s .vim/.gvimrc .
    ln -s .vim/.vimrc .
    vim
    :BundleInstall

Scripts aquired
---------------

* fromdos
 
    ```bash
    sudo apt-get install tofrodos #ubuntu, debian
    brew install tofrodos #via homebrew on mac os
    ```

* ctags

    ```bash
    sudo apt-get install ctags #ubuntu, debian
    brew install ctags #via homebrew on mac os
    ```

[homebrew](http://mxcl.github.com/homebrew/)


Add scala support to taglist
----------------------------

Edit $VIM_CONFIG_PATH/bundle/taglist.vim/plugin/taglist.vim

    ```vim
    " scala language
    let s:tlist_def_scala_settings = 'scala;t:trait;c:class;T:type;' .
                          \ 'm:method;C:constant;l:local;p:package;o:object'
    ```

after

    ```vim
    " yacc language
    let s:tlist_def_yacc_settings = 'yacc;l:label'
    ```
