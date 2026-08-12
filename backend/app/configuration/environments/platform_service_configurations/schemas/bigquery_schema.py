from .config_schema import BaseEnvironmentPlatformServiceConfigurationDetail


class BigQueryConfig(BaseEnvironmentPlatformServiceConfigurationDetail):
    project_id: str
    dataset_location: str = "EU"
