import requests;
import os;
import from typing { Optional, List }
import from jac_cloud.jaseci.utils.logger { logger }


obj GoogleLocationService {
    def init() {
        self.api_key = os.getenv("GOOGLE_MAPS_API_KEY");
        self.get_city_url = "https://maps.googleapis.com/maps/api/geocode/json";
        self.get_places_url = "https://places.googleapis.com/v1/places:searchText";
    }

    def get_city(latitude: float, longitude: float) -> Optional[str] {
        try {
            logger.debug(f"google_location_service | get_city | Fetching city for coordinates: {latitude}, {longitude}");
            params = {
                "latlng": f"{latitude},{longitude}",
                "key": self.api_key
            };
            
            response = requests.get(self.get_city_url, params=params);

            if response.status_code == 200 {
                results = response.json().get("results", []);
                for result in results {
                    for component in result.get("address_components", []) {
                        if "locality" in component.get("types", []) {
                            return component.get("long_name");
                        }
                    }
                }
            }
            return None;
        } except requests.RequestException as e {
            logger.error(f"google_location_service | get_city | Failed to fetch city: {e}");
            return None;
        } except KeyError as e {
            logger.error(f"google_location_service | get_city | Key error: {e}");
            return None;
        } except Exception as e {
            logger.error(f"google_location_service | get_city | Unexpected error: {e}");
            return None;
        }
    }

    def get_detailed_location(
        latitude: float,
        longitude: float,
        radius: float,
        search_query: str,
        top_n: int = 3
    ) -> List[str] {
        try {
            logger.debug(f"google_location_service | get_detailed_location | Fetching places for query: {search_query} near {latitude}, {longitude}");
            headers = {
                "Content-Type": "application/json",
                "X-Goog-Api-Key": self.api_key,
                "X-Goog-FieldMask": "places.displayName"
            };
            payload = {
                "textQuery": search_query,
                "locationBias": {
                    "circle": {
                        "center": {"latitude": latitude, "longitude": longitude},
                        "radius": radius
                    }
                },
                "rankPreference": "DISTANCE"
            };

            response = requests.post(self.get_places_url, json=payload, headers=headers);

            if response.status_code == 200 {
                places = response.json().get("places", []);
                return [place["displayName"]["text"] for place in places[:top_n]];
            }
            return [];
        } except requests.RequestException as e {
            logger.error(f"google_location_service | get_detailed_location | Failed to fetch places: {e}");
            return [];
        } except KeyError as e {
            logger.error(f"google_location_service | get_detailed_location | Key error: {e}");
            return [];
        } except Exception as e {
            logger.error(f"google_location_service | get_detailed_location | Unexpected error: {e}");
            return [];
        }
    }
}

glob google_location_service = GoogleLocationService();