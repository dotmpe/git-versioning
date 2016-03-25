Branch Docs
-----------
master
  - Initial development line.

test
  - Tested at Travis CI.


Package contents
----------------

.versioned-files.list
  - A plain text list of paths that have version tags embedded.
  - The first path is the main file, that contains the canonical tags
    used for ``git-versioning update``.

bin/
  cli-version.sh
    - Command-line facade for lib/git-versioning functions.
      Symlinked to ``git-versioning`` in ``$PREFIX/bin/``.

lib/
  formats.sh
    The place for sed-based file rewrite functions.
  git-versioning.sh
    Shell script functions library.
  util.sh
    ..

tools/
  git-hooks/
    pre-commit.sh
      - GIT pre-commit hook  Shell script.
      - Scans main-doc Status field for behaviour. Nothing fancy based on branch
        name or deployment env yet.

    post-commit-old.sh
      - Started out with example, tried to make it into pre-commit hook.

  cmd/
    prep-version.sh
      - Add current GIT branch name as version pre-release tag.
    version-check.sh
      - Default check greps all metadata files to verify versions all match.

package
  .json
    - NPM standard project metadata file.
  .yaml
    - Another currently meaningless project metadata file.

Sitefile.yaml
  - Metadata for documentation browser sitefile_

reader.rst
  - For use with sitefile_

Makefile
  - Some development targets.
    See also configure script and .travis.yml config.


