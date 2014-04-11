#!/usr/bin/make -f
#
#  gneay-plugin.mk - Simple and portable Makefile for standalone Geany plugins.
#
#  Copyright 2014 Colomban Wendling <colomban@geany.org>
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#


# plugin-specific information
#PLUGIN = yourplugin
PLUGIN_SOURCES    ?= $(PLUGIN).c
PLUGIN_PACKAGES   ?=
PLUGIN_CFLAGS     ?=
PLUGIN_LDFLAGS    ?=

# path to sources
VPATH             ?= .

# tools
CC                ?= cc
RM                ?= rm -f
RMDIR             ?= rmdir
MKDIR_P           ?= mkdir -p
INSTALL           ?= install
LIBTOOL           ?= libtool
PKG_CONFIG        ?= pkg-config

# libtool aliases
LIBTOOL_CC        ?= $(LIBTOOL) $(LIBTOOLFLAGS) --tag=CC --mode=compile $(CC) \
                     -shared
LIBTOOL_LD        ?= $(LIBTOOL) $(LIBTOOLFLAGS) --tag=CC --mode=link $(CC) \
                     -shared -module -avoid-version -rpath $(plugindir)
LIBTOOL_CLEAN     ?= $(LIBTOOL) $(LIBTOOLFLAGS) --mode=clean $(RM)
LIBTOOL_INSTALL   ?= $(LIBTOOL) $(LIBTOOLFLAGS) --mode=install $(INSTALL)
LIBTOOL_UNINSTALL ?= $(LIBTOOL) $(LIBTOOLFLAGS) --mode=uninstall $(RM)

# flags from packages, including Geany
PACKAGES_CFLAGS   ?= `$(PKG_CONFIG) $(PLUGIN_PACKAGES) geany --cflags`
PACKAGES_LIBS     ?= `$(PKG_CONFIG) $(PLUGIN_PACKAGES) geany --libs`

# installation directory
plugindir         ?= `$(PKG_CONFIG) geany --variable=libdir`/geany

# dependency generation CFLAGS
DEPSDIR            = .deps
DEPFILES           = $(PLUGIN_SOURCES:%.c=$(DEPSDIR)/%.lo.Po)
CC_DEPS_CFLAGS    ?= -MT $@ -MP -MD -MF $(DEPSDIR)/$@.Po

# rules
all:
clean:
distclean: clean
install:
uninstall:

.SUFFIXES: .c .lo
.PHONY: all clean distclean install uninstall

.c.lo:
	test -d $(DEPSDIR) || $(MKDIR_P) $(DEPSDIR)
	$(LIBTOOL_CC) -c $< -o $@ $(CC_DEPS_CFLAGS) \
		$(PACKAGES_CFLAGS) $(PLUGIN_CFLAGS) $(CPPFLAGS) $(CFLAGS)

all: $(PLUGIN).la
install: install-$(PLUGIN) install-$(PLUGIN)-local
uninstall: uninstall-$(PLUGIN) uninstall-$(PLUGIN)-local
clean: clean-$(PLUGIN) clean-$(PLUGIN)-local
distclean: distclean-$(PLUGIN) distclean-$(PLUGIN)-local

$(PLUGIN).la: $(PLUGIN_SOURCES:.c=.lo)
	$(LIBTOOL_LD) -o $@ $(PLUGIN_SOURCES:.c=.lo) \
		$(PACKAGES_LIBS) $(PLUGIN_LDFLAGS) $(LIBS) $(LDFLAGS)

install-$(PLUGIN)-local:
install-$(PLUGIN): $(PLUGIN).la
	$(MKDIR_P) $(DESTDIR)$(plugindir)
	$(LIBTOOL_INSTALL) ./$(PLUGIN).la $(DESTDIR)$(plugindir)

uninstall-$(PLUGIN)-local:
uninstall-$(PLUGIN):
	$(LIBTOOL_UNINSTALL) $(DESTDIR)$(plugindir)/$(PLUGIN).la
	$(RMDIR) $(DESTDIR)$(plugindir) >/dev/null 2>&1 || :

clean-$(PLUGIN)-local:
clean-$(PLUGIN):
	$(LIBTOOL_CLEAN) $(PLUGIN).o $(PLUGIN).lo
	$(RM) $(DEPFILES)
	$(RMDIR) $(DEPSDIR) >/dev/null 2>&1 || :

distclean-$(PLUGIN)-local:
distclean-$(PLUGIN):
	$(LIBTOOL_CLEAN) $(PLUGIN).la

# include auto-generated dependency files
-include $(DEPFILES)
