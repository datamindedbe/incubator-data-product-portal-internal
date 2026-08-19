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

-- Without at least one Environment and a platform_service_configs row, the
-- "Add Technical Asset" form can't resolve platform_id/service_id at all -
-- every platform tile's radio value comes from a lookup into
-- platform_service_configs (see data-output-form.component.tsx), and the
-- resulting-path preview separately needs an env_platform_service_configs
-- row to resolve BigQueryConfig.project_id. Neither table has anything in
-- it on a fresh database - sample_data.sql normally provides this as part
-- of its full demo dataset, which this minimal seed deliberately skips.
-- Found the hard way: an "Add Technical Asset" submit failed with a 422
-- (missing platform_id/service_id), even though both fields looked filled
-- in in the UI - both config tables were simply empty on this instance.
INSERT INTO public.environments (id, name, acronym, context, is_default) VALUES
    (gen_random_uuid(), 'prd', 'PRD', '', true);

INSERT INTO public.platform_service_configs (id, platform_id, service_id, config)
SELECT gen_random_uuid(), p.id, ps.id, '[]'
FROM public.platforms p, public.platform_services ps
WHERE p.name = 'GCP' AND ps.name = 'bigquery';

INSERT INTO public.env_platform_service_configs (id, environment_id, platform_id, service_id, config)
SELECT gen_random_uuid(), e.id, p.id, ps.id,
       '[{"identifier": "dm-data-products", "project_id": "dm-data-products", "dataset_location": "EU"}]'
FROM public.environments e, public.platforms p, public.platform_services ps
WHERE e.name = 'prd' AND p.name = 'GCP' AND ps.name = 'bigquery';
