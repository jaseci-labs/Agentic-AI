import boto3;
import from typing { Optional }
import from botocore.exceptions { BotoCoreError, ClientError }
import from jac_cloud.jaseci.utils.logger { logger }
import from utils { get_env_variable }

obj AWSConnector {
    def init {
        REGION = get_env_variable("AWS_REGION");
        AWS_ACCESS_KEY = get_env_variable("AWS_ACCESS_KEY");
        AWS_SECRET_KEY = get_env_variable("AWS_SECRET_KEY");
        self.s3_client = boto3.client(
            "s3",
            aws_access_key_id=AWS_ACCESS_KEY,
            aws_secret_access_key=AWS_SECRET_KEY,
            region_name=REGION,
        );
    }

    def generate_upload_links(
        bucket_name: str,
        object_name: str,
        expiration: int = 3600,
        content_type: str = "image/png",
    ) -> Optional[Dict[str, str]] {
        try {
            logger.debug("aws | generate_upload_links | Generating presigned URL");
            # Pre-signed upload URL
            upload_url = self.s3_client.generate_presigned_url(
                "put_object",
                Params={
                    "Bucket": bucket_name,
                    "Key": object_name,
                    "ContentType": content_type,
                },
                ExpiresIn=expiration,
            );

            # Public URL
            public_url = f"https://{bucket_name}.s3.amazonaws.com/{object_name}";

            return {"upload_url": upload_url, "public_url": public_url};

        } except (BotoCoreError, ClientError) as e {
            logging.error(f"aws |generate_upload_links | Error generating presigned URL: {e}");
            return None;
        }
    }
}

glob aws_client = AWSConnector();