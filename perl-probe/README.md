# Perl Probe

Monitor availability of various components of your systems with `status-check.pl` and
export metrics to Google Cloud Monitoring (formerly, Stackdriver) using `gce-instance-metric.pl`.

* ✅ Check availability via `ping`
* ✅ Check TCP connections via `nc`
* ✅ Check HTTP(s) availability via `curl`
* ✅ Check DNS records via `dig`


## Uptime check

Check availability with Perl wrapper script `status-check.pl`.

Debian/Ubuntu requirements:
```shell
sudo apt update
sudo apt install      \
  iputils-ping        \
  curl                \
  grep                \
  netcat-openbsd      \
  dnsutils            \
  libapp-options-perl
```

Usage:
```shell
perl status-check.pl --help
```

### Ping

Send ping (ICMP ECHO_REQUEST) to network host.

Command:
```shell
perl status-check.pl --cmd=ping --dest=[DESTIONATION] --ping_count=[PING_COUNT] --timeout=[TIMEOUT]
```

Options:

| Name | Description | Allowed characters | Min/Max | Expression |
|------|-------------|--------------------|---------|------------|
| dest | Destination for the availability check (IP or Hostname) | `a-z`, `A-Z`, `0-9`, `.`, `:`, `-`, `_`, `?`, `=`, `/`, `&` | 1-255 | `^[\d\w\.\:\-\_\?\=\/\&]{1,255}$` |
| opt  | Option with port number [DEFAULT: `80`] | `10 till 99999` | 1-5 | `^[1-9]{1}[0-9]{1,4}$` |
| ping_count | Stop ping after sending count ECHO_REQUEST packets [DEFAULT: `2`] | `1 till 99` | 1-2 | ``^[1-9]{1}[0-9]{0,1}$`` |
| timeout | Duration we wait for response [DEFAULT: `5`] | `1 till 99` | 1-2 | `^[1-9]{1}[0-9]{0,1}$` |

Examples:
```shell
perl status-check.pl --cmd=ping --dest='localhost' --ping_count='4'
perl status-check.pl --cmd=ping --dest='1.1.1.1'   --timeout='15'
```

### TCP connection (nc)

Open a TCP connection.

Command:
```shell
perl status-check.pl --cmd=nc --dest=[DESTIONATION] --opt=[PORT] --timeout=[TIMEOUT]
```

Options:

| Name | Description | Allowed characters | Min/Max | Expression |
|------|-------------|--------------------|---------|------------|
| dest | Destination for the availability check (IP or Hostname) | `a-z`, `A-Z`, `0-9`, `.`, `:`, `-`, `_`, `?`, `=`, `/`, `&` | 1-255 | `^[\d\w\.\:\-\_\?\=\/\&]{1,255}$` |
| opt  | Option with port number [DEFAULT: `80`] | `10 till 99999` | 1-5 | `^[1-9]{1}[0-9]{1,4}$` |
| timeout | Duration we wait for response [DEFAULT: `5`] | `1 till 99` | 1-2 | `^[1-9]{1}[0-9]{0,1}$` |

Example:
```shell
perl status-check.pl --cmd=nc --dest='www.nkn-it.de' --port='443'
```

### HTTP

#### curl

Check a URL.

Command:
```shell
perl status-check.pl --cmd=curl --dest=[URL] --timeout=[TIMEOUT]
```

Options:

| Name | Description | Allowed characters | Min/Max | Expression |
|------|-------------|--------------------|---------|------------|
| dest | Destination for the availability check (URL) | `a-z`, `A-Z`, `0-9`, `.`, `:`, `-`, `_`, `?`, `=`, `/`, `&` | 1-255 | `^[\d\w\.\:\-\_\?\=\/\&]{1,255}$` |
| timeout | Duration we wait for response [DEFAULT: `5`] | `1 till 99` | 1-2 | `^[1-9]{1}[0-9]{0,1}$` |

Example:
```shell
perl status-check.pl --cmd=curl --dest='https://www.nkn-it.de/'
```

#### grep

Check for pattern in a website.

Command:
```shell
perl status-check.pl --cmd=curl --dest=[URL] --opt=[PATTERN] --timeout=[TIMEOUT]
```

Options:

