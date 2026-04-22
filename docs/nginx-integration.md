# Nginx-Integration fuer Vexa auf goproto.goecloud.eu

Diese Integration setzt Vexa gemaess offizieller Doku als API-Gateway auf Port `8056` hinter Nginx.
Zusatz: Das Vexa-Dashboard wird unter `/dashboard/` auf Port `3001` weitergeleitet.

Referenzen:
- `https://github.com/Vexa-ai/vexa` (Quickstart, API Gateway auf `8056`)
- `https://raw.githubusercontent.com/Vexa-ai/vexa/main/deploy/compose/README.md` (Compose-Deployment)

## 1) Vexa starten

Auf dem Linux-Host:

```bash
git clone https://github.com/Vexa-ai/vexa.git
cd vexa/deploy/compose
make all
```

Danach pruefen:

```bash
curl -fsS http://127.0.0.1:8056/docs >/dev/null && echo "API Gateway OK"
```

## 2) Nginx aktivieren

Im Repo:

```bash
chmod +x scripts/setup-nginx-vexa.sh
DOMAIN=goproto.goecloud.eu API_UPSTREAM=127.0.0.1:8056 DASHBOARD_UPSTREAM=127.0.0.1:3001 ./scripts/setup-nginx-vexa.sh
```

Das Skript installiert bei Bedarf `nginx` und `gettext-base`, rendert die Config aus
`scripts/nginx-vexa.conf.template`, aktiviert sie und reloadet Nginx.

## 3) API-Base im Bot-Skript setzen

In `.env`:

```dotenv
API_BASE=https://goproto.goecloud.eu
```

Danach kann der Bot wie gewohnt gestartet werden:

```bash
./scripts/teams-bot-example.sh
```

## 4) Schnelle Verifikation

```bash
curl -I https://goproto.goecloud.eu/docs
curl -I https://goproto.goecloud.eu/dashboard/
```

Wenn `/docs` erreichbar ist, laeuft der Vexa API-Gateway korrekt ueber die Internet-Domain.

## TLS-Hinweis (empfohlen)

Falls HTTPS noch nicht durch eine bestehende Edge/Ingress-Konfiguration aktiv ist, danach Let's Encrypt aktivieren:

```bash
sudo apt-get install -y certbot python3-certbot-nginx
sudo certbot --nginx -d goproto.goecloud.eu
```
