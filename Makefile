.PHONY: fmt lint

fmt:
	black .
	npx prettier --write "**/*.{json,yml,yaml,md}"
	git add .
	git diff --cached --quiet || git commit -m "chore: format files" --no-verify

lint:
	make fmt
	tox -e all