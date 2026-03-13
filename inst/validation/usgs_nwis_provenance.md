# USGS NWIS Validation Provenance

- Retrieval timestamp: `2026-03-13 23:06:31 +0530`
- Source service: `USGS NWIS Water Services`
- Site service endpoint: `https://waterservices.usgs.gov/nwis/site/?format=rdb&sites=01491000,01646500,05584500&siteOutput=expanded`
- Parameter code: `00060` (discharge)
- Statistic code: `00003` (daily mean)
- Units retained from NWIS: `cubic feet per second`
- Date window: `2016-01-01` to `2020-12-31`

## Fixed Station Set

- `01491000`: CHOPTANK RIVER NEAR GREENSBORO, MD
- `01646500`: POTOMAC RIVER NEAR WASH, DC LITTLE FALLS PUMP STA
- `05584500`: LA MOINE RIVER AT COLMAR, IL

## Retrieval Logic

- One site-service request is used to resolve station metadata.
- One daily-values request is issued per station using NWIS `dv` output in `rdb` format.
- The query requests parameter `00060` and statistic `00003` only.
- No raw NWIS response files are committed; only derived manifest and summary artifacts are written.

## Processing

- Daily mean discharge values are kept in the original NWIS units (cfs).
- Qualification codes are retained only as summary counts of approved and estimated days.
- Missing or non-numeric daily values are dropped before the observed-series summaries and benchmark scenarios are computed.

## Benchmark Comparison Scenarios

- `identity`: simulated series equals observed series.
- `bias_plus10`: simulated series equals `1.10 * obs`.
- `smooth_cycle`: simulated series adds a deterministic sinusoidal perturbation with amplitude `0.10 * sd(obs)` and is truncated at zero.
- `seasonal_scale`: simulated series applies a fixed seasonal multiplier of `1.15` for April-September and `0.90` otherwise, truncated at zero.

These are benchmark scenarios derived from real observed NWIS series. They are not external model outputs.

## Metric Scope

- `nse`
- `kge`
- `rmse`
- `pbias`
- `mae`
- `ve`
