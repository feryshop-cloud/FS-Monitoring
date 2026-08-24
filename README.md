# FS-Monitoring (Prometheus + Grafana + Loki + Exporters)

Full-stack observability (Metrik & Log Agregator) untuk ekosistem **Feryshop** di VPS.

---

## 1. Komponen Stack

| Service               | Container Name               | Port Internal       | Peran                                                        |
| --------------------- | ---------------------------- | ------------------- | ------------------------------------------------------------ |
| **Prometheus**        | `feryshop-prometheus`        | `:9090` (localhost) | TSDB & Scraper metrik dari seluruh target                    |
| **Grafana**           | `feryshop-grafana`           | `:3001` (localhost) | Visualisasi dashboard, live log search & alerts              |
| **Loki**              | `feryshop-loki`              | `:3100` (internal)  | Log aggregation engine (menyimpan & mengindeks JSON logs)    |
| **Promtail**          | `feryshop-promtail`          | `:9080` (internal)  | Log shipper (mengumpulkan log dari seluruh container Docker) |
| **Node Exporter**     | `feryshop-node-exporter`     | `:9100` (internal)  | Metrik Host VPS (CPU, RAM, Disk, Net)                        |
| **Nginx Exporter**    | `feryshop-nginx-exporter`    | `:9113` (internal)  | Metrik Trafik Gateway (RPS, status code)                     |
| **Postgres Exporter** | `feryshop-postgres-exporter` | `:9187` (internal)  | Metrik Supabase PostgreSQL                                   |

---

## 2. Cara Menjalankan di VPS

### Langkah 1: Siapkan Environment Variable

```bash
cd FS-Monitoring
cp .env.example .env
nano .env
```

### Langkah 2: Jalankan Container

```bash
docker compose up -d
```

---

## 3. Fitur Live Log Search di Grafana (Loki)

Setelah login ke Grafana (`http://<IP_VPS>:3001`), buka menu **Explore** dan pilih datasource **Loki**.

### Contoh Query LogQL yang Berguna:

1. **Lihat Log Error Realtime di Seluruh Aplikasi:**

   ```logql
   {container=~"fs-storefront|fs-admin-dashboard"} | json | level="error"
   ```

2. **Lacak Jejak Request Berdasarkan `requestId` (Correlation ID):**

   ```logql
   {container=~"fs-storefront|fs-admin-dashboard|fs-gateway"} | json | requestId="a1b2c3d4-xxxx-xxxx"
   ```

3. **Cari Request API yang Lambat (> 500ms):**

   ```logql
   {container="fs-storefront"} | json | durationMs > 500
   ```

4. **Tampilkan Log Nginx Gateway dengan Status HTTP 5xx:**
   ```logql
   {container="fs-gateway"} | json | status >= 500
   ```

---

## 4. Rekomendasi Dashboard Grafana Siap Pakai (Import ID)

Buka menu **Dashboards → New → Import**, masukkan ID berikut:

| Kebutuhan Monitoring               | ID Dashboard Grafana Resmi                 |
| ---------------------------------- | ------------------------------------------ |
| **Host VPS (CPU, RAM, Disk, Net)** | **`1860`** _(Node Exporter Full)_          |
| **Trafik & Status HTTP Nginx**     | **`12708`** _(Nginx Exporter)_             |
| **Performa Supabase PostgreSQL**   | **`9628`** _(PostgreSQL Database)_         |
| **Aplikasi Node.js / Next.js**     | **`11159`** _(NodeJS Application Metrics)_ |
| **Docker Container Monitoring**    | **`10619`** _(Docker and OS metrics)_      |
