WAT2WASM = "/usr/bin/wat2wasm"

ifeq ($(OS), Windows_NT)
	MKDIR_BUILD = mkdir build 
	RMDIR = rd /s /q
else
	MKDIR_BUILD = mkdir -p build
	RMDIR = rm -rf
endif

all: build/cart.wasm
.PHONY: all

run: build/cart.wasm
	w4 run build/cart.wasm
.PHONY: run

watch:
	w4 watch
.PHONY: watch

# build cart.wasm from main.wat
build/cart.wasm: main.wat
	$(MKDIR_BUILD)
	$(WAT2WASM) $< -o $@

clean:
	$(RMDIR) build
.PHONY: clean
