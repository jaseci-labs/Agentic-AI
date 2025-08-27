import os;
import re;
import from typing { Optional }
import from dateutil { parser }
import from jac_cloud.jaseci.utils.logger { logger }


def convert_date_to_valid_format(date_string: str) -> str {
    try {
        if date_string {
            logger.debug(f"utils | convert_date_to_valid_format | Converting date string: {date_string}");
            date_string = re.sub(r"(\d{4}):(\d{2}):(\d{2})", r"\1-\2-\3", date_string);
            parsed_date = parser.parse(date_string);
            parsed_date = parsed_date.strftime("%Y-%m-%d");
            logger.debug(f"utils | convert_date_to_valid_format | Parsed date: {parsed_date}");
            return parsed_date;
        } else {
            logger.warning("utils | convert_date_to_valid_format | Empty date string provided.");
            return "";
        }
    } except Exception as e {
        logger.error(f"utils | convert_date_to_valid_format | Error parsing date: {e}");
        return "";
    }
}

def get_env_variable(var_name: str) -> Optional[str] {
    try {
        value = os.environ[var_name];
        logger.debug(f"util | get_env_variable | Successfully retrieved {var_name}");
        return value;
    } except KeyError {
        logger.error(f"util | get_env_variable | Environment variable {var_name} not found.");
        return None;
    }
}