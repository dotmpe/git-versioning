
Change Log
----------

0.0.30
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
  - Testing packaging with Travis.