| Name | Description | Allowed characters | Min/Max | Expression |
|------|-------------|--------------------|---------|------------|
| dest | Destination for the availability check (URL) | `a-z`, `A-Z`, `0-9`, `.`, `:`, `-`, `_`, `?`, `=`, `/`, `&` | 1-255 | `^[\d\w\.\:\-\_\?\=\/\&]{1,255}$` |
| opt  | Option with pattern for search [DEFAULT: `pong`] | `a-z`, `A-Z`, `0-9`, `.`, `,`, | 1-128 | `^[\d\w\.\,]{1,128}$` |
| timeout | Duration we wait for response [DEFAULT: `5`] | `1 till 99` | 1-2 | `^[1-9]{1}[0-9]{0,1}$` |

Example:
```shell
perl status-check.pl --cmd=grep --dest='https://www.nkn-it.de/ci.txt' --opt='3.14159'
```

### DNS

Perform a DNS lookup and check answer.

Valid query types:

* A
* AAAA
* NS
* MX
* TXT

#### A record (IPv4)

Perform a lookup for an A record and check answer.

Command:
```shell
perl status-check.pl --cmd=a --dest=[DNS] --opt=[PATTERN] --timeout=[TIMEOUT]
```

Options:

| Name | Description | Allowed characters | Min/Max | Expression |
|------|-------------|--------------------|---------|------------|
| dest | Destination for the availability check (DNS record) | `a-z`, `A-Z`, `0-9`, `.`, `:`, `-`, `_`, `?`, `=`, `/`, `&` | 1-255 | `^[\d\w\.\:\-\_\?\=\/\&]{1,255}$` |
| opt  | Option with pattern for search [DEFAULT: `\.`] | `a-z`, `A-Z`, `0-9`, `.`, `:`, `-`, `_` | 1-255 | `^[\d\w\.\:\-\_]{1,255}$` |
| timeout | Duration we wait for response [DEFAULT: `5`] | `1 till 99` | 1-2 | `^[1-9]{1}[0-9]{0,1}$` |

Example:
```shell
perl status-check.pl --cmd=a --dest='www.nkn-it.de' --opt='104.21.14.213'
```

#### AAAA record (IPv6)

Perform a lookup for an AAAA record and check answer.

Command:
```shell
perl status-check.pl --cmd=aaaa --dest=[DNS] --opt=[PATTERN] --timeout=[TIMEOUT]
```

Options:

| Name | Description | Allowed characters | Min/Max | Expression |
|------|-------------|--------------------|---------|------------|
| dest | Destination for the availability check (DNS record) | `a-z`, `A-Z`, `0-9`, `.`, `:`, `-`, `_`, `?`, `=`, `/`, `&` | 1-255 | `^[\d\w\.\:\-\_\?\=\/\&]{1,255}$` |
| opt  | Option with pattern for search [DEFAULT: `\.`] | `a-z`, `A-Z`, `0-9`, `.`, `:`, `-`, `_` | 1-255 | `^[\d\w\.\:\-\_]{1,255}$` |
| timeout | Duration we wait for response [DEFAULT: `5`] | `1 till 99` | 1-2 | `^[1-9]{1}[0-9]{0,1}$` |

Example:
```shell
perl status-check.pl --cmd=aaaa --dest='www.nkn-it.de' --opt='2606:4700:3035::6815:ed5'
```

#### Name server record (NS)

Perform a lookup for an name server record (NS) record and check answer.

Command:
```shell
perl status-check.pl --cmd=ns --dest=[DNS] --opt=[PATTERN] --timeout=[TIMEOUT]
```

Options:

| Name | Description | Allowed characters | Min/Max | Expression |
|------|-------------|--------------------|---------|------------|
| dest | Destination for the availability check (DNS record) | `a-z`, `A-Z`, `0-9`, `.`, `:`, `-`, `_`, `?`, `=`, `/`, `&` | 1-255 | `^[\d\w\.\:\-\_\?\=\/\&]{1,255}$` |
| opt  | Option with pattern for search [DEFAULT: `\.`] | `a-z`, `A-Z`, `0-9`, `.`, `:`, `-`, `_` | 1-255 | `^[\d\w\.\:\-\_]{1,255}$` |
| timeout | Duration we wait for response [DEFAULT: `5`] | `1 till 99` | 1-2 | `^[1-9]{1}[0-9]{0,1}$` |

