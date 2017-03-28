
Change Log
----------
(0.0.1)
  :date: Sun Apr 19. 2015

  Initial checkin.

0.0.30
  :date: Mon Mar 21. 2016

  - Start keeping changelog.

    Currently supports literal paths in .versioned-files.list,
    one main document in properties or reStructuredText format.
    And just a handful of source documents: Shell script, Makefile, Javascript,
    YAML, JSON, Coffee-Script, Ant build XML.
    Any format supporting c-style line comments or unix octotrophe comments,
    but needs to be hardcoded.

    Immediate dev plans: clean-up docs, start on branches for better
    configuration, more flexible parser.

0.0.31
  :date: Tue Apr 12. 2016

  - Renamed test ``git-versioning`` to ``git-versioning-spec`` to follow name
    convention.
  - Documentation restructured. Fixes, updates.
    Added reference to project GitVersion.
  - Removed ``V_PATH_LIST``. Started read_nix_style_file.
  - Added modus without ``versioned-files.list`` (and main document with version).
    ``VER_STR`` must be provided in the environment, the files to be checked are
    read from standard-input.

    For example to go without ``.app-id`` and ``.versioned-files.list`` or main
    document::

      cat my-file.list | APP_ID=myproject VER_STR=1.2.3-alpha git-versioning check

    For this the parameters of the ``V_CHECK`` script (``tools/cmd/version-check.sh``)
    have been changed and are incompatible with previous.

  - Proper production release failed, see next version.

0.0.32
  :date: Tue Apr 12. 2016

  - Testing packaging with Travis.

0.1.0
  :date: Tue Apr 12. 2016

  - Incrementing minor because of V_CHECK change. And running production package
    release again just for the heck of it.

0.1.1
  :date: Sun Sep 18. 2016

  - Minor bits for apply version.
    Added .py support for version and __version__ attributes.

0.1.3
  :date: Sun Sep 18. 2016

  - Fixed `load()` and sub-cmd `check` to read `.versioned-files.list`
    (``V_MAIN_DOC``) as a \*nix alike file.
  - Fixes for `make do-release`.

(0.1.4)
  - New formats: XML, C (and c++ and header files), Dockerfile, Java, and
    Groovy. (Comment support only)
  - Renamed `jade` to `pug`.
  - Updates for sh tooling and Travis build. Travis build was not properly
    testing production env, or failing b/c sudo error. Re-added sudo and fixed
    build script.
  - No longer using ``ENV`` for environment name, changed to ``ENV_NAME``.

