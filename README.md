
The Bash Environment: .bashrc.d/
================================

This is a collection of bash configurations which makes terminal life enjoyable.

Motivation
----------

When having multiple desktops and laptops the maintenance of the terminal
environments gets tedious. The target for this is to have the same/similar
environment available for all the computers.

This configuration collection might be usefull for other bash users also. Note
these configurations are tested only in few Ubuntu systems, so functionality
might vary. Contents of the setup is personal preference.

Installation
------------

Minimal prerequisites are Posix utilities and git and bash-completion packages.
In Ubuntu you can always install a meta-package build-essential. To install
minimal requirements:

    $ sudo apt install git bash-completion python3

To install simply clone the repo into `~/.bashrc.d` directory and symlink the
`bashrc` configuration files into home directory as `.bashrc` and symlink the
`gitconfig` to home as `.gitconfig`. Just to be safe make backup copies of
your previous config files.

    $ git clone git@github.com:oskar404/.bashrc.d.git ~/.bashrc.d
    $ ln -s ~/.bashrc.d/bashrc ~/.bashrc
    $ ln -s ~/.bashrc.d/gitconfig ~/.gitconfig

The `bashrc` file sources all `~/.bashrc.d/*.conf` configuration files.

The `gitconfig` sources `~/.bashrc.d/gitconfig.user` file. Add your user
information into file. See example below.

    [user]
        email = user.name@example.com
        name = User Name

Individual commands might need some additional packages. See the comments and
code for the aliases, functions etc. for more information.

Usage
-----

To see what the `bashrc` contains there is a `howto` command which lists the
functions and aliases:

    howto

To add own local help and notes the `howto.txt` file can be edited:

    howto -e

