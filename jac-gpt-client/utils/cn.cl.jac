"""Utility function for merging CSS class names."""

import from "clsx" { clsx }
import from "tailwind-merge" { twMerge }

"""Merge class names with Tailwind CSS conflict resolution."""
def:pub cn(inputs: any) -> str {
    args = [].slice.call(arguments);
    return twMerge(clsx(args));
}
