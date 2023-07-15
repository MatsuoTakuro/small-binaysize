FROM golang:1.18-alpine AS build-env
WORKDIR /app
COPY go.mod .
# COPY go.sum .

# install upx to compress executable
RUN apk add --no-cache upx || \
    go version && echo "upx is not available. please check go version." \
    go mod download
COPY . .

# CGO_ENABLED=0 to disable cgo for building static binary
# -buildvcs=false to disable vcs info in binary
# -trimpath to remove all file system paths from the resulting executable
# -ldflags '-w -s' to disable DWARF debugging info and strip the symbol table
RUN CGO_ENABLED=0 go build -buildvcs=false -trimpath -ldflags '-w -s' -o /go/bin/myapp
RUN [ -e /usr/bin/upx ] && upx /go/binmyapp || echo "upx does not exist or upx execution failed."

FROM scratch
COPY --from=build-env /go/bin/myapp /go/bin/myapp
ENTRYPOINT ["/go/bin/myapp"]
