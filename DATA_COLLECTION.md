# Collecting Indian waste photos (the biggest accuracy improvement available)

TrashNet is a good start but it is photographed on plain backgrounds, mostly in the US. A model trained only on it will be weaker on photos from Indian homes and scrap shops.

## Collect
- Target 150–200 photos per class: cardboard, glass, metal, paper, plastic, trash. More important than the number is variety.
- Use an ordinary phone camera. Shoot items on a floor, table, in a bin and in a scrap pile. Include crumpled, wet and dirty items, Indian packaging (chips packets, milk pouches, tetra packs, steel utensils, aluminium foil trays) and mixed backgrounds.
- One main object per photo to begin with. Keep the file names neutral (`IMG_0123.jpg`).
- Ask for permission before photographing people's property, and never photograph people or faces.

## Label
- Put photos in folders named after the true class: `data/plastic/…`, `data/glass/…`. Decide edge cases once and write them down (is a metal-lidded glass jar glass or metal?).
- Have a second person relabel 10% of photos. If you disagree on more than 5%, the class definitions need work.
- The demo's **"Was this right?"** buttons on the Identify waste page save corrections in the browser and export a CSV, which is a quick way to find photos the current model gets wrong. They record labels only, not the photos.

## Evaluate fairly
- Split by **photo**, and keep a **test set that no training run ever sees** (for example 30 photos per class). Report it separately from TrashNet.
- Report per-class recall and a confusion matrix, as in `docs/MODEL_REPORT.md`.
- Run `notebooks/03_finetune_on_your_photos.ipynb` in Colab on a GPU, which trains on TrashNet plus your photos and prints the numbers.
