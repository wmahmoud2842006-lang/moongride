# MoonGride — Lunar South Pole Mission Analysis
## Windows Local Development & Deployment Guide

MoonGride is an advanced web application engineered for lunar landing site evaluation, surface terrain analysis, solar illumination modeling, and Earth communication visibility at the Lunar South Pole (-80°S to -90°S).

---

## 1. Quick Start (1-Click Launch)

To start the complete application and launch your default web browser automatically:

### Option A: Windows Command Prompt / Double-Click
Double-click or run from Command Prompt:
```cmd
start-local.bat
```

### Option B: Windows PowerShell
Run with PowerShell:
```powershell
.\start-local.ps1
```

The script will:
1. Verify the portable PHP 8.3 runtime and Python 3 environment.
2. Configure the GDAL bridge binary path (`tools\bin`).
3. Start the PHP built-in web server on `http://127.0.0.1:8000`.
4. Automatically open your default web browser to the MoonGride mission interface.

---

## 2. System Architecture

```
[ Web Browser ]
      |
      v  HTTP / REST (Port 8000)
[ PHP 8.3 Built-in Server / public/api.php ]
      |
      +---> [ Controllers & Validation ]
      |         |
      |         +---> [ MissionAnalysisService ]
      |         +---> [ LandingSiteEvaluationService ]
      |         +---> [ MissionRiskEvaluationService ]
      |
      +---> [ LunarTerrainService & TerrainHorizonService ]
      |         |
      |         +---> [ GdalFinder -> tools/bin/gdallocationinfo.exe ]
      |                     |
      |                     v (Pillow / NumPy Bounded-Tile Query)
      |               [ NASA LOLA BigTIFF Rasters ]
      |               (Elevation, Slope, Roughness in IAU:30135)
      |
      +---> [ JplHorizonsService & EarthHorizonsService ]
                |
                v  HTTPS (SSL verified via cacert.pem)
            [ NASA JPL Horizons API ]
            (Sun & Earth Vector Ephemerides)
```

### Technology Stack:
- **Frontend**: Vanilla ES6 JavaScript modules, HTML5 Canvas, modern CSS3 with custom variables.
  - **Three.js (r170)**: Procedural 3D mesh reconstruction from 80m LOLA DEM samples.
  - **Chart.js (v4.4.7 ESM)**: Time-series solar elevation angles.
  - **2D Canvas**: Polar 360-degree radial terrain horizon obstruction profile.
- **Backend**: PHP 8.3.36 ZTS (PSR-4 autoloading via Composer).
  - Strict scalar types (`declare(strict_types=1);`).
  - Modular service architecture (`Criteria`, `Evaluation`, `Support`, `Controllers`).
- **Geospatial Engine**:
  - Native Windows wrapper binaries (`gdallocationinfo.exe`, `gdaltransform.exe`) compiling C# proxies (`csc.exe`) over high-speed Python/Pillow BigTIFF tile decoders.
  - Bounded-box tile extraction caching: reduces 16-point radial horizon decompressions from ~60s down to ~1.3s.
- **Ephemeris Data**:
  - Live NASA JPL Horizons REST API client with SSL certificate chain verification.

---

## 3. Manual Server Execution

If you prefer starting the server manually in a specific terminal:

```cmd
.\php\php.exe -S 127.0.0.1:8000 -t test\lunar-south-pole-backend\public
```

Then visit:
```
http://127.0.0.1:8000/index.html
```

---

## 4. API Endpoints

The single entry-point controller is `public/api.php`, routing requests via the `route` query parameter:

| Route | Method | Description | Sample Request |
| :--- | :--- | :--- | :--- |
| `data-sources` | `GET` | Health check and raster metadata | `/api.php?route=data-sources` |
| `terrain` | `POST` | Single-point elevation, slope, and roughness | `{"longitude": 0.0, "latitude": -89.0}` |
| `horizon` | `POST` | Radial terrain horizon angles | `{"longitude": 0.0, "latitude": -89.0, "radius_km": 50}` |
| `solar-visibility` | `POST` | Solar line-of-sight against terrain horizon | `{"longitude": 0.0, "latitude": -89.0, "date_time": "2026-03-01T00:00:00Z"}` |
| `landing-site` | `POST` | Landing site safety, area, and solar analysis | `{"longitude": 0.0, "latitude": -89.0, "radius_m": 500}` |
| `mission-analysis` | `POST` | Comprehensive end-to-end mission pipeline | `{"longitude": 0.0, "latitude": -89.0, "date_time": "2026-03-01T00:00:00Z"}` |
| `site-comparison` | `POST` | Comparative evaluation across multiple candidate sites | `{"sites": [{"longitude": 0.0, "latitude": -89.0}, ...]}` |

