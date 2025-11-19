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
Fetch attractions for a given location and return the top options within a given budget.

Args:
    location (str): Name of the city to search.
    start_date (str): Start date in YYYY-MM-DD format.
    duration (int): Number of days for which attractions are relevant.
    budget (float): Maximum price allowed.

Returns:
    list: Up to five attractions within the budget.
"""
def search_attractions(location: str, start_date: str, duration: int, budget: float) {


    RAPID_API_KEY = os.getenv("RAPID_API_KEY");

    if not RAPID_API_KEY{
        raise ValueError("RAPID_API_KEY not found in environment variables");
    }

    headers = {
        "X-RapidAPI-Key": RAPID_API_KEY,
        "X-RapidAPI-Host": "booking-com.p.rapidapi.com",
    };

    start_date = datetime.strptime(start_date, "%Y-%m-%d").date();
    end_date = start_date + timedelta(days=duration);

    loc_resp = requests.get(
        "https://booking-com.p.rapidapi.com/v1/hotels/locations",
        headers=headers,
        params={
            "name": location,
            "locale": "en-gb",
        },
    );
    loc_resp.raise_for_status();
    locations = loc_resp.json();

    if not locations{
        raise ValueError(f"No destination found for location: {location}");
    }

    dest_id = locations[0].get("dest_id");
    dest_type = locations[0].get("dest_type");

    search_resp = requests.get(
        "https://booking-com.p.rapidapi.com/v1/attractions/search",
        headers=headers,
        params={
            "dest_id": dest_id,
            "dest_type": dest_type,
            "start_date": start_date.isoformat(),
            "end_date": end_date.isoformat(),
            "order_by": "trending",
            "currency": "USD",
            "locale": "en-gb",
            "page_number": 0,
        },
    );
    search_resp.raise_for_status();
    data = search_resp.json();

    results = data.get("products", []);


    attractions = [];

    for product in results{
        rep_price = product.get("representativePrice") or {};
        charge_amount = rep_price.get("chargeAmount");
        currency = rep_price.get("currency");

        if charge_amount is None{
            continue;
        }

        if charge_amount <= budget{
            attractions.append({
                "name": product.get("name"),
                "shortDescription": product.get("shortDescription"),
                "chargeAmount": charge_amount,
                "currency": currency,
            });

            if len(attractions) == 5{
                break;
            }
        }
    }
    return attractions;
    
}


"""
Fetch hotels for a given location and return the top options closest to a given budget.

Args:
    location (str): Name of the city to search.
    start_date (str): Check-in date in YYYY-MM-DD format.
    duration (int): Number of nights to stay.
    budget (float): Maximum price allowed.

Returns:
    list: Up to five hotels within the budget.
"""
def search_hotels(location: str, start_date: str, duration: int, budget: float) {

    RAPID_API_KEY = os.getenv("RAPID_API_KEY");

    if not RAPID_API_KEY{
        raise ValueError("RAPID_API_KEY not found in environment variables");
    }

    headers = {
        "X-RapidAPI-Key": RAPID_API_KEY,
        "X-RapidAPI-Host": "booking-com.p.rapidapi.com",
    };

    checkin = datetime.strptime(start_date, "%Y-%m-%d").date();
    checkout = checkin + timedelta(days=duration);

    loc_resp = requests.get(
        "https://booking-com.p.rapidapi.com/v1/hotels/locations",
        headers=headers,
        params={
            "name": location,
            "locale": "en-gb",
        },
    );
    loc_resp.raise_for_status();
    locations = loc_resp.json();

    if not locations{
        raise ValueError(f"No destination found for location: {location}");
    }

    dest_id = locations[0].get("dest_id");
    dest_type = locations[0].get("dest_type");

    search_resp = requests.get(
        "https://booking-com.p.rapidapi.com/v1/hotels/search",
        headers=headers,
        params={
            "dest_id": dest_id,
            "dest_type": dest_type,
            "checkin_date": checkin.isoformat(),
            "checkout_date": checkout.isoformat(),
            "adults_number": 1,
            "room_number": 1,
            "order_by": "popularity",
            "filter_by_currency": "USD",
            "locale": "en-gb",
            "units": "metric",
            "page_number": 0,
            "include_adjacency": "true",
        },
    );
    search_resp.raise_for_status();
    data = search_resp.json();

    results = data.get("result", []);
    hotels = [];

    # collect only the needed fields, skip if price is missing
    for h in results {
        price = h.get("min_total_price");
        if price is None{
            continue;
        }

        if price > budget{
            continue;
        }

        hotels.append({
            "name": h.get("hotel_name"),
            "address": h.get("address"),
            "min_total_price": price,
            "currency": h.get("currencycode"),
            "url": h.get("url"),
        });
    }

    if not hotels{
        return [];
    }

    # sort by closeness to budget and take top 5 (or fewer if less available)
    hotels = sorted(
        hotels,
        key=lambda x: float :  abs(x.get("min_total_price") - budget)
    );

    return hotels[:5];
}


def get_tools() {
    return {
        "search_flights_tool": search_flights,
        "search_attractions_tool": search_attractions,
        "search_hotels_tool": search_hotels
    };
}




