package main // import "github.com/bvberkum/git-versioning"

import (
  "fmt"
  "os"
  "os/exec"
  "strings"

  "github.com/docopt/docopt-go"
  "github.com/Masterminds/semver"
  "github.com/BurntSushi/toml"
)

var ns_name = "bvberkum"
var app_id = "git-versioning"
var version = "0.3.0-dev" // git-versioning

type Conf struct {
  Main_Doc string
  Update_Mode string
	Version string
}

func main() {
	ret := main_exec()
	os.Exit(ret)
}

func main_exec() (int) {
  var (
    ret int
    cfn string
    cf Conf
    v *semver.Version
  )
  usage := `Manage embedded versions and other types of source-code stamping.

Usage:
  git-versioning [options] init
  git-versioning [options] version
  git-versioning [options] check
  git-versioning [options] update

Options:
  -c, --config CONFIG
                [default: .gitver.toml]
  -h --help     Show this screen.
  --version     Show version.

Commands;
  init
  version
  check
  update
`
  version_str := fmt.Sprintf("%s %s", app_id, version)
  opts, _ := docopt.Parse(usage, nil, true, version_str, false)

	ret, _, _ = chkgitgconf()
	//ret, clean_fltr, smudge_fltr := chkgitgconf()
  //fmt.Println("Clean filter:", clean_fltr)
  //fmt.Println("Smudge filter:", smudge_fltr)
	if ret != 0 { return ret }

	ret = chgitdir()
	if ret != 0 { return ret }

  cfn = opts["--config"].(string)
	if _, err := toml.DecodeFile(cfn, &cf); err != nil {
		fmt.Println(err)
		return 1
	}

	v, err := semver.NewVersion(cf.Version)
	if err != nil {
		fmt.Println(err)
		return 1
  }

	if opts["version"].(bool) {
		fmt.Println(cf.Version)
		return 0

	} else if opts["init"].(bool) {
		ret = cmd_init(opts)

	} else if opts["check"].(bool) {
		ret = cmd_check(cf, v, opts)

	} else if opts["update"].(bool) {
		ret = cmd_update(opts)

	}
	return ret
}

func cmd_init(opts map[string]interface{}) (int) {

	return 0
}

func cmd_check(cf Conf, v *semver.Version, opts map[string]interface{}) (int) {
  var (
    gitver *semver.Version
    ret int
  )
	ret, gitver = gitflowver()
	if ret != 0 { return ret }

  // NOTE: somewhat counterintuitively, this fails v with a meta tag
  c, err := semver.NewConstraint(fmt.Sprintf(">= %s", gitver))
  if err != nil { return 1 }
  if c.Check(v) {
    return 0

  } else {
    fmt.Printf(
      "Expected project version to be equal or greater than last tag: %s vs. %s\n",
      v, gitver)
    return 1
  }
}

func cmd_update(opts map[string]interface{}) (int) {
	return 0
}

func git_exists() (string, error) {
	out, err := exec.Command("git","rev-parse","--show-toplevel").Output()
	if err != nil {
		return "", err
	} else {
		return fmt.Sprintf("%s", out), nil
	}
}

func chgitdir() (int) {
	rootdir, err :=	git_exists()
	if err != nil {
		fmt.Printf("Expected a GIT checkout (rev-parse --show-toplevel %s)", err)
    return 1
	}

	//fmt.Printf("Found GIT at %s", rootdir)
	os.Chdir(rootdir)
	return 0
}

func chkgitgconf() (int, string, string) {

	out, err := exec.Command("git","config","--global","filter.gitver.clean").Output()
	if err != nil { return 1, "", "" }
  clean := strings.Trim( fmt.Sprintf( "%s", out ), "\n\t " )

	out, err = exec.Command("git","config","--global","filter.gitver.smudge").Output()
	if err != nil { return 1, "", "" }
  smudge := strings.Trim( fmt.Sprintf( "%s", out ), "\n\t " )

	return 0, clean, smudge
}

func gitflowver() (int, *semver.Version) {
	out, err := exec.Command("git","describe").Output()
	if err != nil { return 1, nil }

  gitver := strings.Split( strings.Trim( fmt.Sprintf( "%s", out ), "\n\t " ), "-")[0]
	ver, err := semver.NewVersion(gitver)
	if err != nil {
		fmt.Println(err)
		return 1, nil
  }

  return 0, ver
}
