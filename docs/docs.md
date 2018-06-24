# Documentación

## JSON Payloads:

#### JSON de Comprador (Viejo, ip debe reemplazarse por el objeto con 3 url)
``` json
{
  "name": "buyer_name",
  "ip": "127.0.0.1:5000", 
  "tags": ["cats", "dogs"]
}
```

#### JSON de Oferta (Viejo, hay que ver si se agrega el id o nombre del que oferta)
``` json
{
  "price": 2700,
  "duration": 400,
  "json": {"name": "a table", "country": "Argentina"},
  "tags": ["wood"]
}
```

#### JSON de notificación de nueva oferta
 ``` json
 {
   "bid_id": "d351ea12",
   "bid_json": {
     "duration": 400,
     "json": {"name": "a table", "country": "Argentina"},
     "tags": ["wood"]
   }
 }
 ```
 
 #### JSON de notificación de subasta terminada.
 ``` json
 {
   "bid_id": "d351ea12",
   "state": {"type": "you won", "money": 200}
 }
 ```
 
 #### JSON de Nuevo Precio
 ```json
 {
   "bid_id": "d351ea12",
   "price": 23.3
 }
 ```
