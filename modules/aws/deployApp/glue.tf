resource "aws_glue_catalog_database" "this" {
  name = "${var.global_name}-${var.app_name}"
}

resource "aws_glue_catalog_table" "aws_glue_catalog_table" {
  name          = module.AWS-deploy-output-bucket.bucket_id
  database_name = aws_glue_catalog_database.this.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL = "TRUE"
  }

  storage_descriptor {
    location      = "s3://${module.AWS-deploy-output-bucket.bucket_id}/parquet/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "my-stream"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = 1
      }
    }

    columns {
      name = "sessionid"
      type = "varchar(24)"
    }

    columns {
      name = "pledgeid"
      type = "int"
    }

    columns {
      name = "pledgetext"
      type = "varchar(65535)"
    }

    columns {
      name = "preprocessedtext"
      type = "varchar(65535)"
    }

    columns {
      name = "contentgroups"
      type = "int"
    }

    columns {
      name = "topicaction"
      type = "int"
    }

    columns {
      name = "area"
      type = "varchar(250)"
    }

    columns {
      name = "y1"
      type = "double"
    }

    columns {
      name = "y2"
      type = "double"
    }

    columns {
      name = "organisationname"
      type = "varchar(250)"
    }

    columns {
      name = "country"
      type = "varchar(250)"
    }

    columns {
      name = "pledgestatus"
      type = "varchar(50)"
    }

    columns {
      name = "organisationtype"
      type = "varchar(250)"
    }

  }
}