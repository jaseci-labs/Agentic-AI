import from aws { aws_client }
import from jac_cloud.jaseci.utils.logger { logger }
import from utils { get_env_variable }
import from uuid { uuid4 }
import from fastapi { HTTPException, status }


walker generate_presigned_url {

    class __specs__ {
        has tags: list = ["storage"];
    }

    can generate_presigned_url with `root entry {
        BUCKET_NAME = get_env_variable("AWS_S3_BUCKET_NAME");
        OBJECT_NAME = f"{uuid4().hex}.png";
        response = aws_client.generate_upload_links(
            bucket_name=BUCKET_NAME,
            object_name=OBJECT_NAME,
            expiration=3600,
            content_type="image/png"
        );

        if response {
            report response;
        } else {
            logger.error("storage | generate_presigned_url | Failed to generate presigned URL");
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to generate presigned URL"
            );
        }
    }
}