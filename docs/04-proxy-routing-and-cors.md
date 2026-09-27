# EpicBook: Reverse-Proxy Routing and CORS

Prepared by Oluwagbade Odimayo. Selected reverse proxy: **Nginx**.

## Routes

| Path | Destination | Purpose |
|---|---|---|
| `/assets/` | frontend:8080 | Static CSS, JavaScript and images |
| `/api/` | backend:8080 | JSON API (cart) |
| `/health` | backend:8080 | Application and database health |
| `/proxy-health` | Nginx itself | Proxy liveness for its Docker health check |
| `/` (everything else) | backend:8080 | Server-rendered application pages |

Nginx resolves `backend` and `frontend` through Docker's DNS (`127.0.0.11`) at request time, so a container that restarts with a new IP address is found without reloading the proxy. Only the reverse proxy publishes a port (80); the frontend, backend and database are reachable only on the internal Docker networks.

## Was CORS required?

No. The browser loads every page, asset and API call from the same origin, `http://<VM public IP>`, and the reverse proxy forwards each path to the right container behind the scenes. Because the scheme, host and port never change, the browser never makes a cross-origin request, so the backend needs no CORS headers. CORS would only be needed if the API were served from a different origin, for example a separate host or port, as in the Book Review App in Assignment 6.
