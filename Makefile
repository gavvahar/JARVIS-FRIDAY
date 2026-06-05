.PHONY: fmt lint

fmt:
	npx prettier --write "**/*.{json,yml,yaml,md}"
	git add .
	git commit -m "chore: format files" --no-verify

lint:
	make fmt
	tox -e all