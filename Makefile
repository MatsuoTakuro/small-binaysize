build:
	docker build . -t go-binary

run:
	docker run go-binary --name go-binary