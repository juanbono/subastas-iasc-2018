.PHONY: help run test start_clientA start_clientB deps deps_client deps_exchange start_exchange \
        start_bids start_buyers deps_bids deps_buyers

help:
	@echo "Comandos:"
	@echo "- 'make deps': instala las dependencias de cada app."
	@echo "- 'make start_exchange': levanta una instancia de la exchange en el puerto 4000."
	@echo "- 'make start_client1': levanta un cliente en el puerto 5001."
	@echo "- 'make start_client2: levanta un cliente en el puerto 5002."

deps_exchange: 
	cd apps/exchange && mix deps.get

deps_client:
	cd apps/client && mix deps.get

deps_bids:
	cd apps/bids && mix deps.get

deps_buyers:
	cd apps/buyers && mix deps.get

deps:
	make deps_exchange && make deps_client && make deps_bids && make deps_buyers

start_exchange:
	cd apps/exchange && iex -S mix

start_bids:
	cd apps/bids && iex -S mix

start_buyers:
	cd apps/buyers && iex -S mix

start_clientA:
	cd apps/client/ && PORT=5001 iex --sname A -S mix

start_clientB:
	cd apps/client/ && PORT=5002 iex --sname B -S mix

start_clientC:
	cd apps/client/ && PORT=5003 iex --sname C -S mix
