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

## Installation

### PIP install/update in user home

```sh
pip install git+https://github.com/ralf-it/makefile-forces.git@v2.0.3 --verbose --force
```

then use in Makefile via

```Makefile
-include ~/.local/include/make/forces.mk
```

### Bash install script in project dir


Development from main branch:

```bash
curl https://raw.githubusercontent.com/ralf-it/makefile-forces/main/.install/install.sh | bash
```

Release from tag:

```bash
curl https://raw.githubusercontent.com/ralf-it/makefile-forces/main/.install/install.sh | bash -s -- 2.0.0
```


then use in Makefile via

```Makefile
-include .make/forces.mk
```