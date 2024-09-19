
```bash
git clone https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/lyrebird
```

>Редактируем `Makefile`
```
# Variables for configuration
VERSION = $(shell git describe | sed 's/lyrebird-//')
OUTPUT := lyrebird

# Build for amd64
build:
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-X main.lyrebirdVersion=$(VERSION)" -o $(OUTPUT) ./cmd/lyrebird

# Build for MIPS little-endian
build-mipsle:
	CGO_ENABLED=0 GOOS=linux GOARCH=mipsle go build -ldflags="-X main.lyrebirdVersion=$(VERSION)" -o $(OUTPUT) ./cmd/lyrebird

# Build for MIPS64 little-endian
build-mips64le:
	CGO_ENABLED=0 GOOS=linux GOARCH=mips64le go build -ldflags="-X main.lyrebirdVersion=$(VERSION)" -o $(OUTPUT) ./cmd/lyrebird

# Build for ARM (32-bit)
build-arm:
	CGO_ENABLED=0 GOOS=linux GOARCH=arm go build -ldflags="-X main.lyrebirdVersion=$(VERSION)" -o $(OUTPUT) ./cmd/lyrebird

# Build for ARM (64-bit)
build-arm64:
	CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -ldflags="-X main.lyrebirdVersion=$(VERSION)" -o $(OUTPUT) ./cmd/lyrebird

# Clean up
clean:
	rm -f $(OUTPUT)  # Remove the output binary, ignoring errors if it doesn't exist
```

