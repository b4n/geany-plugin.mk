# geany-plugin.mk

`geany-plugin.mk` provides (experimental) easy Make support for
building standalone Geany plugins.  This does not aim at being as
powerful as can be "real" build systems like Autotools, CMake or others,
but intent to be simple, powerful enough and very easy to setup.

One particular thing it intentionally  doesn't support is the
environment detection and configuration step.  This is left to the
user, as a set of overrideable tools and flags.

On the other hand, the simplest setup only requires setting one single
variable.

## About `geany-plugin.mk`

### Default dependencies

`geany-plugin.mk` uses
[Libtool](https://www.gnu.org/software/libtool/libtool.html) and
[pkg-config](http://www.freedesktop.org/wiki/Software/pkg-config/) by
default, and although it is possible to avoid using them, it requires
non-trivial overrides.

Libtool is especially hard to avoid, because building a shared library
dynamically loadable by an application can be vastly different depending
on the OS, or even the target architecture.

### Portability

The Makefile itself should be fairly portable around Make
implementations, and has been tested with GNU and BSD Makes.

The default setup should also be fairly portable around Unices, but has
yet to be tested on non-Linux platforms.


## Usage as a developer

To use `geany-plugin.mk`, the only absolutely required thing is to set
the `PLUGIN` Make variable to the name of the plugin to build. It will
be the name of the plugin library file, with the library extension
appended.

You may also want to override the following:

`PLUGIN_SOURCES`
: the list of the plugin's source files (which defaults to
  `$(PLUGIN).c` for convenience);
`PLUGIN_PACKAGES`
: the list of *pkg-config* packages the plugin requires (but note that
  Geany's package is always included, and you don't need to list it);
`PLUGIN_CFLAGS`
: the additional C compiler flags for the plugin;
`PLUGIN_LDFLAGS`
: the additional linker flags for the plugin.

Please note that the plugin-specific flags should only contain the
required flags, like constants definition, but no user flags.  E.g.,
please restrain from adding warning flags or alike -- instead set
`CFLAGS` or `LDFLAGS` in your environment or when calling Make.

Each plugin-specific targets (`install-$(PLUGIN)`, `uninstall-$(PLUGIN)`,
`clean-$(PLUGIN)` and `distclean-$(PLUGIN)`) has a `-local` version that
you can use to hook custom code to these operations if needed.

Although you can set all these on the Make command line, or by editing
a copy of `geany-plugin.mk`, it is strongly recommended to define them
in a Makefile from which you source `geany-plugin.mk`


### Example Makefile

```Makefile
PLUGIN          := my-plugin
PLUGIN_SOURCES  := my-plugin-file1.c my-plugin-file2.c
PLUGIN_PACKAGES := gtk+-2.0

# this is required to support VPATH building.  If you don't care about
# this and don't feel like you understand it, you can remove it and not
# use it in the include below.
VPATH ?= .

# source geany-plugin.mk
include $(VPATH)/geany-plugin.mk
```


## Usage as an end user

In addition to the developer-specific variables, a user calling a
`geany-plugin.mk`-based Makefile can override several variables to
fine-tune the behavior.

Installation destination can be overridden, as well as being prefixed.
`geany-plugin.mk` honors the `DESTDIR` variable, which will be used as
the root directory where to install files.  Additionally, the
`plugindir` variable that defines the target directory for installation
can be overridden, and defaults to Geany's plugin directory (as
reported by *pkg-config*).

Most tools and flags can be overridden, and will honor the values from
the environment.  Tools are:

CC
: C compiler, defaults to `cc`;
RM
: removes files, defaults to `rm -f`;
RMDIR
: removes empty directories, defaults to `rmdir`;
MKDIR_P
: creates directories recursively, defaults to `mkdir -p`;
INSTALL
: installs files, defaults to `install`;
LIBTOOL
: builds libraries, defaults to `libtool`;
PKG_CONFIG
: manages package flags, defaults to `pkg-config`.

Although Libtool is supposed to be used, and then overriding the
following should not be useful, the caller can also override some
task-specific Libtool calls: `LIBTOOL_CC`, `LIBTOOL_LD`,
`LIBTOOL_CLEAN`, `LIBTOOL_INSTALL` and `LIBTOOL_UNINSTALL`. Note
however that as the default for those respects the various tools above,
one should never have to override them unless one tries to avoid using
libtool.

Used flags include `CFLAGS`, `CPPFLAGS`, `LDFLAGS` and `LIBTOOLFLAGS`.

There are also the special `PACKAGES_CFLAGS` and `PACKAGES_LIBS` that
should contain flags required by all packages used by the plugin. These
default to the result of `$(PKG_CONFIG) --cflags` and `$(PKG_CONFIG)
--libs` respectively, on all `$(PLUGIN_PACKAGES)` packages and the
"geany" package. Manually overriding those should be seldom necessary,
unless *pkg-config* reports erroneous flags.

The special `CC_DEPS_CFLAGS` are flags passed to the compiler to
generate Makefile dependencies in `$(DEPSDIR)/$@.Po`.  The default
value uses GCC syntax for it; but if your compiler doesn't support it
you can set it either to a blank value (which will obviously disable
automatic dependencies) or to whatever flags your compiler has for this
purpose.

Finally, out-of-tree ("VPATH") builds are supported using the `VPATH`
variable, on Make implementations that support it, and if the
developer-specific Makefile does.  This variable should point to the
directory containing the sources.


## Appendix

### License

    Copyright 2014 Colomban Wendling <colomban@geany.org>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
