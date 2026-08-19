from typing import ClassVar, Literal, Optional

from sqlalchemy.orm import Session

from app.configuration.environments.platform_service_configurations.schema_response import (
    BigQueryConfig,
)
from app.data_products.schema import DataProduct
from app.technical_asset_configuration.base_schema import (
    AssetProviderPlugin,
    PlatformMetadata,
)
from app.technical_asset_configuration.bigquery.model import (
    BigQueryTechnicalAssetConfiguration as BigQueryTechnicalAssetConfigurationModel,
)
from app.technical_asset_configuration.data_output_types import DataOutputTypes


class BigQueryTechnicalAssetConfiguration(AssetProviderPlugin):
    name: ClassVar[str] = "BigQueryTechnicalAssetConfiguration"
    version: ClassVar[str] = "1.0"

    dataset_id: Optional[str] = None
    configuration_type: Literal[DataOutputTypes.BigQueryTechnicalAssetConfiguration]

    _platform_metadata = PlatformMetadata(
        display_name="BigQuery",
        icon_name="bigquery-logo.svg",
        platform_key="bigquery",
        parent_platform="gcp",
        result_label="Resulting dataset",
        result_tooltip="The BigQuery dataset you can access through this technical asset",
        detailed_name="Dataset",
    )

    class Meta:
        orm_model = BigQueryTechnicalAssetConfigurationModel

    def validate_configuration(self, data_product: DataProduct, db: Session):
        pass

    def on_create(self):
        pass

    def apply_namespace_default(self, namespace: str) -> None:
        # No "Dataset" form field on purpose - a Technical Asset is already
        # exactly one BigQuery dataset (ADR-001), so its own namespace *is*
        # the dataset id; asking for a second, near-always-identical field
        # was the "duplicate info" the UI surfaced. use_namespace_when_not_
        # source_aligned isn't a fit here - it defaults from the *Data
        # Product's* namespace (right for Snowflake's one-database-per-
        # product `database` field), not this asset's own. Direct API
        # callers can still set an explicit dataset_id to diverge from the
        # namespace; this only fills the gap when they don't.
        if not self.dataset_id:
            self.dataset_id = namespace

    def get_configuration(
        self, configs: list[BigQueryConfig]
    ) -> Optional[BigQueryConfig]:
        # Unlike Snowflake/S3, which can have several databases/buckets
        # registered per environment, every BigQuery Technical Asset in a
        # given environment lives in the same GCP project (portal-gcp's
        # ADR-001) - there's exactly one config to pick, nothing to
        # disambiguate by.
        return configs[0] if configs else None
