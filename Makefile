.PHONY: help

help:
	@echo "Comandos:"
	@echo "- 'make run': levanta el sistema completo."
	@echo "- 'make deps': instala las dependencias."
	@echo "- 'make test': corre los tests de todas las aplicaciones.

run: 
	iex -S mix 

deps: 
	mix deps.get

test:
	mix test
