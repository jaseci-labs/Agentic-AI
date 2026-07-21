"""Shared persistent layout for the auth screens (Login / Register).

Rendered ONCE as a react-router layout route: the ambient background (glow orbs
+ floating particles) and the hero stay mounted across /login <-> /register
navigation, and only the form card (the <Outlet/>) swaps. This keeps the
particles flowing continuously and eliminates the remount flash — the shell is
never torn down, so switching pages feels like a seamless SPA transition.

Routing (frontend.cl.jac):
    <Route element={<AuthShell />}>
        <Route path="/login" element={<LoginPage />} />
        <Route path="/register" element={<RegisterPage />} />
    </Route>
"""

import from "@jac/runtime" { Outlet }
import from .AuthHero { AuthHero }
import from .AuthParticles { AuthParticles }

def:pub AuthShell() -> JsxElement {
    return <div className="jc-auth-shell">
        <div className="jc-bg-orbs" />
        <AuthParticles />
        <AuthHero />
        <div className="jc-auth-panel">
            <div className="jc-float-wrap jc-slide-up">
                <Outlet />
            </div>
        </div>
    </div>;
}
