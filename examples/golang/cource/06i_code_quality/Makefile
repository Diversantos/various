install: 
	@curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.62.2
lint:
	@golangci-lint run ./... -v
lint_autofix:
	@GO111MODULE=on $(GOLINT) run ./ -v --fix
