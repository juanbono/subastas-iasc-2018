# Subastas - IASC 2018

## Integrantes:

- Matias Mangiantini
- Juan Bono
- Kevin Mormandi

[Trabajo Practico](https://docs.google.com/document/d/19LNOQ6UVRD1bX99NxAA7DfSlM4BvavbCQtwrhkj7U8c/edit) de la materia Implementación de Arquitecturas Concurrentes de Software.

## Partes del sistema:

### Exchange
Es la interfaz del sistema con los compradores, se encarga de recibir:
  - Las solicitudes de registro de los compradores.
  - Las apuestas.
  - Las ofertas sobre apuestas existentes.
Para luego redirigirlas a los sistemas internos para su procesamiento.

### Buyers
Se encarga de mantener el estado de los compradores. 

### Bids
Se encarga de mantener el estado de las apuestas, validar las ofertas, etc.

### Client
Cliente de prueba que simula un cliente real.

## Deployment:
TODO
