# Pocket Curio — journal adoption read (2026-09-05)

The last journal holdout in the fleet, adopted with one deliberate
design decision:

## The photo stays domain

An item's photo is not a journal attachment — it IS the record (the
grid tiles, the cover fallbacks, the guided-crop flow are all built on
`items.photo_path`). This is the Table Encore dish-photo precedent:
journal option B owns the MEMORY (rating + notes, via
`journal_entry_id`), and structural domain media stays on the domain
row. Extra memory shots (the back of the postcard) can land as journal
photos later without schema change.

Consequences:
- Schema v2 migrates rating/notes into the shared journal tables and
  drops the columns; photo_path is untouched (migration_test proves
  both against a raw v1 file).
- Backups are format 2 (journal tables via cc_core dumpJournalTables);
  format 1 restores through an upgrade shim (round-trip test).
- The photo file layer stays Pocket Curio's `PhotoStore` (relative
  paths under `photos/`, sync IO by design — an insight that moved
  UP into cc_core 0.21.2's shareStampedFile). A thin
  `PhotoStoreService` adapter exposes cc_core's `PhotoService` face
  where shared flows need it (runRestoreFlow's media loop).

## Kept local, on purpose

- `FreeTierCounter`: Pocket Curio's is a dual-limit card (collections
  AND items in one surface) — a different widget from cc_core's
  single-usage counter, not a duplicate.
- `PhotoStore` itself: see above; on the ledger watch list until a
  second cropper/photo-first app wants it.

## Shed onto cc_core in this pass

rating_stars (cc_core 0.14), share_plus_launcher (0.17),
journal dump/restore in backups (0.17), shareStampedFile +
runRestoreFlow (0.20/0.21.2), continentTiles + continentNames
(0.21.x — donated FROM here). Pin: v0.10.0 → v0.21.2.
