# Codex Tools

<div align="center">

[![Typing SVG](https://readme-typing-svg.demolab.com/?font=Fira+Code&size=22&pause=1000&color=A6E3A1&center=true&vCenter=true&width=620&lines=Universal+App+Hosting+for+Pterodactyl;Node.js+%C2%B7+Python+%C2%B7+PHP;Browser+Automation+Ready;Deploy+with+Git+%C2%B7+Backup+%C2%B7+Web+Terminal)](https://github.com/fidzzcodex-me/codex-tools)

[![Build and Push Docker Image](https://github.com/fidzzcodex-me/codex-tools/actions/workflows/docker-build.yml/badge.svg)](https://github.com/fidzzcodex-me/codex-tools/actions/workflows/docker-build.yml)
[![Docker Image](https://img.shields.io/badge/ghcr.io-codex--tools-89B4FA?logo=docker&logoColor=white)](https://github.com/fidzzcodex-me/codex-tools/pkgs/container/codex-tools)
[![Node.js](https://img.shields.io/badge/Node.js-18%20%7C%2020%20%7C%2022-A6E3A1?logo=node.js&logoColor=white)](#bahasa-dan-runtime-yang-didukung)
[![Python](https://img.shields.io/badge/Python-3.11%20%7C%203.12%20%7C%203.13-F9E2AF?logo=python&logoColor=white)](#bahasa-dan-runtime-yang-didukung)
[![PHP](https://img.shields.io/badge/PHP-8.1%20%7C%208.2%20%7C%208.3%20%7C%208.4-CBA6F7?logo=php&logoColor=white)](#bahasa-dan-runtime-yang-didukung)
[![Pterodactyl Egg](https://img.shields.io/badge/Pterodactyl-Egg-F38BA8?logo=docker&logoColor=white)](egg-codex-tools.json)

</div>

Docker image dan Pterodactyl egg untuk hosting aplikasi apa saja dalam satu image: Node.js, Python, atau PHP, lengkap dengan dukungan browser automation, deployment via Git, process management, backup otomatis, dan akses terminal langsung dari browser. Runtime terdeteksi otomatis dari Startup Command yang kamu isi, tidak perlu pilih image terpisah untuk tiap bahasa.

## Daftar Isi

- [Kegunaan](#kegunaan)
- [Bahasa dan Runtime yang Didukung](#bahasa-dan-runtime-yang-didukung)
- [Browser Automation](#browser-automation)
- [Mode Hosting](#mode-hosting)
- [Deployment](#deployment)
- [Process Management](#process-management)
- [Backup Otomatis](#backup-otomatis)
- [Cron Job](#cron-job)
- [Web Terminal](#web-terminal)
- [Cloudflare Tunnel](#cloudflare-tunnel)
- [Notifikasi Webhook](#notifikasi-webhook)
- [Console dan Monitoring](#console-dan-monitoring)
- [Referensi Environment Variable](#referensi-environment-variable)
- [Cara Kerja Startup](#cara-kerja-startup)
- [Troubleshooting](#troubleshooting)
- [Struktur Proyek](#struktur-proyek)

## Kegunaan

Codex Tools dibuat untuk operator hosting yang ingin menyediakan satu jenis server di panel Pterodactyl, tapi tetap fleksibel untuk berbagai jenis aplikasi: bot, API, scraper, website, atau automation tool. Semua tools yang biasanya perlu di-setup manual satu per satu (browser automation, backup, tunnel, cron, terminal) sudah tersedia bawaan dan tinggal diaktifkan lewat variable di panel, tanpa perlu masuk ke container secara manual.

## Bahasa dan Runtime yang Didukung

| Bahasa   | Versi Tersedia         | Terdeteksi dari Startup Command                  |
|----------|-------------------------|---------------------------------------------------|
| Node.js  | 18, 20, 22 (pilih salah satu) | `node`, `npm`, `npx`, `pnpm`, `yarn`         |
| Python   | 3.11, 3.12, 3.13         | `python3`, `python`                                |
| PHP      | 8.1, 8.2, 8.3, 8.4       | `php`, `artisan`                                   |

Dependency di-install otomatis berdasarkan file yang ditemukan di project:

- Node.js: `package.json` -> `npm ci`/`npm install`, atau `pnpm install`/`yarn install` kalau `INSTALL_DEPS` diisi sesuai
- Python: `requirements.txt` -> `pip install`
- PHP: `composer.json` -> `composer install`

Install ulang dependency ini terjadi setiap kali server di-restart, kecuali `SKIP_DEPS_INSTALL` diaktifkan.

## Browser Automation

Untuk kebutuhan scraping, bot, dan automation berbasis browser, sudah tersedia:

- **Playwright** (Chromium, Firefox, WebKit) untuk Python dan Node.js
- **Puppeteer**, **puppeteer-real-browser**, dan **puppeteer-extra** dengan **puppeteer-extra-plugin-stealth**
- **Camoufox** (fork Firefox anti-deteksi) lengkap dengan database GeoIP

Mode render diatur lewat `HEADLESS_MODE`:

- `true`: browser jalan headless, lebih hemat resource dan lebih cepat
- `false` (default): browser jalan headful lewat Xvfb (virtual display), rendering lebih mirip browser asli sehingga lebih sulit dideteksi sebagai bot, tapi lebih berat di CPU

Path binary browser (Chromium/Firefox/WebKit) diekspos otomatis lewat environment variable seperti `PUPPETEER_EXECUTABLE_PATH`, jadi script kamu tidak perlu hardcode lokasi binary.

## Mode Hosting

Selain menjalankan Startup Command sendiri, tersedia **Static Host Mode** (`STATIC_HOST_MODE=true`) untuk hosting situs statis (HTML/CSS/JS) tanpa perlu menulis server sama sekali. File cukup di-upload ke folder yang ditentukan lewat `STATIC_HOST_DIR` (default `public`), dan server otomatis melayani lewat `python3 -m http.server` di port `APP_PORT`.

## Deployment

Ada dua cara mengisi file aplikasi ke container:

1. **Upload manual** lewat File Manager panel (`USER_UPLOAD=true` untuk melewati proses git sama sekali)
2. **Clone dari Git** dengan mengisi `GIT_ADDRESS` (mendukung repo private lewat `USERNAME` + `ACCESS_TOKEN`, dan `BRANCH` tertentu)

Kalau `AUTO_UPDATE=true`, server otomatis `git pull` setiap kali direstart, jadi selalu menjalankan kode terbaru dari repo tanpa perlu upload ulang.

Kalau proses clone gagal (URL salah, token salah, repo private tanpa akses), server tetap menyala dan menampilkan pesan error yang jelas di console, bukan diam-diam gagal.

## Process Management

Aktifkan `PROCESS_MANAGER=true` supaya aplikasi otomatis restart sendiri kalau crash, tanpa perlu restart seluruh container/server:

- Node.js: dijalankan lewat **PM2** (`pm2-runtime`)
- PHP/Python/lainnya: dijalankan lewat **Supervisor**

## Backup Otomatis

Aktifkan `ENABLE_AUTO_BACKUP=true` untuk backup berkala seluruh isi `/home/container` ke folder `.codex/backups`, dengan interval yang diatur lewat `BACKUP_INTERVAL_HOURS` (default 24 jam). Hanya 5 backup terakhir yang disimpan.

Aktifkan tambahan `ENABLE_TELEGRAM_BACKUP=true` untuk mengirim salinan tiap backup ke Telegram lewat bot (perlu `TELEGRAM_BOT_TOKEN` dan `TELEGRAM_CHAT_ID`).

## Cron Job

`CRON_JOBS` menerima jadwal bergaya cron standar, satu baris per jadwal:

```
0 3 * * * curl https://situskamu.com/ping
```

Dicek setiap 20 detik oleh proses internal (bukan cron daemon sistem), sehingga tetap berjalan di filesystem read-only. Catatan: field jadwal saat ini hanya mendukung `*` atau angka pasti, belum mendukung koma, range, atau step (`*/5`, `1-5`, dan sejenisnya).

## Web Terminal

Aktifkan akses terminal langsung dari browser lewat `ENABLE_WEB_TERMINAL` (default aktif), diakses di `http://ip-server:WEB_TERMINAL_PORT` (default port `7681`) menggunakan `ttyd`. Login memakai basic auth (`WEB_TERMINAL_USER` / `WEB_TERMINAL_PASSWORD`).

Ini adalah sesi bash terpisah dari proses aplikasi utama. Perintah yang dijalankan (dan tombol Ctrl+C untuk menghentikannya) di sini sama sekali tidak memengaruhi status server utama, cocok untuk debugging atau menjalankan perintah manual tanpa risiko mematikan server.

**Wajib ganti `WEB_TERMINAL_PASSWORD` dari default (`changeme`) sebelum server diakses publik.** Peringatan otomatis akan muncul di console kalau password masih default.

## Cloudflare Tunnel

Aktifkan `ENABLE_CF_TUNNEL=true` dan isi `CF_TOKEN` (dari dashboard Cloudflare Zero Trust > Networks > Tunnels) untuk mengekspos server ke internet lewat Cloudflare Tunnel, tanpa perlu port forwarding manual.

## Notifikasi Webhook

Isi `WEBHOOK_URL` untuk mendapat notifikasi (Discord, Slack, atau layanan lain yang menerima payload JSON) setiap kali server start. Format payload bisa dikustomisasi lewat `WEBHOOK_PAYLOAD`, dengan placeholder `{event}`, `{server}`, `{ip}`, dan `{time}`.

## Console dan Monitoring

Console menampilkan panel status sistem saat boot (CPU, RAM, disk, uptime), status runtime yang terdeteksi (Node.js/Python/PHP), info akses aplikasi, dan konfigurasi startup sequence. Selama server berjalan, statistik CPU/RAM/disk dicetak ulang secara berkala lewat `LIVE_STATS_INTERVAL` (default 30 detik, isi `0` untuk mematikan).

Perlu diperhatikan: Ctrl+C di console utama panel Pterodactyl setara dengan menekan tombol Stop (dikonfigurasi lewat sinyal stop egg ini), karena console utama menampilkan proses aplikasi secara langsung. Untuk menjalankan dan menghentikan perintah secara interaktif tanpa risiko itu, gunakan Web Terminal.

## Referensi Environment Variable

### Aplikasi

| Variable | Default | Keterangan |
|---|---|---|
| `STARTUP_CMD` | `node index.js` | Perintah untuk menjalankan aplikasi |
| `STATIC_HOST_MODE` | `false` | Jalankan static file server, mengabaikan `STARTUP_CMD` |
| `STATIC_HOST_DIR` | `public` | Folder yang di-serve saat Static Host Mode aktif |
| `APP_PORT` | `3000` | Port yang didengarkan aplikasi |
| `NODE_VERSION` | `22` | Versi Node.js (18/20/22) |
| `PYTHON_VERSION` | `3.13` | Versi Python (3.11/3.12/3.13) |
| `PHP_VERSION` | `8.3` | Versi PHP (8.1/8.2/8.3/8.4) |
| `INSTALL_DEPS` | `npm` | Package manager Node.js (npm/pnpm/yarn) |
| `SKIP_DEPS_INSTALL` | `false` | Lewati install dependency saat restart |
| `PROCESS_MANAGER` | `false` | Auto-restart aplikasi lewat PM2/Supervisor |
| `HEADLESS_MODE` | `false` | Mode render browser automation |

### Deployment

| Variable | Default | Keterangan |
|---|---|---|
| `GIT_ADDRESS` | kosong | URL repo Git untuk clone otomatis |
| `USERNAME` | kosong | Username Git untuk repo private |
| `ACCESS_TOKEN` | kosong | Personal Access Token Git untuk repo private |
| `BRANCH` | kosong | Branch yang di-clone |
| `AUTO_UPDATE` | `false` | Git pull otomatis setiap restart |
| `USER_UPLOAD` | `false` | Lewati proses git, upload file manual |

### Backup

| Variable | Default | Keterangan |
|---|---|---|
| `ENABLE_AUTO_BACKUP` | `false` | Aktifkan backup otomatis |
| `BACKUP_INTERVAL_HOURS` | `24` | Interval backup dalam jam |
| `ENABLE_TELEGRAM_BACKUP` | `false` | Kirim backup ke Telegram |
| `TELEGRAM_BOT_TOKEN` | kosong | Token bot Telegram |
| `TELEGRAM_CHAT_ID` | kosong | Chat ID/User ID tujuan |

### Notifikasi dan Akses

| Variable | Default | Keterangan |
|---|---|---|
| `WEBHOOK_URL` | kosong | URL webhook notifikasi start server |
| `WEBHOOK_PAYLOAD` | kosong | Template payload JSON custom |
| `ENABLE_WEB_TERMINAL` | `true` | Aktifkan terminal browser (ttyd) |
| `WEB_TERMINAL_PORT` | `7681` | Port web terminal |
| `WEB_TERMINAL_USER` | `admin` | Username login web terminal |
| `WEB_TERMINAL_PASSWORD` | `changeme` | Password login web terminal (wajib diganti) |
| `ENABLE_CF_TUNNEL` | `false` | Aktifkan Cloudflare Tunnel |
| `CF_TOKEN` | kosong | Token Cloudflare Zero Trust Tunnel |

### Lain-lain

| Variable | Default | Keterangan |
|---|---|---|
| `CRON_JOBS` | kosong | Jadwal cron internal, satu baris per jadwal |
| `LIVE_STATS_INTERVAL` | `30` | Interval cetak ulang statistik di console (detik) |

## Cara Kerja Startup

Urutan yang terjadi setiap kali container start:

1. Wings menjalankan `/bin/bash /entrypoint.sh` sebagai proses utama
2. Semua script pendukung di `/scripts` di-load
3. Identitas console dan animasi boot ditampilkan
4. Repo di-clone/pull kalau `GIT_ADDRESS` diisi
5. Runtime (Node.js/Python/PHP) dideteksi dari `STARTUP_CMD`, dependency di-install
6. Web terminal, Cloudflare Tunnel, auto backup, webhook, dan cron job dijalankan sesuai konfigurasi
7. Pemeriksaan konfigurasi dijalankan, peringatan (password default, file startup tidak ditemukan, dan sejenisnya) ditampilkan di console
8. Panel status sistem dan runtime ditampilkan
9. Aplikasi (`STARTUP_CMD`) dijalankan sebagai proses akhir, langsung atau lewat PM2/Supervisor

Setiap kegagalan pada tahap manapun dicatat dengan jelas di console (baris berawalan `[boot] FATAL`), sehingga penyebab crash selalu terlihat, tidak pernah gagal secara diam-diam.

## Troubleshooting

**Server crash langsung dengan exit code 1, console kosong.** Penyebab paling umum adalah `STARTUP_CMD` menunjuk ke file yang belum ada di `/home/container` (misalnya `index.js` belum di-upload, atau clone Git gagal). Peringatan spesifik untuk kasus ini sudah otomatis muncul di bagian Config Warnings pada console.

**Firefox/browser automation terasa lambat.** Ini karakteristik bawaan mode headful (`HEADLESS_MODE=false`) yang me-render lewat Xvfb secara software, bukan bug. Set `HEADLESS_MODE=true` kalau situs target tidak memerlukan render visual asli untuk menghindari deteksi bot.

**Ctrl+C di console utama mematikan server.** Sesuai desain, karena console utama menampilkan proses aplikasi secara langsung dan Ctrl+C dikonfigurasi sebagai sinyal stop. Gunakan Web Terminal untuk sesi interaktif yang aman dari hal ini.

## Struktur Proyek

```
codex-tools-custom/
├── Dockerfile                  Image build: Node.js, Python, PHP, browser automation, tools pendukung
├── entrypoint.sh                Script utama yang dijalankan saat container start
├── egg-codex-tools.json         Definisi egg Pterodactyl (variable, startup command, docker image)
├── scripts/
│   ├── theme.sh                 Warna dan helper tampilan console
│   ├── identity.sh              Identitas shell (prompt, home, user)
│   ├── boot-animation.sh        Animasi dan logo saat boot
│   ├── sysinfo.sh                Pembacaan CPU/RAM/disk/uptime dari cgroup
│   ├── banner.sh                 Panel status sistem dan runtime di console
│   ├── config-check.sh           Pemeriksaan konfigurasi dan peringatan dini
│   ├── detect-runtime.sh        Deteksi runtime dan install dependency otomatis
│   ├── git-setup.sh              Clone/pull repository Git
│   ├── web-terminal.sh          Web terminal lewat ttyd
│   ├── tunnel.sh                  Cloudflare Tunnel
│   ├── backup.sh                  Backup otomatis ke folder dan Telegram
│   ├── webhook.sh                 Notifikasi webhook saat start
│   ├── cron-runner.sh            Scheduler cron internal
│   ├── live-stats.sh              Statistik berkala selama server berjalan
│   └── log-rotate.sh              Rotasi log otomatis
└── .github/workflows/
    └── docker-build.yml          Build dan push image otomatis ke GitHub Container Registry
```
