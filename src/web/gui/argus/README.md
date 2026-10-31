# Argus console

A single, self-contained HTML page that the Netdata Agent serves at `http://<agent>:19999/argus/`.
It shows live charts, alerts and nodes using only the Agent's own `/api/v3` endpoints.

## What it shows

- **Overview**: per-second charts for the selected node.
  - Starts with `system.cpu`, `system.ram`, `system.io`, `system.net`, `system.load` and `system.processes`.
  - **Add chart** searches every chart the node collects (from `/api/v3/contexts`) by name, context or family. The `×` on a card removes it, and **Reset charts** restores the defaults. The choice is saved in the browser (`localStorage`), per browser rather than per Agent.
  - **Hide zero lines** (on by default) asks the Agent to drop dimensions that are zero for the whole window (`options=nonzero`). When every dimension is zero, the Agent keeps them all, so a chart never goes blank because of this option.
  - Titles, units, dimensions and chart type come from the Agent's response, not from the page.
  - Hovering one chart lines up every chart at the same moment.
  - The strip under each chart is the ML anomaly rate (`arp`) of each point. When ML is disabled on the node, the summary says "ML off".
  - "Agent query" on each card shows the exact request the page sends.
- **Alerts**: alert instances from every node this Agent knows about.
  - Status tabs (Raised, Critical, Warning, Clear, All) show counts for the current node and search filters.
  - Filter by node, and search alert name, chart or summary.
  - Selecting a row switches to that node, adds the alert's chart to the overview if it is missing, and highlights it.
- **Nodes**: this Agent plus every child streaming to it. Selecting a row opens its charts.

## API calls

All calls are same-origin and relative to the page, so the console also works behind a reverse proxy that serves the Agent under a sub-path.

| Endpoint | Used for | Frequency |
|---|---|---|
| `/api/v3/data?scope_nodes=…&scope_contexts=…&after=-N&points=…&time_group=average&group_by=dimension&format=json2[&options=nonzero]` | one request per chart | every second while the tab is visible and Live is on |
| `/api/v3/nodes` | node list, health, versions | every 5 seconds, every second on the Nodes view |
| `/api/v3/alerts?options=instances,values` | alert table, status counts and badge | every 5 seconds, every second on the Alerts view |
| `/api/v3/contexts?scope_nodes=…&options=titles` | chart list for **Add chart** | once per node, when the picker opens |

Polling stops while the browser tab is hidden. Every request has a 5 second deadline, so a stalled Agent shows an error banner instead of a frozen page.

## Design constraints

- **No external resources.** No CDN scripts, web fonts or images. Agents often run without internet access, and the page must not make requests outside the Agent.
- **No new backend code.** The console relies on the existing `/api/v3` endpoints and their access rules. If bearer protection is enabled, the API answers HTTP 412 (or 401/403) and the page explains that instead of showing empty charts.
- **Escaping.** Every string that comes from the API (node names, alert names, summaries) is HTML-escaped before it is inserted into the page.

## Installation

The page is installed with the `netdata` component by the rule in `CMakeLists.txt`, next to the Swagger files, to `${WEB_DEST}/argus/index.html`. It does not depend on `ENABLE_DASHBOARD`, so it is available even when the main dashboard bundle is not downloaded.

## Testing changes

Build and run an Agent, then copy the file into its web directory and open `/argus/`:

```sh
cp src/web/gui/argus/index.html <web directory>/argus/index.html
```

Check the three views, a node with no `system.io` (the card should say "No data"), and stop the Agent while the page is open (the banner should appear, then clear when the Agent is back).
