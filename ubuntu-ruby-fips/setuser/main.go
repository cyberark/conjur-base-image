// main contains the whole setuser utility.
package main

import (
	"crypto/fips140"
	"fmt"
	"log"
	"os"
	"os/exec"
	"os/user"
	"slices"
	"strconv"
	"syscall"
)

// allowedCommands is the list of allowed commands, this is a set of commands that are used in normal operations by the
// appliance. Even if setuser does not allow to elevate user privilidges, we do not want setuser to be used with any
// command since that could be used by the attackers to hide their activities.
var allowedCommands = []string{"pg_ctl", "pg_dump", "pg_dumpall", "psql", "createuser", "pg_ctlcluster", "true"}

// logFatal is the log.Fatal function needed to be mocked for testing.
var logFatal = log.Fatal

// main runs the given command as the given user.
func main() {
	if !fips140.Enabled() {
		log.Print("WARN: Compliance with FIPS 140-3 is not enabled")
	}

	if len(os.Args) < 3 {
		logFatal(help())
	}
	u, err := user.Lookup(os.Args[1])
	if err != nil {
		logFatal(err)
	}
	uid, err := strconv.ParseInt(u.Uid, 10, 32)
	gid, err := strconv.ParseInt(u.Gid, 10, 32)
	command := os.Args[2]
	if !slices.Contains(allowedCommands, command) {
		logFatal(
			fmt.Errorf(
				"command %s not allowed, allowed commands are %v",
				os.Args[2],
				allowedCommands,
			),
		)
	}
	// file deepcode ignore CommandInjection: This is by design. This tool allows to change the user for execution of following command.
	// The input is sanitized above, and only few limited commands are allowed to be passed.
	cmd := exec.Command(command, os.Args[3:]...)
	cmd.SysProcAttr = &syscall.SysProcAttr{
		Credential: &syscall.Credential{Uid: uint32(uid), Gid: uint32(gid)},
	}
	cmd.Env = append(
		os.Environ(),
		fmt.Sprintf("USER=%s", u.Username),
		fmt.Sprintf("UID=%s", u.Uid),
		fmt.Sprintf("HOME=%s", u.HomeDir),
	)
	cmd.Stdout, cmd.Stderr = os.Stdout, os.Stderr
	if isTerminal(os.Stdin) {
		cmd.Stdin = os.Stdin
	}
	if err = cmd.Run(); err != nil {
		logFatal(err)
	}
}

// isTerminal returns true if the given file is attr terminal.
func isTerminal(stdin *os.File) bool {
	fi, err := stdin.Stat()
	if err != nil {
		return false
	}
	return (fi.Mode() & os.ModeCharDevice) != 0
}

// help returns the help message.
func help() string {
	return "\nUsage:\n\t" + os.Args[0] +
		" USERNAME COMMAND [args..]\n\tallowed commands are: " +
		fmt.Sprintf("%v", allowedCommands) + "\n"
}
