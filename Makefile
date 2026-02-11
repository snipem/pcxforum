.PHONY: test build clean run ui run_binary install deps release lint build-all

# pcxforum parameters
BINARY_NAME=pcxforum
VERSION=$(shell git describe --tags --always)
DIST_DIR=dist

# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GORUN=$(GOCMD) run
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOINSTALL=$(GOCMD) install -v
GOGET=$(GOCMD) get

all: test build install
build:
		$(GOBUILD) -o $(BINARY_NAME) -v
test:
		$(GOTEST) ./...
clean:
		$(GOCLEAN)
		rm -f $(BINARY_NAME)
		rm -rf $(DIST_DIR)

run:
		PCXFORUM_READLOG_FILE=/tmp/pcxforumread \
		PCXFORUM_DEBUG=true \
		go run pcxforum.go
	
ui:
		tmux send-keys -t right "C-c"; sleep 0.1; tmux send-keys -t right "cd ${GOPATH}/src/github.com/snipem/pcxforum && make run" "C-m"; tmux select-pane -t right

run_binary:
		$(GOBUILD) -o $(BINARY_NAME)
		./$(BINARY_NAME)
install:
		$(GOINSTALL) .
deps:
		$(GOCMD) mod download

build-all:
		@mkdir -p $(DIST_DIR)
		@echo "Building pcxforum $(VERSION)"
		@echo "Building for Linux (amd64)..."
		GOOS=linux GOARCH=amd64 $(GOBUILD) -o $(DIST_DIR)/$(BINARY_NAME)-$(VERSION)-linux-amd64 -v
		@echo "Building for Linux (arm64)..."
		GOOS=linux GOARCH=arm64 $(GOBUILD) -o $(DIST_DIR)/$(BINARY_NAME)-$(VERSION)-linux-arm64 -v
		@echo "Building for macOS (amd64)..."
		GOOS=darwin GOARCH=amd64 $(GOBUILD) -o $(DIST_DIR)/$(BINARY_NAME)-$(VERSION)-darwin-amd64 -v
		@echo "Building for macOS (arm64)..."
		GOOS=darwin GOARCH=arm64 $(GOBUILD) -o $(DIST_DIR)/$(BINARY_NAME)-$(VERSION)-darwin-arm64 -v
		@echo "Building for Windows (amd64)..."
		GOOS=windows GOARCH=amd64 $(GOBUILD) -o $(DIST_DIR)/$(BINARY_NAME)-$(VERSION)-windows-amd64.exe -v
		@echo "Building for Windows (arm64)..."
		GOOS=windows GOARCH=arm64 $(GOBUILD) -o $(DIST_DIR)/$(BINARY_NAME)-$(VERSION)-windows-arm64.exe -v
		@echo "Build complete! Binaries in $(DIST_DIR)/"
		@ls -lh $(DIST_DIR)/

release:
		git tag $(TAG_VERSION)
		goreleaser release --clean

lint:
		golangci-lint run

