package main

import (
	"fmt"
	"os"
	"os/user"
	"strings"
	"testing"
)

func Test_help(t *testing.T) {
	if help() != "\nUsage:\n\t"+
		os.Args[0]+
		" USERNAME COMMAND [args..]\n\tallowed commands are: [pg_ctl pg_dump pg_dumpall psql createuser pg_ctlcluster true]\n" {
		t.Errorf("unexpected help message: %s", help())
	}
}

func Test_isTerminal(t *testing.T) {
	type args struct {
		stdin *os.File
	}

	tests := []struct {
		name string
		args args
		want bool
	}{
		{"nil is not attr terminal", args{nil}, false},
		{"regular file is not attr terminal", args{file()}, false},
		{"stdin is attr terminal", args{os.Stdin}, true},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := isTerminal(tt.args.stdin); got != tt.want {
				t.Errorf("isTerminal() = %v, want %v", got, tt.want)
			}
		})
	}
}

func file() (f *os.File) {
	f, _ = os.Open("main.go")
	return
}

func Test_main(t *testing.T) {
	type args struct {
		user string
		cmd  string
	}
	tests := []struct {
		name            string
		args            args
		wantErrContains string
	}{
		{"no args", args{"", ""}, "Usage:"},
		{"no command", args{"foo", ""}, "Usage:"},
		{"invalid command", args{currentUser(), "bash"}, "command bash not allowed, allowed commands are"},
		{"invalid user", args{"foo", "true"}, "user: unknown user foo"},
		{"valid user", args{currentUser(), "true"}, ""},
	}
	logFatal = func(v ...interface{}) { panic(v) }
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			defer func() {
				if r := recover(); r != nil {
					if len(tt.wantErrContains) == 0 {
						t.Errorf("main() failed: %v", r)
					}
					if len(tt.wantErrContains) > 0 && !strings.Contains(fmt.Sprintf("%v", r), tt.wantErrContains) {
						t.Errorf("main() failed with: %v, expecting: %v", r, tt.wantErrContains)
					}
				}
			}()
			setArgs(os.Args[0], tt.args.user, tt.args.cmd)
			main()
		})
	}
}

func setArgs(prog string, v ...string) {
	os.Args = []string{prog}
	for _, s := range v {
		if len(s) > 0 {
			os.Args = append(os.Args, s)
		}
	}
}

func currentUser() string {
	current, _ := user.Current()
	return current.Username
}
