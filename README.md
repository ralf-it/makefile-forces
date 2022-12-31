# Makefile Forces

## License

This project is licensed under the [Apache License, Version 2.0](LICENSE.md).

## IDE Configuration

### Visual Studio Code

.vscode/settings.json:

```json
{
    "files.associations": {
        "Makefile.*": "makefile",
        ".env.*": "env",
        ".env-*": "env"
    }
}
```

## Prerquisities

- GNU Make 4.3 or later
- Bash 5.1 or later

## Important

Do not create targets with a name `<TARGET>` that internally would call target with same name `<TARGET>`. This will cause infinite loop. It include also `make $@+INFO -- something <TARGET> something`. Safest is to use quotes `make $@+INFO -- "something <TARGET> something"`.


## Installation

### PIP install/update

#### User home

```sh
pip install git+https://github.com/ralf-it/makefile-forces.git@v3.0.5 --verbose --force
```

then use in Makefile in HOME dir via

```Makefile
include ~/.make/forces.mk
```

or copy sample `forces/.samples/forces.mk` to LOCAL dir ie. `.make/forces.mk` and use it in Makefile via

```Makefile
include .make/forces.mk
```

#### Custom Directory

```sh
INSTALL_DIR=$(pwd) pip install git+https://github.com/ralf-it/makefile-forces.git@v3.0.5 --verbose --force
```

then use in Makefile in PWD dir via

```Makefile
include .make/forces.mk
```

## Usage

To not display too many unrelated targets, the targets are grouped into three categories:
- static project targets
- dynamic project targets
- forces targets

Use the targets as follows.


Project static targets:

```sh
make <TAB> # list all targets
make help
```

Project dynamic targets :
```sh
make @<TAB> # list all targets
make @help
```

Forces targets:
```sh
make /<TAB> # list all targets
make /help
```

Show all help:
```sh
make /HELP
```

Arguments and keywords:
```sh
make <TARGET> \*ARGS -- \*\*KWARGS # list all targets
```


## Development

Forces is also used in developing itself. So feel free to take a look how its used in [Makefile](https://raw.githubusercontent.com/ralf-it/makefile-forces/main/Makefile).

