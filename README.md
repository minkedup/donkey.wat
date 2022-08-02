# donkey.wat

A simple clone of the game
[DONKEY.BAS](https://en.wikipedia.org/wiki/DONKEY.BAS) written for the
[WASM-4](https://wasm4.org) fantasy console in [Webassembly
Text](https://webassembly.org/).

## Building

Before building, make sure you have the [WebAssembly Binary
Toolkit](https://github.com/WebAssembly/wabt) installed, along with `make`.

**Debian**
```sh
$ sudo apt-get install -y wabt make
```

**Fedora**
```sh
$ sudo dnf install -y wabt make
```

Build the cart by running:

```shell
make
```

## Running

First, make sure that you have the `w4` tool installed on your system. If you
don't, you can install it from npm with the following command:

```sh
$ npm install -g wasm4
```

Then you should be able to execute the following to run the program:

```shell
w4 run build/cart.wasm
```
