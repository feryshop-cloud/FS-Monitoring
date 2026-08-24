# FS-Monitoring (Prometheus + Grafana + Exporters)

Monitoring stack & observability untuk ekosistem **Feryshop** di VPS.

---

## 1. Komponen Stack & Container Images

Tersedia dalam bentuk **GitHub Container Registry (GHCR)** image atau dapat di-build langsung via Docker Compose:

| Service               | GitHub Container Image (GHCR)                 | Upstream Base                                   | Port Internal       | Peran                                 |
| --------------------- | --------------------------------------------- | ----------------------------------------------- | ------------------- | ------------------------------------- |
| **Prometheus**        | `ghcr.io/feryshop-cloud/fs-prometheus:latest` | `prom/prometheus:v2.51.0`                       | `:9090` (localhost) | TSDB & Scraper metrik                 |
| **Grafana**           | `ghcr.io/feryshop-cloud/fs-grafana:latest`    | `grafana/grafana:10.4.1`                        | `:3001` (localhost) | Visualisasi dashboard & alerts        |
| **Node Exporter**     | -                                             | `prom/node-exporter:v1.7.0`                     | `:9100` (internal)  | Metrik Host VPS (CPU, RAM, Disk, Net) |
| **Nginx Exporter**    | -                                             | `nginx/nginx-prometheus-exporter:1.1.0`         | `:9113` (internal)  | Metrik Trafik Gateway                 |
| **Postgres Exporter** | -                                             | `prometheuscommunity/postgres-exporter:v0.15.0` | `:9187` (internal)  | Metrik Supabase PostgreSQL            |

---

## 2. Cara Menjalankan di VPS

### Langkah 1: Siapkan Environment Variable

```bash
cd FS-Monitoring
cp .env.example .env
```

Edit file `.env`:

- Ganti `GRAFANA_ADMIN_PASSWORD` dengan password admin yang aman.
- Isi `SUPABASE_DB_URL` dengan connection string PostgreSQL Supabase Anda:
  ```env
  SUPABASE_DB_URL=postgresql://postgres:YOUR_PASSWORD@db.YOUR_PROJECT_REF.supabase.co:5432/postgres?sslmode=require
  ```

### Langkah 2: Jalankan Container

```bash
# Opsi A: Pull dan jalankan image dari GitHub Container Registry
docker compose up -d

# Opsi B: Build lokal dari Dockerfile
docker compose up -d --build
```

---

## 3. GitHub Actions CI/CD (GHCR Images)

Repository ini dilengkapi dengan GitHub Actions workflow [`.github/workflows/docker-publish.yml`](.github/workflows/docker-publish.yml) yang otomatis mem-build dan mem-push image ke GitHub Packages (GHCR) setiap kali ada commit ke branch `main` atau pembuatan release tag:

- `ghcr.io/feryshop-cloud/fs-prometheus:latest`
- `ghcr.io/feryshop-cloud/fs-grafana:latest`

---

## 4. Mengakses Grafana & Dashboard

1. Buka browser: `http://<IP_VPS_ANDA>:3001` (atau via reverse proxy domain, misal `monitor.feryshop.com`).
2. Login menggunakan kredensial dari `.env`:
   - **User:** `admin`
   - **Password:** Sesuai `GRAFANA_ADMIN_PASSWORD` di `.env`
3. Datasource Prometheus sudah terpasang otomatis (_auto-provisioned_).

---

## 5. Rekomendasi Dashboard Siap Pakai (Import ID)

Di Grafana, klik menu **Dashboards** → **New** → **Import**, lalu masukkan ID dashboard komunitas:

1. **Host VPS (Node Exporter Full):** Dashboard ID **`1860`**
2. **Nginx Reverse Proxy:** Dashboard ID **`12708`**
3. **PostgreSQL / Supabase:** Dashboard ID **`9628`**
4. **Node.js Application (Next.js):** Dashboard ID **`11159`**
