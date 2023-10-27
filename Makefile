SHELL := /bin/bash
PRJ_NAME ?=
TAG ?=

clean-client:
	- rm -r build/macos/
	- rm -r build/linux/
	- rm -r build/windows/

clean-server:
	rm -r ./build/server/

clean-all:
	clean-client
	clean-server

###############################################################
# Client Build
###############################################################

# check_dependency
flutter_distributor:
	@source ~/.bashrc; \
	if command -v flutter_distributor; then \
		echo "exist flutter_distributor"; \
	else \
		echo "Dependency not found. Installing flutter_distributor.."; \
		flutter pub global activate flutter_distributor; \
		echo 'export PATH="$$PATH":"$$HOME/.pub-cache/bin"' >> ~/.bashrc; \
	fi

# 编译到 Linux
build-client-linux-arm64:
	flutter build linux

build-client-linux-amd64: flutter_distributor
	mkdir -p ./linux/packaging/deb/
	cp ./packaging/deb/make_config.yaml ./linux/packaging/deb/
	source ~/.bashrc; \
	flutter_distributor package --platform linux --targets deb --no-skip-clean

# 编译到 macOS
build-client-macOS-x64:
	@ - make clean-client
	flutter build macos
	npx appdmg ./packaging/dmg/config.json packaging/dmg/$(PRJ_NAME)-$(TAG)-x64.dmg

# 编译到 windows
build-client-windows-amd64:
	@ - make clean-client
	./packaging/exe/InnoSteupScript.iss

build-client-windows-arm64: build-client-windows-amd64

###############################################################
# Server Build
###############################################################

# 编译到 Linux
build-server-linux-arm64:
	@ - make clean-server
	mkdir -p ./build/server
	CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o ./build/server/server.linux-arm64.bin ./src/server/server.go

build-server-linux-amd64:
	@ - make clean-server
	mkdir -p ./build/server
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o ./build/server/server.linux-amd64.bin ./src/server/server.go

# 编译到 macOS
build-server-macOS-arm64:
	@ - make clean-server
	mkdir -p ./build/server
	CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 go build -o ./build/server/server.darwin-arm64.bin ./src/server/server.go

build-server-macOS-amd64:
	@ - make clean-server
	mkdir -p ./build/server
	CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build -o ./build/server/server.darwin-amd64.bin ./src/server/server.go

# 编译到 windows
build-server-windows-arm64:
	@ - make clean-server
	mkdir -p ./build/server
	CGO_ENABLED=0 GOOS=windows GOARCH=arm64 go build -o ./build/server/server.windows-arm64.exe ./src/server/server.go

build-server-windows-amd64:
	@ - make clean-server
	mkdir -p ./build/server
	CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -o ./build/server/server.windows-amd64.exe ./src/server/server.go


# 编译server到 全部平台
build-server: build-server-linux-arm64 build-server-linux-amd64 build-server-macOS-arm64 build-server-macOS-amd64 build-server-windows-arm64 build-server-windows-amd64
