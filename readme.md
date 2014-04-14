# libsass compatible bourbon

The latest release bourbon (4.0.0) relies on features of sass v3.3. See:
  * https://github.com/thoughtbot/bourbon/issues/375
  * https://github.com/andrew/node-sass/issues/273

Unfortunately, libsass isn't going to support this for a while - they are
aiming for sass v3.2 feature parity before adding in v3.3 features.

This is a fork of 3.2.0-beta.2, which is the last version of bourbon that
doesn't rely on too much of 3.3's featureset. The only thing I had to remove
is global variable declarations. See here:
  * https://github.com/thoughtbot/bourbon/issues/366

This version currently works with the version of libsass that node-sass links
to (because that's where I'm using it.) As of April 14, 2014, this is only
a few commits behind master:
  * https://github.com/hcatlin/libsass/tree/1122ead208a8d1c438daaca70041ef6dd2361fa0

Please open issues or pull requests for any other issues you notice that stop
bourbon from working with libsass' master.

See [Bourbon's repo](https://github.com/thoughtbot/bourbon) and
[docs](http://bourbon.io) for more info on bourbon itself.
