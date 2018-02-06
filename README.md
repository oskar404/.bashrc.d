
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
`bashrc` configuration files into home directory as `.bashrc` and symlink the
`gitconfig` to home as `.gitconfig`. Just to be safe make backup copies of
your previous config files.

    $ git clone git@github.com:oskar404/.bashrc.d.git ~/.bashrc.d
    $ ln -s ~/.bashrc.d/bashrc ~/.bashrc
    $ ln -s ~/.bashrc.d/gitconfig ~/.gitconfig

The `bashrc` example sources all `~/.bashrc.d/*.conf` files found. The `bashrc`
is self-contained so it can be simply copied as local file and modified.

The `gitconfig` sources `~/.bashrc.d/gitconfig.user` file. Add your user
information into file. See example below.

    [user]
        email = user.name@example.com
        name = User Name


Usage
-----

To see what the `bashrc` does there are two quick command which will list the
utilities availble in the environment:

    alias

which lists the available aliases and

    declare -F | grep -v "declare -f _"

which lists the declared functions in the environment.