---

## 5. Verification & Test Suite

An automated test suite is provided to verify all core services, criteria, evaluations, and end-to-end pipelines.

To run the complete test suite:
```cmd
.\php\php.exe test\lunar-south-pole-backend\tests\run_all_tests.php
```

All 24 test suites test:
1. `test_api.php`: API endpoint routing and JSON response formatting.
2. `test_communication_criteria.php`: Earth visibility and communication window evaluations.
3. `test_data_confidence.php`: LOLA DEM and JPL Horizons data provenance scoring.
4. `test_earth_horizons.php`: NASA JPL Horizons Earth ephemeris vectors.
5. `test_earth_terrain_horizon.php`: 360-degree terrain horizon profiling.
6. `test_earth_visibility.php`: Earth center occultation against local terrain.
7. `test_full_mission.php`: Complete multi-step mission analysis workflow.
8. `test_horizons.php`: NASA JPL Horizons solar ephemeris retrieval.
9. `test_horizon_api.php`: Terrain horizon API endpoint.
10. `test_illumination_criteria.php`: Solar visibility criteria scoring.
11. `test_landing_site_api.php`: Landing site API endpoint.
12. `test_landing_site_evaluation.php`: Multi-criteria site safety evaluation.
13. `test_lunar_area.php`: Radial area circular sampling (120 points).
14. `test_mission_risk_evaluation.php`: Mission risk matrix and severity scoring.
15. `test_safety_evaluation.php`: Safety classification engine.
16. `test_science_criteria.php`: Science potential metrics.
17. `test_science_evaluation.php`: Science evaluation engine.
18. `test_site_comparison.php`: Cross-site candidate comparison.
19. `test_site_ranking.php`: Landing site ranking algorithm.
20. `test_solar_visibility.php`: Solar line-of-sight calculations.
21. `test_solar_visibility_api.php`: Solar visibility API endpoint.
22. `test_terrain.php`: Point elevation, slope, and roughness sampling.
23. `test_terrain_api.php`: Point terrain API endpoint.
24. `test_terrain_criteria.php`: Surface slope and roughness criteria checks.

---

## 6. Directory Structure

```
c:\Users\YA\Downloads\test\
|-- php\                                # Portable PHP 8.3.36 runtime
|   |-- php.exe
|   |-- php.ini                         # Configured with curl, openssl, mbstring, gd
|   `-- extras\ssl\cacert.pem           # CA bundle for JPL Horizons HTTPS verification
|-- tools\bin\                          # Windows GDAL bridge executables
|   |-- gdallocationinfo.exe
|   |-- gdaltransform.exe
|   |-- gdal_translate.exe
|   `-- gdalinfo.exe
|-- start-local.bat                     # Windows Command Prompt 1-click launcher
|-- start-local.ps1                     # PowerShell 1-click launcher
|-- README_WINDOWS_SETUP.md             # This documentation
`-- test\lunar-south-pole-backend\
    |-- app\
    |   |-- Controllers\                # API Request handlers
    |   |-- Services\                   # Domain services (Terrain, Horizons, Mission)
    |   |   |-- Criteria\               # Terrain, Illumination, Science, Communication
    |   |   `-- Evaluation\             # Safety, Risk, Ranking, Comparison
    |   `-- Support\                    # GdalFinder, GDAL Python bridge
    |-- config\                         # Evaluation thresholds & criteria
    |-- public\                         # Web document root
    |   |-- index.html                  # Main application UI
    |   |-- api.php                     # API router
    |   |-- css\styles.css              # Responsive styles
    |   `-- js\                         # Vanilla ES modules (app, ui, 3D, 2D)
    |-- storage\rasters\                # BigTIFF LOLA elevation, slope, roughness
    `-- tests\                          # 24 automated PHP test suites
```

---

## 7. Troubleshooting

- **Port 8000 already in use**:
  Modify port in `start-local.bat` or `start-local.ps1` from `8000` to `8080`, or terminate the conflicting process using:
  ```powershell
  Stop-Process -Id (Get-NetTCPConnection -LocalPort 8000).OwningProcess -Force
  ```
- **NASA JPL Horizons API timeout**:
  The JPL Horizons API server occasionally experiences transient load spikes. The application includes connection timeouts, fallback handling, and clear error messaging in `JplHorizonsService.php`.
- **GDAL raster access**:
  The application automatically locates the bridge binaries in `tools\bin` via `App\Support\GdalFinder`. If OSGeo4W is installed at `C:\OSGeo4W\bin`, `GdalFinder` will also automatically detect and use it as an available backend.
