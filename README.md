## obs-scm-autoupdater

An automatic/bunch update program for packages with scm \_service files on [openSUSE Build Service](https://build.opensuse.org) in Ruby.

Now you can update many packages at once on your local machine.

## System Requirement

* ruby
* `osc` package, which is the CLI client for the build service (with Username/Password configured already)
* your aimed packages have to have a \_service file with certain limitations

## \_service file limitations

Generally, openSUSE Factory doesn't allow for service files that will be ran on server side.

So your \_service files have to be in `disabled` or `localonly` mode. (currently only `disabled` is implemented)

And your \_service file have to a _scm_ service free of errors (it means you have to run the service manually at least once with the command `osc service disabledrun` to see if it works), which means git/svn service.

## Status

* run the service inside package directory.

## TODO

* run the service inside repository directory, for all the sub-directories.
* repository directory with sub-directory exceptions.
* automatically fetch the repository too.

## LICENSE

MIT
