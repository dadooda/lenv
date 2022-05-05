
Lenv
====

Load location-based shell environment ehnancements

## Overview

While developing it's often desirable to have a number of shell ehnancements at hand. Lenv allows to load, edit and reuse such shell enhancements.

## Setup

1. Fetch `lenv.sh`:

        $ curl -O https://raw.githubusercontent.com/dadooda/lenv/main/lenv.sh

2. Source `lenv.sh` in your interactive shell profile (e.g. `~/.bashrc`).

## Usage

1. Create a directory `<project>_support/` on the same level as your project directory.
2. Edit the file `env.sh` in `<project>_support/`. Put your shell enhancements there.
3. While in `<project>/` or deeper, run `lenv` any time to load your shell enhancements.

## Example

Suppose your current extraordinary project is called "Gobbledy" and lives in `~/work/gobbledy/`.  
Suppose Lenv is already set up.

1. Step into your project directory:

        $ cd ~/work/gobbledy

2. Create support directory:

        $ mkdir ../gobbledy_support

3. Edit shell enhancements:

        $ lenvedit

After the editor exits, the enhancements are going to be loaded straight away.

Next time, loading the shell enhancements is as easy is:

```
$ cd ~/work/gobbledy
$ lenv
```

## Miscellaneous

### Shared support directories

Directory named `_support/` will act as a shared support directory for all project directories residing at the same level with it.

## Cheers!

The product is free to use by everyone. Feedback of any kind is greatly appreciated.  
&mdash; Alex Fortuna, &copy; 2022