Example:
```shell
perl status-check.pl --cmd=ns --dest='nkn-it.de' --opt='abby.ns.cloudflare.com'
```

#### MX record

Perform a lookup for an MX record and check answer.

Command:
```shell
perl status-check.pl --cmd=mx --dest=[DNS] --opt=[PATTERN] --timeout=[TIMEOUT]
```

Options:

| Name | Description | Allowed characters | Min/Max | Expression |
|------|-------------|--------------------|---------|------------|
| dest | Destination for the availability check (DNS record) | `a-z`, `A-Z`, `0-9`, `.`, `:`, `-`, `_`, `?`, `=`, `/`, `&` | 1-255 | `^[\d\w\.\:\-\_\?\=\/\&]{1,255}$` |
| opt  | Option with pattern for search [DEFAULT: `\.`] | `a-z`, `A-Z`, `0-9`, `.`, `:`, `-`, `_` | 1-255 | `^[\d\w\.\:\-\_]{1,255}$` |
| timeout | Duration we wait for response [DEFAULT: `5`] | `1 till 99` | 1-2 | `^[1-9]{1}[0-9]{0,1}$` |

Example:
```shell
perl status-check.pl --cmd=mx --dest='nkn-it.de' --opt='mxext1.mailbox.org'
```

#### TXT record

Perform a lookup for an TXT record and check answer.

Command:
```shell
perl status-check.pl --cmd=txt --dest=[DNS] --opt=[PATTERN] --timeout=[TIMEOUT]
```

Options:

| Name | Description | Allowed characters | Min/Max | Expression |
|------|-------------|--------------------|---------|------------|
| dest | Destination for the availability check (DNS record) | `a-z`, `A-Z`, `0-9`, `.`, `:`, `-`, `_`, `?`, `=`, `/`, `&` | 1-255 | `^[\d\w\.\:\-\_\?\=\/\&]{1,255}$` |
| opt  | Option with pattern for search [DEFAULT: `\.`] | `a-z`, `A-Z`, `0-9`, `.`, `:`, `-`, `_` | 1-255 | `^[\d\w\.\:\-\_]{1,255}$` |
| timeout | Duration we wait for response [DEFAULT: `5`] | `1 till 99` | 1-2 | `^[1-9]{1}[0-9]{0,1}$` |

Example:
```shell
perl status-check.pl --cmd=txt --dest='nkn-it.de' --opt='mailgun.com'
```


## Add data point to Google monitoring

With the Perl script `gce-instance-metric.pl` you can add a data point to your custom Google monitoing metric.

Debian/Ubuntu requirements:
```shell
sudo apt update
sudo apt install      \
  libapp-options-perl \
  libwww-perl         \
  libjson-xs-perl     \
  libdatetime-perl    \
  libdatetime-format-rfc3339-perl
```

Usage:
```shell
perl gce-instance-metric.pl --help
```

Command:
```shell
perl gce-instance-metric.pl \
  --token=[TOKEN]           \
  --metric=[METRIC_NAME]    \
  --value=[INT_VALUE]       \
  --instance=[GCE_INSTANCE] \
  --zone=[GCE_ZONE]         \
  --project=[GCE_PROJECT]
```

Options:

| Name | Description | Allowed characters | Min/Max | Expression |
|------|-------------|--------------------|---------|------------|
| token | Google Cloud access token [DEFAULT: Access token from metadata server] | `string` | - | - |
| metric  | Custom metric name without `custom.googleapis.com/` prefix [DEFAULT: `vpc-probe/ping`] | `a-z`, `0-9`, `-`, `/` | 1-255 | `^[a-z0-9\-\/]{1,255}$$` |
| value | Value [DEFAULT: `100`] | `int` | - | - |
| instance | Google Compute Engine instance id (name) | `a-z`, `0-9`, `-` | 1-63 | `^[a-z0-9\-]{1,63}$` |
| zone | Google Compute Engine zone (the zone from the GCE instance) | `a-z`, `0-9`, `-` | 1-128 | `^[a-z0-9\-]{1,128}$` |
| project | Google Cloud project id (the project on which to execute the request) | `a-z`, `0-9`, `-` | 6-60 | `^[a-z0-9\-]{6,60}$` |

