"""BigQuery technical asset plugin

Revision ID: 6fb24c09f8b5
Revises: aa9f983049d2
Create Date: 2026-08-02 15:00:00.000000

"""

from typing import Sequence, Union

import sqlalchemy as sa
import sqlalchemy.orm as orm
from alembic import op
from sqlalchemy.dialects import postgresql

from app.shared.model import utcnow

# revision identifiers, used by Alembic.
revision: str = "6fb24c09f8b5"
down_revision: Union[str, None] = "aa9f983049d2"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "bigquery_technical_asset_configurations",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("data_output_configurations.id", ondelete="CASCADE"),
            primary_key=True,
        ),
        sa.Column("dataset_id", sa.String(), nullable=True),
        sa.Column("created_on", sa.DateTime(timezone=False), server_default=utcnow()),
        sa.Column("updated_on", sa.DateTime(timezone=False), onupdate=utcnow()),
        sa.Column("deleted_at", sa.DateTime(timezone=False), nullable=True),
    )

    bind = op.get_bind()
    session = orm.Session(bind=bind)

    gcp_id = session.execute(
        sa.text("INSERT INTO platforms (name) VALUES ('Google Cloud') RETURNING id")
    ).scalar_one()

    session.execute(
        sa.text(
            """
            INSERT INTO platform_services (name, platform_id, result_string_template, technical_info_template)
            VALUES ('bigquery', :platform_id, :result_template, :technical_info_template)
            """
        ),
        {
            "platform_id": gcp_id,
            # Unlike technical_info_template (rendered per-environment, with
            # that environment's BigQueryConfig.project_id available as
            # context - see schema.py's result_string computed field), this
            # is rendered with only the asset's own configuration fields, no
            # environment context. project_id lives on BigQueryConfig, not on
            # BigQueryTechnicalAssetConfiguration - referencing it here always
            # KeyErrors. Every sibling plugin's result_string_template only
            # references its own config fields for the same reason (Glue:
            # {database}__{database_suffix}.{table}, S3: {bucket}/{suffix}/
            # {path}) - follow that pattern instead of introducing the one
            # exception.
            "result_template": "{dataset_id}",
            "technical_info_template": (
                "https://console.cloud.google.com/bigquery"
                "?project={project_id}&d={dataset_id}&p={project_id}&page=dataset"
            ),
        },
    )

    session.commit()


def downgrade() -> None:
    bind = op.get_bind()
    session = orm.Session(bind=bind)

    session.execute(sa.text("DELETE FROM platform_services WHERE name = 'bigquery'"))
    session.execute(sa.text("DELETE FROM platforms WHERE name = 'Google Cloud'"))

    session.commit()

    op.drop_table("bigquery_technical_asset_configurations")
