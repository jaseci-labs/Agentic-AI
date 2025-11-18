import os;
import requests;
import from dotenv { load_dotenv }
import from datetime { datetime, timedelta }


"""
Fetch an OAuth2 access token from Amadeus using client credentials.
"""
def _get_amadeus_token() -> str {
    AUTH_URL = "https://test.api.amadeus.com/v1/security/oauth2/token";
    AMADEUS_API_KEY = os.getenv("AMADEUS_API_KEY");
    AMADEUS_API_SECRET = os.getenv("AMADEUS_API_SECRET");

    response = requests.post(
        AUTH_URL,
        headers={"Content-Type": "application/x-www-form-urlencoded"},
        data={
            "grant_type": "client_credentials",
            "client_id": AMADEUS_API_KEY,
            "client_secret": AMADEUS_API_SECRET,
        },
        timeout=15
    );
    response.raise_for_status();

    return response.json()["access_token"];
}

"""
Search round-trip flights using the Amadeus Flight Offers Search API.

:param origin_location: Origin IATA code (e.g. "CMB")
:param destination_location: Destination IATA code (e.g. "DOH")
:param duration: Trip length in days (used to compute return date)
:param departure_date: Departure date as "YYYY-MM-DD"
:param adults: Number of adult travelers (default: 1)
:return: List of up to 5 simplified flight offers.
"""
def search_flights(
    origin_location: str,
    destination_location: str,
    duration: int,
    departure_date: str,
    adults: int = 1
) {
    dep = datetime.strptime(departure_date, "%Y-%m-%d").date();
    return_date = (dep + timedelta(days=duration)).isoformat();

    FLIGHT_OFFERS_URL = "https://test.api.amadeus.com/v2/shopping/flight-offers";
    token = _get_amadeus_token();

    params = {
        "originLocationCode": origin_location,
        "destinationLocationCode": destination_location,
        "departureDate": dep.isoformat(),
        "returnDate": return_date,
        "adults": adults,
        "max": 5,
    };

    headers = {
        "Authorization": f"Bearer {token}",
    };

    response = requests.get(
        FLIGHT_OFFERS_URL,
        headers=headers,
        params=params,
        timeout=20
    );
    response.raise_for_status();
    raw = response.json();

    offers = raw.get("data", [])[:5];

    simplified = [];
    for offer in offers {
        price = offer.get("price", {});
        itineraries = offer.get("itineraries", {});

        simplified.append(
            {
                "id": offer.get("id"),
                "one_way": offer.get("oneWay"),
                "price_total": price.get("total"),
                "price_currency": price.get("currency"),
                "outbound_itinerary": itineraries[0] if len(itineraries) >= 1 else None,
                "inbound_itinerary": itineraries[1] if len(itineraries) >= 2 else None,
            }
        );
    }

    return simplified;
}

"""
Fetch attractions for a given location using the TripAdvisor API.

Args:
    location (str): Name of the city or place to search.

Returns:
    list: attractions specific to the location.
"""
def search_attractions(location: str) -> list {
    booking_com_api_key = os.getenv("BOOKING_COM_API_KEY");

    if not api_key {
        raise ValueError("TRIPADVISOR_API_KEY not set");
    }

    url = "https://booking-com15.p.rapidapi.com/api/v1/attraction/searchLocation";

    params = {"query": location};
    headers = {
        "x-rapidapi-key": booking_com_api_key,
        "x-rapidapi-host": "booking-com15.p.rapidapi.com"
    };

    response = requests.get(url, headers=headers, params=params).json();

    products = response["data"]["products"];

    attraction_names = [
        p["title"]
        for p in products
        if p.get("taxonomySlug") != "transfers-services"
    ];

    return attraction_names;
}




def get_tools() {
    return {
        "search_flights_tool": search_flights,
        "search_attractions_tool": search_attractions,
    };
}


with entry{
    load_dotenv();
    get_tripadvisor_activities("Sydney");

}


