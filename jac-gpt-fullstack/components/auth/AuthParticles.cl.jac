"""Shared ambient floating orange particles for the auth screens.

Pure presentation: a fixed, curated set of small glowing dots animated entirely
by CSS (see `.jc-particle` / `@keyframes particleDrift` in global.css). No JS
libraries, no per-frame work — GPU-composited transform/opacity only.
"""

# Curated spread so the field looks random but stays balanced and subtle.
# l/t = position (%), s = size (px), o = peak opacity, d = duration, dl = delay.
glob _PARTICLES: list = [
    {"l": "6%",  "t": "18%", "s": 3, "o": 0.45, "d": "15s", "dl": "0s"},
    {"l": "12%", "t": "62%", "s": 2, "o": 0.35, "d": "19s", "dl": "2s"},
    {"l": "18%", "t": "34%", "s": 4, "o": 0.50, "d": "13s", "dl": "1s"},
    {"l": "22%", "t": "82%", "s": 2, "o": 0.30, "d": "21s", "dl": "5s"},
    {"l": "27%", "t": "10%", "s": 3, "o": 0.40, "d": "17s", "dl": "3s"},
    {"l": "31%", "t": "48%", "s": 5, "o": 0.55, "d": "12s", "dl": "0s"},
    {"l": "36%", "t": "72%", "s": 2, "o": 0.28, "d": "20s", "dl": "6s"},
    {"l": "41%", "t": "24%", "s": 3, "o": 0.42, "d": "16s", "dl": "2s"},
    {"l": "45%", "t": "88%", "s": 4, "o": 0.38, "d": "18s", "dl": "4s"},
    {"l": "49%", "t": "56%", "s": 2, "o": 0.32, "d": "22s", "dl": "1s"},
    {"l": "54%", "t": "14%", "s": 3, "o": 0.46, "d": "14s", "dl": "3s"},
    {"l": "58%", "t": "40%", "s": 6, "o": 0.60, "d": "11s", "dl": "0s"},
    {"l": "62%", "t": "78%", "s": 2, "o": 0.30, "d": "20s", "dl": "5s"},
    {"l": "66%", "t": "22%", "s": 3, "o": 0.40, "d": "17s", "dl": "2s"},
    {"l": "70%", "t": "60%", "s": 4, "o": 0.48, "d": "13s", "dl": "4s"},
    {"l": "74%", "t": "8%",  "s": 2, "o": 0.34, "d": "19s", "dl": "1s"},
    {"l": "78%", "t": "46%", "s": 3, "o": 0.44, "d": "15s", "dl": "3s"},
    {"l": "82%", "t": "84%", "s": 5, "o": 0.52, "d": "12s", "dl": "0s"},
    {"l": "86%", "t": "30%", "s": 2, "o": 0.30, "d": "21s", "dl": "6s"},
    {"l": "90%", "t": "66%", "s": 3, "o": 0.42, "d": "16s", "dl": "2s"},
    {"l": "94%", "t": "20%", "s": 2, "o": 0.36, "d": "18s", "dl": "4s"},
    {"l": "9%",  "t": "44%", "s": 2, "o": 0.30, "d": "20s", "dl": "3s"},
    {"l": "15%", "t": "92%", "s": 3, "o": 0.40, "d": "17s", "dl": "1s"},
    {"l": "34%", "t": "58%", "s": 2, "o": 0.28, "d": "22s", "dl": "5s"},
    {"l": "52%", "t": "72%", "s": 3, "o": 0.44, "d": "14s", "dl": "2s"},
    {"l": "60%", "t": "12%", "s": 2, "o": 0.32, "d": "19s", "dl": "4s"},
    {"l": "72%", "t": "38%", "s": 4, "o": 0.50, "d": "13s", "dl": "0s"},
    {"l": "84%", "t": "54%", "s": 2, "o": 0.30, "d": "21s", "dl": "3s"},
    {"l": "88%", "t": "10%", "s": 3, "o": 0.42, "d": "16s", "dl": "6s"},
    {"l": "3%",  "t": "76%", "s": 2, "o": 0.34, "d": "18s", "dl": "2s"},
    {"l": "43%", "t": "6%",  "s": 3, "o": 0.40, "d": "15s", "dl": "1s"},
    {"l": "67%", "t": "90%", "s": 4, "o": 0.46, "d": "12s", "dl": "4s"}
];


"""Ambient orange particle field. Sits behind hero + card content."""
def:pub AuthParticles() -> JsxElement {
    return <div className="jc-particles" aria-hidden="true">
        {_PARTICLES.map(lambda (p: Any, i: Any) -> Any {
            return <span
                key={i}
                className="jc-particle"
                style={{
                    "left": p.l,
                    "top": p.t,
                    "width": String(p.s) + "px",
                    "height": String(p.s) + "px",
                    "--p-op": String(p.o),
                    "animationDuration": p.d,
                    "animationDelay": p.dl
                }}
            />;
        })}
    </div>;
}
