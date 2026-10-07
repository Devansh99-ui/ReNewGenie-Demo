# Model report: what the classifier does, how well, and why

All numbers below come from `training/` scripts run on TrashNet (2,527 photos, 6 classes). The split is by photo: 70% train (1,770), 15% validation, 15% test (380), seed 7. The test set was used once at the end.

## Results
| Model | Test accuracy |
|---|---|
| CNN from scratch (8 conv layers, about 210,000 weights) | 83.4% |
| Feature MLP (453 colour/edge/texture features, 5 networks) | 81.8% |
| Ensemble, 0.6 CNN + 0.4 MLP (weight chosen on validation) | **86.8%** (330 of 380) |

One split of 380 photos means the margin of error is roughly ±3.5 points at 95% confidence, so 86.8% should be read as "about 83–90%".

## Confusion matrix (rows = true class, 380 test photos)
| True \ Predicted | Card. | Glass | Metal | Paper | Plastic | Trash | Recall | Precision |
|---|---|---|---|---|---|---|---|---|
| Cardboard | 59 | 0 | 1 | 2 | 0 | 2 | 92% | 91% |
| Glass | 1 | 50 | 4 | 0 | 3 | 1 | 85% | 81% |
| Metal | 0 | 6 | 61 | 2 | 4 | 1 | 82% | 91% |
| Paper | 1 | 0 | 0 | 88 | 2 | 1 | 96% | 91% |
| Plastic | 2 | 6 | 1 | 4 | 60 | 2 | 80% | 86% |
| Trash | 2 | 0 | 0 | 1 | 1 | 12 | 75% | 63% |

## What the matrix says
- **Glass, metal and plastic are confused with each other** (6 metal photos called glass, 6 plastic called glass, 4 metal called plastic). All three are shiny, transparent or reflective, and a model that sees mostly colour and edges cannot separate a clear plastic bottle from a glass one reliably. This is the main weakness.
- **Paper and cardboard are strong** because their texture and colour are distinctive on plain backgrounds.
- **Trash has the lowest precision (63%)** because it is a catch-all class with few photos (only 16 in the test set), so its numbers are noisy.

## Why a CNN and a feature model together
The two models make different mistakes. The CNN learns shapes but overfits a small training set (training accuracy about 97%, validation about 80%). The feature model is blunt but stable. Averaging them gains about 3 points over the better one, and the weight was chosen on validation data, not the test set.

## Is the confidence number honest?
A calibration table (`tests/calib.json`) records how often the ensemble was right at each confidence level on the test photos:

| Confidence | Photos | Right |
|---|---|---|
| below 40% | 12 | 42% |
| 40–50% | 30 | 53% |
| 50–60% | 32 | 72% |
| 60–70% | 34 | 79% |
| 70–80% | 41 | 80% |
| 80–90% | 60 | 95% |
| 90–100% | 171 | 99% |

That is why the app says "not sure" below 60% and shows this reliability after each result.

## What the model cannot do (be upfront about this)
- TrashNet photos are single objects on plain backgrounds. Cluttered phone photos, wet or crumpled items, and Indian packaging that is not in TrashNet will score lower. **The 86.8% does not transfer to those photos.**
- The region scan runs the classifier on 14 crops. It is not a trained object detector and cannot draw reliable boxes.
- There is no transfer learning here. The original report's VGG16 approach is in `notebooks/01_vgg16_transfer_learning.ipynb` (written without a GPU, not yet run by the author).

## What I would do next, in order of impact
1. Collect and label 150–200 photos per class from Indian homes and scrap shops (`docs/DATA_COLLECTION.md`) and measure accuracy on them separately.
2. Fine-tune a pretrained network (`notebooks/03_finetune_on_your_photos.ipynb`) and compare it with this ensemble on the same new test set.
3. Add a separate "mixed or unclear" class instead of forcing a guess.
4. Report accuracy per class with confidence intervals, not just one headline number.
