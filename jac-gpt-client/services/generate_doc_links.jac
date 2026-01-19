"""
Script to generate all_section_links.json from mkdocs.yml navigation structure.
Reads the mkdocs.yml file and constructs a JSON file with title and URL for each page.
Includes semantic embeddings for each title for similarity search.
"""

import yaml;
import json;
import os;
import from pathlib {Path}
import from typing {List, Dict, Any}
import numpy as np;
import from sentence_transformers {SentenceTransformer}

"""Convert markdown file path to URL following mkdocs use_directory_urls convention."""
def construct_url(base_url: str, md_path: str) -> str {
    # Remove .md extension
    url_path = md_path.replace('.md', '');
    
    # Handle index.md files - they map to their parent directory
    if url_path.endswith('/index') {
        url_path = url_path[:-6];  # Remove '/index'
    } elif url_path == 'index' {
        url_path = '';
    } else {
        # Regular files get a trailing slash in directory URLs mode
        url_path = url_path + '/';
    }
    
    # Combine with base URL
    return f"{base_url}{url_path}";
}

"""
Recursively extract navigation items from the mkdocs nav structure.
    
Args:
nav_item: Current navigation item (can be dict, list, or string)
parent_sections: List of parent section titles for building hierarchical titles
base_url: Base URL for the documentation site
site_url: Site URL from mkdocs.yml
    
Returns:
    List of dictionaries containing title and url
"""
def extract_nav_items(nav_item: Any, parent_sections: List[str], base_url: str, site_url: str) -> List[Dict[str, str]] {
    results = [];
    
    if isinstance(nav_item, dict) {
        for (key, value) in nav_item.items() {
            # Key is the section title
            if isinstance(value, str) {
                # This is a direct link: "Title": "path/to/file.md"
                title = " ● ".join(parent_sections + [key]) if parent_sections else key;
                url = construct_url(site_url, value);
                results.append({
                    "title": title,
                    "url": url
                });
            } elif isinstance(value, list) {
                # This is a section with nested items
                new_parent_sections = parent_sections + [key];
                for item in value {
                    results.extend(extract_nav_items(item, new_parent_sections, base_url, site_url));
                }
            } elif isinstance(value, dict) {
                # Nested dictionary
                new_parent_sections = parent_sections + [key];
                results.extend(extract_nav_items(value, new_parent_sections, base_url, site_url));
            }
        }
    } elif isinstance(nav_item, list) {
        for item in nav_item {
            results.extend(extract_nav_items(item, parent_sections, base_url, site_url));
        }
    } elif isinstance(nav_item, str) {
        # Direct path without title
        title = " ● ".join(parent_sections) if parent_sections else nav_item;
        url = construct_url(site_url, nav_item);
        results.append({
            "title": title,
            "url": url
        });
    }
    
    return results;
}


"""
Parse mkdocs.yml and generate all_section_links.json.
    
Args:
    mkdocs_path: Path to mkdocs.yml file
    output_path: Path where all_section_links.json should be created
"""
def parse_mkdocs_nav(mkdocs_path: str, output_path: str) {
    
    # Read mkdocs.yml
    with open(mkdocs_path, 'r', encoding='utf-8') as f {
        mkdocs_config = yaml.safe_load(f);
    }
    
    # Extract site_url and nav
    site_url = mkdocs_config.get('site_url', 'https://jac-lang.org/');
    if not site_url.endswith('/') {
        site_url += '/';
    }
    
    nav = mkdocs_config.get('nav', []);
    
    # Extract all navigation items
    all_links = [];
    for nav_item in nav {
        all_links.extend(extract_nav_items(nav_item, [], site_url, site_url));
    }
    
    # Generate embeddings for all titles
    print(f"Generating embeddings for {len(all_links)} titles...");
    model = SentenceTransformer('all-MiniLM-L6-v2');
    titles = [link['title'] for link in all_links];
    embeddings = model.encode(titles, show_progress_bar=True);
    
    # Add embeddings to links
    for (i, link) in enumerate(all_links) {
        link['embedding'] = embeddings[i].tolist();
    }
    
    # Write to JSON file
    with open(output_path, 'w', encoding='utf-8') as f {
        json.dump(all_links, f, indent=2, ensure_ascii=False);
    }
    
    print(f"Generated {len(all_links)} links with embeddings in {output_path}");
    return all_links;
}

with entry {
    # Determine paths relative to this script
    script_dir = Path(__file__).parent;
    mkdocs_path = script_dir.parent.parent / "jaseci" / "docs" / "mkdocs.yml";
    output_path = script_dir / "docs_links" / "all_section_links.json";
    
    # Ensure output directory exists
    output_path.parent.mkdir(parents=True, exist_ok=True);
    
    # Check if mkdocs.yml exists
    if not mkdocs_path.exists() {
        print(f"Error: mkdocs.yml not found at {mkdocs_path}");
        print("Please provide the correct path to mkdocs.yml");
        exit(1);
    }
    
    # Parse and generate
    all_links = parse_mkdocs_nav(str(mkdocs_path), str(output_path));
    
    # Print first 10 for testing
    print(f"\nFirst 10 links generated:");
    for (i, link) in enumerate(all_links[:10], 1) {
        print(f"{i}. {link['title']}");
        print(f"   {link['url']}\n");
    }
    
    print(f"Successfully generated documentation links!");
}
