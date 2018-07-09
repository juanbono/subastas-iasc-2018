# Documentación

## JSON Payloads:

#### JSON de Comprador (Viejo, ip debe reemplazarse por el objeto con 3 url)
```json
{
  "name": "buyer_name",
  "ip": "127.0.0.1:5000",
  "tags": ["cats", "dogs"]
}
```

#### JSON de Oferta (Viejo, hay que ver si se agrega el id o nombre del que oferta)
```json
{
  "price": 2700,
  "close_at": 1533764803,
  "json": {"name": "a table", "country": "Argentina"},
  "tags": ["wood"]
}
```

#### JSON de notificación de nueva oferta
```json
{
  "id": 1,
  "bid": {
    "description": "Jean Slim Tiana Azul",
    "colour": "blue",
    "stock": 1,
    "image_url": "https://tascani.vteximg.com.br/arquivos/ids/161468-340-510/jean-slim-tiana-2.jpg"
  },
  "best_offer": null,
  "close_at": 1529856667,
  "tags": ["fashion", "jeans", "free_shipment"],
  "seller": {
    "id": 1,
    "company_name": "Tascani"
  },
  "price": 2500
}
```

#### JSON de notificación de subasta terminada.
```json
{
  "id": 1,
  "bid": {
    "description": "Jean Slim Tiana Azul",
    "colour": "blue",
    "stock": 1,
    "image_url": "https://tascani.vteximg.com.br/arquivos/ids/161468-340-510/jean-slim-tiana-2.jpg"
  },
  "best_offer": {
    "price": 3000,
    "user_id": 40
  },
  "close_at": 1529856667,
  "tags": ["fashion", "jeans", "free_shipment"],
  "seller": {
    "id": 1,
    "company_name": "Tascani"
  },
  "price": 3000
}
```

#### JSON de Nuevo Precio
```json
{
  "id": 1,
  "bid": {
    "description": "Jean Slim Tiana Azul",
    "colour": "blue",
    "stock": 1,
    "image_url": "https://tascani.vteximg.com.br/arquivos/ids/161468-340-510/jean-slim-tiana-2.jpg"
  },
  "best_offer": {
    "price": 3000,
    "user_id": 40
  },
  "close_at": 1529856667,
  "tags": ["fashion", "jeans", "free_shipment"],
  "seller": {
    "id": 1,
    "company_name": "Tascani"
  },
  "price": 3000
}
```
