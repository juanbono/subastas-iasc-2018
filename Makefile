.PHONY: help run test start_clientA start_clientB deps deps_client deps_exchange start_exchange

help:
	@echo "Comandos:"
	@echo "- 'make run': levanta el sistema completo."
	@echo "- 'make deps': instala las dependencias de cada app."
	@echo "- 'make test': corre los tests de todas las aplicaciones."
	@echo "- 'make start_exchange': levanta una instancia de la exchange en el puerto 4000."
	@echo "- 'make start_client1': levanta un cliente en el puerto 5001."
	@echo "- 'make start_client2: levanta un cliente en el puerto 5002."

run: 
	iex -S mix 

deps_exchange: 
	cd apps/exchange && mix deps.get

deps_client:
	cd apps/client && mix deps.get

deps:
	make deps_exchange && make deps_client

test:
	mix test

start_exchange:
	cd apps/exchange && iex -S mix

start_clientA:
	cd apps/client/ && REPLACE_OS_VARS=true EXCHANGE="http://192.168.99.100:31782" PORT=5001 iex --sname A -S mix

start_clientB:
	ifdef $(exchange)
		cd apps/client/ && REPLACE_OS_VARS=true EXCHANGE=$(exchange) PORT=5002 iex --sname B -S mix
	endif

start_clientC:
	ifdef $(exchange)
		cd apps/client/ && REPLACE_OS_VARS=true EXCHANGE=$(exchange) PORT=5003 iex --sname C -S mix
	endif
