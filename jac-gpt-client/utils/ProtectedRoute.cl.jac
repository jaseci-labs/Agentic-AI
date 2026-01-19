"""Protected route wrapper for authentication."""

import from react { useEffect }
import from "@jac-client/utils" { Navigate, jacIsLoggedIn }

"""Wrap routes that require authentication."""
def:pub ProtectedRoute(props: any) -> any {
    if not jacIsLoggedIn() {
        return <Navigate to="/login" />;
    }
    return props.children;
}
