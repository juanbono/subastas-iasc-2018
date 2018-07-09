.PHONY: help run test start_client1 start_client2 deps

help:
	@echo "Comandos:"
	@echo "- 'make run': levanta el sistema completo."
	@echo "- 'make deps': instala las dependencias."
	@echo "- 'make test': corre los tests de todas las aplicaciones.
	@echo "- 'make start_client1': levanta un cliente en el puerto 5001.
	@echo "- 'make start_client2: levanta un cliente en el puerto 5002.

run: 
	iex -S mix 

deps: 
	mix deps.get

test:
	mix test

start_client1:
	cd apps/client/ && PORT=5001 iex -S mix

start_client2:
	cd apps/client/ && PORT=5002 iex -S mix
