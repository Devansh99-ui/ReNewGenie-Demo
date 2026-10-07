# ReNewGenie Demo

Interactive demo page for **ReNewGenie: AI-Powered Assistant for Smart Recycling, Reuse and Carbon Reduction**, a B.Tech CSE (AI/ML) final-year project at Ajay Kumar Garg Engineering College, Ghaziabad (Group ID 26CSEAIML/1/GID-16, supervisor Dr. Jaishree Jain).

Main project code: https://github.com/mrgauravshukla81/ReNewGenie

## See it

![Guided tour](docs/img/tour.gif)

| | |
|---|---|
| ![Home](docs/img/01-home.png) | ![Live demo on Home](docs/img/02-home-live-demo.png) |
| ![Classifier with heat-map](docs/img/03-classifier.png) | ![Marketplace](docs/img/04-marketplace.png) |
| ![Trading tools](docs/img/05-trading-tools.png) | ![Carbon credit portfolio](docs/img/06-carbon-portfolio.png) |
| ![Price forecast](docs/img/07-forecast.png) | ![Centre map](docs/img/08-centres-map.png) |

## What is in the demo
A static site (`index.html`, `style.css`, `app.js`, `data/`; no build step):
- **Classifier** (Module 1): two real models read your photo in the browser (86.8% on 380 held-out TrashNet photos), with a **heat-map** of what the CNN looked at, a **"not sure"** state below 60% confidence, and a note on how reliable each confidence level was on held-out photos
- **Vision tools**: region scan (the classifier on 14 overlapping crops, merged; a pseudo-detector, not a trained one), batch mode for up to 40 photos with CSV export, and live camera
- **Guide** (Module 2): recycling education hub
- **Marketplace** (Module 3): 17 scrap grades priced from real Delhi reference rates, condition deductions, fees, collector profiles, booking, order tracker, receipt, market intelligence, and (inside Claude) a **shared community board**
- **Carbon credits**: route finder (CCTS, plastic and e-waste EPR, Verra), credit calculator, EPR value band, deal simulator, project integrity scorecard and a case file of documented failures
- **Trading tools**: price-risk card, sealed-bid auction simulator, exact shortest pick-up route (brute force up to 8 stops, otherwise nearest-neighbour + 2-opt) and a Monte Carlo carbon-credit portfolio simulator (all teaching simulations on illustrative assumptions)
- **Analytics**: impact log as charts, plus a scenario simulator
- **User tour**: a 9-step guided walkthrough (button on Home, or Ctrl K)
- **Price forecast**: three methods with rolling backtests and honest ranges, on real world metal prices or your own series
- **Centres** (Module 4): 182 Delhi-NCR places on one map
- **Impact tracker**, **Reuse ideas** (keyword + meaning search over 36 ideas), **Lifespan**
- **AI assistant** and AI helpers (inside Claude only)
- **Project report**: architecture, tools, training results with confusion matrix and learning curve, security, SDGs, limitations

Docs: `docs/MODEL_REPORT.md` (results, confusion matrix, honest limits), `docs/DATA_COLLECTION.md` (how to collect Indian waste photos), `docs/BACKEND.md` + `backend/supabase_schema.sql` (adding real accounts; schema not yet run). The classifier also has **Was this right?** buttons that save corrections as an exportable CSV. See `docs/ARCHITECTURE.md` for how it fits together, `tests/` for the tests, and `notebooks/` for the Colab notebooks (VGG16 transfer learning with Grad-CAM; YOLO multi-item detection; fine-tuning on your own photos). The notebooks were written without a GPU; run them and report only the numbers they print.

## Prototype features
Impact tracker, Reuse ideas and Lifespan are prototypes built for this demo from the report's section 5.2.3. They are not in the original GitHub code. CO2e factors are indicative US EPA WARM values (via Nebraska DWEE 2025 analysis), not India-specific. Sample log entries are flagged "sample". No accuracy or BLEU/ROUGE scores are claimed for them.

## The classifier
Your VGG16 file (`classifyWaste.h5`) is not in the GitHub repo, so this demo ships two smaller models I trained on the same TrashNet photos (2,527 images, split by photo 70/15/15):
- a CNN trained from scratch (TensorFlow, 83.4% on the 380 held-out photos), run by hand-written JavaScript in `app.js`
- an ensemble of 5 small neural networks on 453 hand-built image features (81.8%)
- the demo averages both (0.6 CNN + 0.4 features): 86.8%, macro F1 0.84

One split only, and only 16 photos for the Trash class, so treat the numbers as indicative. Training scripts are in `training/`.

## Real data in the marketplace and carbon pages
- Reference scrap rates for 20 materials from public Delhi price lists (scraprates.in, 6 Oct 2026; Delhi Kabadiwala, undated). Grades without a list price are tagged as estimates.
- Plastic EPR indicative prices (Enviraj, 23 Jul 2025) and e-waste EPR floor prices from trade explainers, not legal texts.
- Case file of 7 documented carbon-credit problems (Guardian 2023 on Verra rainforest credits, C-Quest, ICVCM cookstove review, Philippine plastic credits and others) and an 8-question project integrity scorecard.
- Collector names, ratings and fees stay demo data. Credit price, fixed cost and fee share are labelled assumptions you can edit. India CCTS trading dates should be checked before relying on them.

## AI assistant (needs Claude access)
When the page is opened as a Claude artifact, an AI assistant tab, a photo second opinion, AI reuse ideas and a credit project reviewer appear. They use the viewer's own Claude access and ask for consent on first use. Outside Claude they are hidden and everything else still works. They were tested locally only with a mock.

## Location data
Pins are at town or locality level, not street addresses, because the DPCC list gives only the town. Each Google Maps button searches by name. Marketplace orders are not sent anywhere. `training/build_places.py` rebuilds `data/places.js`.

## Marketplace and carbon-credit notes
Collector names and base rates are your project's sample data. Grade multipliers, deductions, ratings and response times are indicative estimates for the demo, not live quotes. In the Carbon credits tab, figures marked "assumption" (credit price, fixed cost, fee share) are editable placeholders. Rule summaries come from trade explainers and the Verra FAQ linked on the page; read the official notifications before relying on them.

## Run it
Open `index.html` in a browser. Tests: `npm test` (Node 16+) and `python3 tests/smoke.py` (needs Playwright).

The forecast tab uses World Bank monthly metal prices that end in June 2017 (via the open datasets/commodity-prices repository); it demonstrates the method, not today's market.

## Host it free (GitHub Pages)
Repo Settings > Pages > Deploy from a branch > `main` / root. Link: `https://<your-username>.github.io/<repo-name>/`.

## Team
Gaurav Shukla, Anchal Singh, Devansh Tomar, Abhisekh Chaurasiya
