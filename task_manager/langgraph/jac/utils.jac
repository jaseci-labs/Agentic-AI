import from datetime { datetime }

def normalize_from_fields(date_s: str, time_s: str) -> tuple[str, str] {

    now = datetime.now();

    # date
    if date_s {
        try {
            d = datetime.strptime(date_s, "%Y-%m-%d");
        } except ValueError {
            d = datetime(now.year, now.month, now.day);
        }
    }
    else {
        d = datetime(now.year, now.month, now.day);
    }

    # time
    if time_s {
        # support HH:MM or HH:MM:SS
        for fmt in ("%H:%M:%S", "%H:%M") {
            try {
                t = datetime.strptime(time_s, fmt);
                (hh, mm, ss) = (t.hour, t.minute, t.second);
                break;
            } except ValueError {
                continue;
            }
        }
        else{
            (hh, mm, ss) = (0, 0, 0);
        }
    }
    else {
        (hh, mm, ss) = (0, 0, 0);
    }

    dt = datetime(d.year, d.month, d.day, hh, mm, ss);
    return (dt.strftime("%Y-%m-%d %H:%M:%S"), dt.strftime("%H:%M:%S"));
}