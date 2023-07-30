Install ::

  $ make install
  $ make uninstall

or diretly using ``install.sh``. Uninstall is only needed to remove existing... ::

  ENV_NAME=production ./configure.sh ~/.local
  ./install.sh uninstall
  ./install.sh install

  ENV_NAME=production ./configure.sh /usr/local
  sudo ./install.sh uninstall
  sudo ./install.sh install

See also Travis CI test build script.


Options per project (config file relative to project root):

1. A simple ``.versioned-files.list`` file, starting with the main-document and followed
   by other files. Example initalization::

      cd myproject
      echo my-project > .app-id
      echo :Version: 0.0.1  > ReadMe.rst
      echo "# Id: my-project" > test.sh
      echo 'version=0.0.1 # my-project' >> test.sh
      echo -e '{\n"version":"0.0.1"\n}' > package.json
      echo ReadMe.rst > .versioned-files.list
      echo package.json >> .versioned-files.lst
      echo test.sh >> .versioned-files.lst


2. Or/and in addition, ``.properties`` to customize main-document, list-file, and other
   settings::

      App-Id: git-versioning
      # Version:
      Main-File: ReadMe.rst
      # Formats: /src/github.com/bvberkum/git-versioning/lib/formats.sh
      # Local-Formats: local-formats.sh
      # File-List: .versioned-files.list
      # Other-Files:

3. and as as last resort file ``.app-id`` if
   the current directory/GIT remote are not anough to determine the App ID and version, documents. And none of the other are provided. TODO: ``.htd/app-id`` etc. Some of the metadata is shared with other tooling.


Commands for pre-merge/commit/push, and before/after development,testing or
other build stages:

::

  git-versioning check # verify all versions match

  git-versioning dev # apply dev tag
  git-versioning snapshot # apply feature tag
  git-versioning update # rewrite embedded versions
  git-versioning check


Syntax
------
For clike or hash-comment languages::

  # Id: app-id/0.0.0 path/filename.ext
  # version: 0.0.0 app-id path/filename.ext

And while the exact format differs variables follow the pattern::

  version = 0.0.0 # app-id

For some files exceptions are made. Refer to test/example files for syntax
per format.

The trailing sentinel comment is for additional modes. It should
have the app-id to avoid any ambiguity with other apps.

Exact specs of variable rewrites may differ per format since its not always
possible to include a comment on the line (ie. JSON).

rSt example::

  .. Id: git-versioning/0.2.0-dev ReadMe.rst

Sentinel syntax
_______________
The syntax for Id lines overlaps with other uses of comments in source and
documents alike for preprocessing, static analysis etc.

The exact syntax shall be spec'ed in a Users-scripts derived project and git-versioning to adapt.
::

   <comment-prefix>: <directive-id>: <directive-parts> <modeline-rest>

Experimentation with these is ongoing, these common signatures are evolving:

# <directive>: <app-id/app-version> <local-name> <param/modes...>
# <directive>: <other>:<other-local-name>
# <directive>: <app-id/app-version> <other>:<other-local-name>

All three could have rest part with eiter params or editor mode-line part,
depending on its place of use in the file. ID-directive lines near file head or tail are one obvious choice to place editor mode-lines on as well.

..

   TODO: update comment regexes and list supported somewwere `\/\/|..|--|;|comment|rem|::|"|#`

Pathnames vs. locators and IDs
_______________________________
Possible variations?::

  .. Id: <git-versioning/0.2.0-dev> ReadMe.rst
  .. Id: git-versioning/0.2.0-dev "ReadMe.rst"

But quoting ie. in literal content does not seem that applicable.
Angle brackets shall be used to designate special lookups, but in the
URL/special protocol sense. Regular local names are unquoted.

Another issue is long paths and locators, and special ID vs. references in
general. git-versioning shall ride along with parts of customized todo.txt syntax
with Users-scripts project where wanted.


Use cases
---------

1. files get distributed, and need to be matched to source repository easily
2. file need access to the project's version (ie. compiled program source code)
   and such versions need to be updated.

Issues
------

Only the first match in a version is considered. This for me is a minor issue,
one I may get to fix later. However, more important to me are some
considerations with regard to source code versioning.

Without deployment, embedding version strings as file Id's always adds a change.
SCM systems may not have facilities to ignore lines, and anyway looking at such
changeset is not informative at all.

In my opinion

1. changes to versions should be left out of the source code and out of version
   history as much as possible. I think it would be more appropiate to use a
   placeholder that does not change (as much).

2. when committing a release, the commit may be left out of the default SCM
   version. On a seperate branch or even without any branch only a commit.
   Such version could even have a tag to distinguish it from a related version
   tagged onto the default or main-line branch. This way versions appear on the
   main line too, which helps to navigate the repository.

That said, having the project version embedded makes some sense to me, and
having another script to help with copies has some place. For compiled projects,
it can be more convienient to copy the version rather than add the overhead to
retrieve them during the build process. For documentation it may not be pretty
or informative to look at a placeholder. And a build system with documentation
distribution is not feasible for every project, some may want to try to get as
much from the SCM system instead, including serving documentation.

More on current issues in `dev doc <./dev.rst>`_.
