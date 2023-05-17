# Go (programming language)

## Install

[Download](https://go.dev/dl/) latest version: 

```shell
curl -L "https://go.dev/dl/go1.19.1.linux-amd64.tar.gz" -o "go.linux-amd64.tar.gz"
```

Remove any previous Go installation:

```shell
rm -rf /usr/local/go && \
tar -C /usr/local -xzf "go.linux-amd64.tar.gz"
```


Add `/usr/local/go/bin` to the `PATH` environment variable:

```shell
export PATH=$PATH:/usr/local/go/bin
```

Test:

```shell
go version
```

## go.mod and go.sum

Dependency management with go...

Init:

```shell
go mod init -
```

Ensures that the go.mod file matches the source code:

```shell
go mod tidy
```

> When we upgrade the version of a specific package in go.mod
> we need to run the command go mod tidy to update the checksums in go.sum

Clear cache:

```shell
go clean -modcache
```

## Cross Compile

Get supported operating systems and CPU architectures:

```shell
go tool dist list
```

To cross compile we need two environment variables.
These are `GOOS` and `GOARCH`.

```shell
GOOS=windows GOARCH=386 go build -o main.exe main.go
```

Copy & Paste:
```text
# Windows
GOOS=windows GOARCH=386
GOOS=windows GOARCH=amd64
# Linux
GOOS=linux   GOARCH=386
GOOS=linux   GOARCH=amd64
GOOS=linux   GOARCH=arm
GOOS=linux   GOARCH=arm64
# Mac
GOOS=darwin  GOARCH=386
GOOS=darwin  GOARCH=amd64
GOOS=darwin  GOARCH=arm
GOOS=darwin  GOARCH=arm64
```

## Format

Gofmt formats Go programs.

* **`-w`** : If a file's formatting is different from gofmt's, overwrite it with gofmt's version.
* **`-s`** : Try to simplify code

```bash
gofmt -w -s *.go
```

## Lint

Please use `golangci-lint`. It is a Go linters aggregator.

* Install: <https://golangci-lint.run/usage/install/>
    * Linux:
        ```bash
        curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin
        ```
    * macOS:
        ```bash
        brew install golangci-lint
        ```

Run:
```bash
golangci-lint run
```