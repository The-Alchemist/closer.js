build:
	docker compose build

run:
	docker compose run --rm --remove-orphans closer-repl

test:
	docker compose run --rm --remove-orphans --entrypoint sh closer-repl -c "npm test"