Example:
```shell
# Add default value 100 to default metric custom.googleapis.com/vpc-probe/ping
perl gce-instance-metric.pl --instance='test-server' --zone='europe-west4-c' --project='test-sandbox'
```

## Configuration

The Perl module [App::Options](https://metacpan.org/pod/App::Options) is used.
App::Options combines command-line arguments, environment variables, option files and program defaults.

### Option Files

A cascading set of option files are all consulted to allow individual users to specify values that override the normal values for certain programs.

Furthermore, the values for individual programs can override the values configured generally system-wide.

The resulting value for an option variable comes from the first place that it is ever seen.
Subsequent mentions of the option variable within the same or other option files will be ignored.

The following files are consulted in order.

```text
$ENV{HOME}/.app/$app.conf
$ENV{HOME}/.app/app.conf
$prog_dir/$app.conf
$prog_dir/app.conf
$prefix/etc/app/$app.conf
$prefix/etc/app/app.conf
/etc/app/app.conf
```

If the special option, `$app` is the program name without any trailing extension (i.e. ".exe", ".pl", etc.).

Option file:

* status-check.conf
* gce-instance-metric.conf

The Program Directory `$prog_dir` is the directory in which the program exists on the file system.

The Special Option `$prefix` represents the root directory of the software installation.

### Environment Variables

For each variable/value pair that is to be inserted into the option,
the corresponding environment variables are searched to see if they are defined.

The environment always overrides an option file value.

By default, the environment variable for an option variable named `timeout` would be `APP_TIMEOUT`.

Example:
```
export APP_TIMEOUT="10"
export APP_METRIC="my-custom/probe"
```

### Command Line Argument

Each command line argument that begins with a "-" or a "--" is considered to be an option:

```shell
--timeout=10 # long option, with arg
-timeout=10  # short option, with arg
```

The command line argument always overrides an option file value and environment variable.

### Debug

Specifying the `--debug_options` option on the command line will assist in figuring out which files App::Options is looking at.

Example:
```text
$ perl status-check.pl --cmd=txt --dest='nkn-it.de' --opt='mailgun.com' --debug_options=1
1. Parsed Command Line Options. [--cmd=txt --dest=nkn-it.de --opt=mailgun.com --debug_options=1]
3. Provisional prefix Set. prefix=[/home/nils/perl5/perlbrew/perls/perl-5.26.1] origin=[perl prefix]
4. Set app variable. app=[status-check] origin=[program name (status-check.pl)]
5. Scanning Option Files
   Looking for Option File [/etc/app/policy.conf]
   Looking for Option File [/home/nils/.app/status-check.conf]
   Looking for Option File [/home/nils/.app/app.conf]
   Looking for Option File [./status-check.conf]
   Looking for Option File [./app.conf]
   Looking for Option File [/home/nils/perl5/perlbrew/perls/perl-5.26.1/etc/app/status-check.conf]
   Looking for Option File [/home/nils/perl5/perlbrew/perls/perl-5.26.1/etc/app/app.conf]
   Looking for Option File [/etc/app/app.conf]
6. Scanning for Environment Variables.
7. prefix Made Definitive [/home/nils/perl5/perlbrew/perls/perl-5.26.1]
8. Set Defaults.
User input:
         Command: txt
         Destination: nkn-it.de
         Option: mailgun.com
File: /tmp/15d45f2509126484f295a467baa497716a95742d401311586e75d5db3f88be9c.out
Command: dig txt 'nkn-it.de' | grep 'mailgun.com'
File content:
"v=spf1 mx a:smtp.nkn-it.de include:mailgun.com include:mailbox.org ~all"
UP: txt check on [ destination=nkn-it.de, option=mailgun.com ] has a normal state
```


## Contributing

Have a patch that will benefit this project?
Awesome! Follow these steps to have it accepted.

1. Please read [how to contribute](CONTRIBUTING.md).
1. Fork this Git repository and make your changes.
1. Create a Pull Request.
1. Incorporate review feedback to your changes.
1. Accepted!


## License

All files in this repository are under the [Apache License, Version 2.0](LICENSE) unless noted otherwise.