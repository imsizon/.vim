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
