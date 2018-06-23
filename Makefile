.PHONY: help

help:
	@echo "Comandos:"
	@echo "- 'make run': para levantar el sistema completo."
	@echo "- 'make deps': para instalar las dependencias."

run: 
	iex -S mix 

deps: 
	mix deps.get
