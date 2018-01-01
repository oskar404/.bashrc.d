
The Bash Environment: .bashrc.d/
================================

This is a collection of bash configurations which makes my terminal life
enjoyable.

Motivation
----------

When having multiple desktops and laptops the maintenance of the terminal
environments gets tedious. The target for this is to have the same/similar
environment available for all the computers.

This configuration collection might be usefull for other bash users also.

Installation
------------

To install simply clone the repo into `~/.bashrc.d` directory and symlink the
`bashrc` configuration files into home directory as `.bashrc` and copy the
`gitconfig.main` to home as `.gitconfig`. Just to be safe make backup copies of
your previous config files.

```bash
$ git clone git@github.com:oskar404/.bashrc.d.git ~/.bashrc.d
$ ln -s ~/.bashrc.d/bashrc ~/.bashrc
$ cp -i ~/.bashrc.d/gitconfig.main ~/.gitconfig
```

