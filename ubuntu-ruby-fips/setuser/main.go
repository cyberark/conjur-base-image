package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"os/user"
	"strconv"
	"syscall"
)

func main() {
	if len(os.Args) < 3 {
		log.Fatal(help())
	}
	u, err := user.Lookup(os.Args[1])
	if err != nil {
		log.Fatal(err)
	}
	uid, err := strconv.ParseInt(u.Uid, 10, 32)
	gid, err := strconv.ParseInt(u.Gid, 10, 32)
	cmd := exec.Command(os.Args[2], os.Args[3:]...)
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
		log.Fatal(err)
	}
}

// isTerminal returns true if the given file is a terminal.
func isTerminal(stdin *os.File) bool {
	fi, err := stdin.Stat()
	if err != nil {
		return false
	}
	return (fi.Mode() & os.ModeCharDevice) != 0
}

func help() string {
	return "\nUsage:\n\t" + os.Args[0] + " USERNAME COMMAND [args..]\n"
}
