
The Bash Environment: .bashrc.d/
================================

This is a collection of bash configurations which makes my terminal life
enjoyable.

Motivation
----------

When having multiple desktops and laptops the maintenance of the terminal gets
tedious. The target for this is to have the same environment available for all
the computers.

This configuration collection might be usefull for other bash users also.

Installation
------------

To install simply clone the repo into `~/.bashrc.d` directory and copy the
example main configuration files into home directory. Make a backup copy of
your previous configurations before taking these new files into use.

```bash
$ git clone git@github.com:oskar404/.bashrc.d.git ~/.bashrc.d
$ cp -i ~/.bashrc.d/bashrc.main ~/.bashrc
$ cp -i ~/.bashrc.d/gitconfig.main ~/.gitconfig
```

Or you can manually edit your current configurations to point to bashrc.d files.
See examples how to edit your files in `bashrc.main` and `gitconfig.main`. If
you copied the sample git main configuration file to `~/.gitconfig` make sure
you edit the personal data to be correct.

If you are working with Mac OSX copy the `bashrc.main` as `~/.profile`
