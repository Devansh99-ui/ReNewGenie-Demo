# How ReNewGenie Demo is built

One static page, no server, no build step. Everything below runs in the browser.

```
index.html ─ style.css
   └─ app.js  (all behaviour)
        ├─ data/model.js          feature-MLP weights (5 networks, fp16)
        ├─ data/cnn_model.js      CNN weights + training curve
        ├─ data/samples.js        6 held-out TrashNet photos
        ├─ data/embeddings.js     64-d word vectors for reuse search
        ├─ data/forecast_data.js  6 metal price series (1980-2017)
        └─ data/places.js         182 Delhi NCR places
```

## 1. Waste classifier (Module 1)
| Stage | What happens | Where |
|---|---|---|
| Photo | resized twice: 256×192 for the feature model, 192×144 → 96×72 for the CNN | `go` click handler |
| Feature MLP | 453 hand-built features (colour histogram, gradient orientations, edges, 8×6 thumbnail) → 5 small networks averaged | `CLF` |
| CNN | 8 conv layers (BatchNorm folded in), global average pool, dense; run on the photo and its mirror | `CNN.predict` |
| Ensemble | 0.6 × CNN + 0.4 × MLP | go handler |
| Trust | confidence band lookup (`CALIB`) and "not sure" below 60% | `calibBand` |
| Heat-map | `CNN.cam`: class activation map. Exact because the net ends in global average pooling + one dense layer | `drawCam` |

Training scripts: `training/` (`train2.py` features, `cnn_train.py` CNN, `cnn_export.py` ensemble weight + fixtures, `calibration.py`).
Test photos are split by photo; the split is one split of 2,527 photos, so quoted accuracy (86.8%) has a wide margin of error.

## 2. Reuse search
`searchReuse(query, material)`: tokenise → stop-words → lemmatise, then two scores blended 50/50:
1. TF-IDF cosine against each idea's text.
2. Meaning: pretrained word vectors (spaCy `en_core_web_md`, PCA to 64-d), as a mean-vector cosine and a late-interaction "max-sim" score.
Honest result on 36 paraphrased queries: top-1 27 vs 26 for keywords only. Small library, small gain.

## 3. Price forecast
`FC`: naive, damped Holt, ridge regression on lagged returns; rolling-origin backtest (fit on the past only); prediction ranges are empirical 10–90% quantiles of each method's own backtest errors at that horizon. No method beats naive by much, which is the expected finding for commodity prices.

## 4. Marketplace, carbon credits
Rates: public Delhi price lists (see README). Quotes = reference rate × collector factor − condition deduction − fees. Carbon: EPA WARM-based emission factors, EPR floor/indicative prices from trade explainers, credit-integrity scorecard from documented cases (`CASES`).

`ALGO` block: haversine distance matrix, exact TSP by permutation (<= 8 stops) or nearest-neighbour + 2-opt, a seeded mulberry32 RNG, a sealed-bid auction simulator and a log-normal Monte Carlo credit portfolio. The region scan runs the classifier on 14 crops and merges overlaps with non-maximum suppression; it is not a trained detector. The guided tour is a data-driven array of steps that switch tabs and highlight an element.

## 5. Claude-powered features (only inside Claude)
Use the page's `sample` capability: a chat assistant with tools (`get_scrap_rate`, `compare_quotes`, `find_places`, `estimate_credits`, `list_credit_cases`, `forecast_metal`, `search_reuse_ideas`), photo second opinion, reuse ideas, credit-project reviewer. Hidden when the capability is absent.

## 6. Shared state (only inside Claude)
`db` + `user` capabilities: community board (`listings` collection, reservation by lease) and a private per-user impact log at `data/users/<id>/impactlog`. In a plain browser these controls stay hidden and the impact log lives in `localStorage`.

## Testing
- `npm test` runs `tests/unit.test.js` (CNN vs TensorFlow fixtures, impact maths, lifespan rules, reuse search, forecast backtest properties, route optimality, auction and portfolio sanity checks).
- `python3 tests/smoke.py` opens every tab in headless Chromium and fails on any JavaScript error.

## Not built here (needs GPU or a server)
`notebooks/01_vgg16_transfer_learning.ipynb` and `notebooks/02_yolo_multi_item_detection.ipynb` for Colab. Shared state outside Claude needs a real backend (Supabase / Firebase).
