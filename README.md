####Installation

```
git clone https://github.com/fieldville/dotvim.git ~/.vim
```

#####Create symlinks

```
ln -s ~/.vim/vimrc ~/.vimrc
ln -s ~/.vim/gvimrc ~/.gvimrc
```

#####Set up NeoBundle

```
mkdir -p ~/.vim/bundle
git clone https://github.com/Shougo/neobundle.vim  ~/.vim/bundle/neobundle.vim
```

then launch vim, run `:NeoBundleInstall`
