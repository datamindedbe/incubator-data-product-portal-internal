-- Minimal local seed: Domains + Data Product Types, no demo data
-- products/output ports. Used by `db_tool.py init-if-empty` (see
-- compose.local.yaml) instead of the full sample_data.sql demo dataset -
-- only ever runs once, on a genuinely empty database (domain count == 0).

INSERT INTO public.domains (id, name, description, created_on, updated_on, deleted_at) VALUES
    (gen_random_uuid(), 'People', '', timezone('utc'::text, CURRENT_TIMESTAMP), NULL, NULL),
    (gen_random_uuid(), 'Sales', '', timezone('utc'::text, CURRENT_TIMESTAMP), NULL, NULL),
    (gen_random_uuid(), 'Marketing', '', timezone('utc'::text, CURRENT_TIMESTAMP), NULL, NULL),
    (gen_random_uuid(), 'Consulting', '', timezone('utc'::text, CURRENT_TIMESTAMP), NULL, NULL),
    (gen_random_uuid(), 'Finance', '', timezone('utc'::text, CURRENT_TIMESTAMP), NULL, NULL),
    (gen_random_uuid(), 'Product', '', timezone('utc'::text, CURRENT_TIMESTAMP), NULL, NULL),
    (gen_random_uuid(), 'Knowledge', '', timezone('utc'::text, CURRENT_TIMESTAMP), NULL, NULL);

-- Data Mesh archetypes, replacing the demo's Processing/Reporting/etc set.
-- icon_key left DEFAULT for all three - none of DataProductIconKey's fixed
-- options (reporting/processing/exploration/ingestion/machine_learning/
-- analytics) actually fit; pick better ones later via Settings > Data Product
-- if the icon picker there offers anything closer.
INSERT INTO public.data_product_types (id, name, description, icon_key, created_on, updated_on, deleted_at) VALUES
    (gen_random_uuid(), 'Source-aligned', 'Exposes data close to its origin, owned by the team that generates it.', 'DEFAULT', timezone('utc'::text, CURRENT_TIMESTAMP), NULL, NULL),
    (gen_random_uuid(), 'Aggregate', 'Combines multiple source-aligned data products into a broader, cross-domain view.', 'DEFAULT', timezone('utc'::text, CURRENT_TIMESTAMP), NULL, NULL),
    (gen_random_uuid(), 'Consumer-aligned', 'Shaped for a specific consumer or use case, such as a report or ML feature set.', 'DEFAULT', timezone('utc'::text, CURRENT_TIMESTAMP), NULL, NULL);
