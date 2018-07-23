# Subastas - IASC 2018

[Trabajo Practico](https://docs.google.com/document/d/19LNOQ6UVRD1bX99NxAA7DfSlM4BvavbCQtwrhkj7U8c/edit) de la materia Implementación de Arquitecturas Concurrentes de Software.

## Integrantes:

- Matias Mangiantini
- Juan Bono
- Kevin Mormandi

## Partes del sistema:
![Arbol de supervision](/docs/exchange_diagram.png)
### Exchange
Es la interfaz del sistema con los compradores, se encarga de recibir:
  - Las solicitudes de registro de los compradores.
  - Las apuestas.
  - Las ofertas sobre apuestas existentes.
Para luego procesarlas.

### Buyers
Se encarga de mantener el estado de los compradores y notificarlos de los distintos eventos (nueva apuesta, apuesta finalizada, nuevo precio, etc). Cada comprador esta representado como un [GenServer](https://hexdocs.pm/elixir/GenServer.html). Este se encarga de recibir los diferentes eventos del sistema y en caso de ser necesario, notificar al comprador al que representa.

### Bids
Se encarga de mantener el estado de las apuestas y validar las ofertas. Cada apuesta esta representada como un [GenServer](https://hexdocs.pm/elixir/GenServer.html). 

### Client
Cliente de prueba que simula un cliente real.

## Deployment:

[Como hacer deployment de la Exchange con Docker y Kubernetes](/apps/exchange/DEPLOY.md).
