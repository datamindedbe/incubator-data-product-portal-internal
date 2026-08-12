from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column

from app.technical_asset_configuration.base_model import BaseTechnicalAssetConfiguration


class BigQueryTechnicalAssetConfiguration(BaseTechnicalAssetConfiguration):
    __tablename__ = "bigquery_technical_asset_configurations"

    dataset_id: Mapped[str] = mapped_column(String, nullable=True)

    __mapper_args__ = {
        "polymorphic_identity": "BigQueryTechnicalAssetConfiguration",
    }
