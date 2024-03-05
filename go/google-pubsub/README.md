# Publish to Google Cloud Pub/Sub Topic

[![Badge: Google Cloud](https://img.shields.io/badge/Google%20Cloud-%234285F4.svg?logo=google-cloud&logoColor=white)](#readme)
[![Badge: Linux](https://img.shields.io/badge/Linux-FCC624.svg?logo=linux&logoColor=black)](#-download)
[![Badge: macOS](https://img.shields.io/badge/macOS-000000.svg?logo=apple&logoColor=white)](#-download)
[![Badge: Windows](https://img.shields.io/badge/Windows-008080.svg?logo=windows95&logoColor=white)](#-download)
[![Badge: Go](https://img.shields.io/badge/Go-%2300ADD8.svg?logo=go&logoColor=white)](#readme)
[![Badge: GitHub go.mod Go version](https://img.shields.io/github/go-mod/go-version/cyclenerd/google-cloud-pubsub-publish)](https://github.com/Cyclenerd/google-cloud-pubsub-publish/blob/master/go.mod)
[![Badge: CI](https://github.com/Cyclenerd/google-cloud-pubsub-publish/actions/workflows/ci.yml/badge.svg)](https://github.com/Cyclenerd/google-cloud-pubsub-publish/actions/workflows/ci.yml)
[![Badge: GitHub license](https://img.shields.io/github/license/cyclenerd/google-cloud-pubsub-publish)](https://github.com/Cyclenerd/google-cloud-pubsub-publish/blob/master/LICENSE)

Small and fast CLI program to publish a message to a Google Cloud Pub/Sub topic.

This CLI program is developed in Go and faster than the original Google Cloud CLI tool `gcloud`.
There are ready-to-run compiled binaries for Linux, macOS and Windows.

## 🔑 Authentication

Set the environment variable `GOOGLE_APPLICATION_CREDENTIALS` to the path of the JSON file that contains your service account key. This variable only applies to your current shell session, so if you open a new session, set the variable again.

<details>
<summary><b>Linux</b></summary>

Shell:

```shell
export GOOGLE_APPLICATION_CREDENTIALS="PATH_TO_JSON_KEY"
```

Replace `PATH_TO_JSON_KEY` with the path of the JSON file that contains your service account key.

</details>

<details>
<summary><b>macOS</b></summary>

Shell:

```shell
export GOOGLE_APPLICATION_CREDENTIALS="PATH_TO_JSON_KEY"
```

Replace `PATH_TO_JSON_KEY` with the path of the JSON file that contains your service account key.
</details>

<details>
<summary><b>Windows</b></summary>

PowerShell:
```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS="PATH_TO_JSON_KEY"
```

Command prompt:
```shell
set GOOGLE_APPLICATION_CREDENTIALS=PATH_TO_JSON_KEY
```

Replace `PATH_TO_JSON_KEY` with the path of the JSON file that contains your service account key.
</details>

## 💁 Usage

Synopsis:

```shell
pubsub-publish \
  --project="PROJECT_ID" \
  --topic="TOPIC" \
  --message="MESSAGE"
```

Arguments:

**`-p`, `--project`**

* Google Cloud project ID

**`-t`, `--topic`**

* Topic ID or fully qualified identifier for the topic

**`-m`, `--message`**

* The body of the message to publish to the given topic name


## 🚀 Benchmark

I developed this CLI program because I wanted to publish messages faster to a Pub/Sub topic from a Raspberry Pi 4
(Broadcom BCM2711, Quad core Cortex-A72 (ARM v8) 64-bit SoC @ 1.5GHz) with Raspberry Pi OS Lite (64-bit).

Here you have the comparison of the runtime to publish one message:

| This app  |          | Google Cloud CLI |
|-----------|----------|------------------|
| 0.293 sec | +1.9 sec | 2.193 sec        |

**This CLI program**

```shell
pi@raspberry:~ $ time ./pubsub-publish \
  --project="PROJECT_ID" \
  --topic="TOPIC" \
  --message='{"test":"true"}'

real    0m0.293s
user    0m0.241s
sys     0m0.058s
```

**Google Cloud CLI**

```shell
pi@raspberry:~ $ time gcloud pubsub topics publish "TOPIC" \
  --project="PROJECT_ID" \
  --message='{"test":"true"}'

real    0m2.193s
user    0m1.818s
sys     0m0.256s

pi@raspberry:~ $ time gcloud version
Google Cloud SDK 401.0.0
bq 2.0.75
core 2022.09.03
gcloud-crc32c 1.0.0
gsutil 5.12

real    0m1.961s
user    0m1.722s
sys     0m0.223s
```

You can see that it is not the publication of the actual message which takes a long time,
it is the launching of the Google Cloud CLI.