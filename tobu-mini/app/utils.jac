import re;
import os;
import uuid;
import requests;
import from dateutil { parser }
import from typing { Optional }
import from io { BytesIO }
import from PIL { Image, UnidentifiedImageError }
import from jac_cloud.jaseci.utils.logger { logger }

glob TEMP_DIR = "temp" ;

def download_and_save_image(url: str) -> Optional[str] {
    # Ensure temp folder exists
    os.makedirs(TEMP_DIR, exist_ok=True);

    try {
        logger.debug(f"utils | download_and_save_image | Downloading image from {url}");
        response = requests.get(url);
        response.raise_for_status();

        image = Image.open(BytesIO(response.content));
        image.load();  # Fully load image in memory

        # Generate unique filename with correct extension
        ext = image.format.lower() if image.format else "png";
        filename = f"{uuid.uuid4().hex}.{ext}";
        filepath = os.path.join(TEMP_DIR, filename);

        image.save(filepath);
        logger.debug(f"Image saved to {filepath}");
        return filepath;

    } except requests.RequestException as e {
        logger.error(f"utils | download_and_save_image | Failed to download image: {e}");
    } except (UnidentifiedImageError, OSError) as e {
        logger.error(f"utils | download_and_save_image | Failed to process image: {e}");
    }
    return None;
}

def convert_date_to_valid_format(date_string: str) -> str {
    try {
        if date_string {
            logger.debug(f"utils | convert_date_to_valid_format | Converting date string: {date_string}");
            date_string = re.sub(r"(\d{4}):(\d{2}):(\d{2})", r"\1-\2-\3", date_string);
            parsed_date = parser.parse(date_string);
            logger.debug(f"utils | convert_date_to_valid_format | Parsed date: {parsed_date}");
            return parsed_date.strftime("%Y-%m-%d");
        } else {
            logger.warning("utils | convert_date_to_valid_format | Empty date string provided.");
            return "";
        }
    } except Exception as e {
        logger.error(f"utils | convert_date_to_valid_format | Error parsing date: {e}");
        return "";
    }
}