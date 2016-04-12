
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

(0.0.31)
  - Renamed test git-versioning to git-versioning-spec
  - Documentation restructured. Fixes, updates.
    Added reference to project GitVersion.
  - Removed V_PATH_LIST. Started read_nix_style_file.
  - Added modus without versioned-files.list (and main document with version).
    VER_STR must be provided in the environment, the files to be checked are
    read from standard-input::

      VER_STR=1.2.3-alpha git-versioning check

