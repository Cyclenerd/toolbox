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