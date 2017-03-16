# Flowdocktee

Flowdocktee is a bash script that works like [tee](https://en.wikipedia.org/wiki/Tee_(command))
command. It sends the standard input to flowdock instead of writing to files.

Flowdocktee is inspired by wonderful [slacktee](https://github.com/course-hero/slacktee)

## Requirements

Flowdocktee needs [curl](https://curl.haxx.se/) to communicate with Flowdock.

## Installation

Clone the git repository
```
$ git clone https://github.com/netMedi/flowdocktee.git
```

Install `flowdocktee`.
```
$ chmod -x install.sh
$ ./install.sh
```

After installation copy the `flowdocktee.conf.sample` to `$HOME/.flowdocktee`
and insert your user's `api_token`, `flow`, and `organization` accordingly,
depending on where you want the messages to be sent.
You can also pass `--config` parameter for the command which defines alternative
configuration path.

## Configuration

- `api_token`: Can be found in your [api tokens page](https://www.flowdock.com/account/tokens),
this command does not support the flow API tokens as the API is deprecated and 
the [messages endpoint](https://www.flowdock.com/api/messages) usage is encouraged.

- `flow` is the name of the flow you want the messages to be sent to.

- `organization` is the name of the organization where the `flow` belongs.

## Usage

```
usage: flowdoctee [options]
  options:
    --config        Specify the location ot the alternative configuration file.
```

```
$ echo "Hello world" | flowdocktee
```

```
$ ls | flowdocktee | grep ".conf"
```

In case of missconfiguration or error flowdocktee just fails silently as we
want to pipe the input always instead of halting the subsequent commands.
