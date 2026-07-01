"""
Script to generate all_section_links.json from mkdocs.yml navigation structure.
Reads the mkdocs.yml file and constructs a JSON file with title and URL for each page.
Includes semantic embeddings for each title for similarity search.
"""

import from jaclang.byllm.lib {Model}
import yaml;
import from dotenv {load_dotenv}
import json;
import os;
import from pathlib {Path}
import from typing {List, Dict, Any}
import numpy as np;
import from sentence_transformers {SentenceTransformer}

glob llm = Model(model_name="gpt-4.1-mini");

with entry {
    load_dotenv(override=True);
}

"""Create custom YAML loader that ignores MkDocs-specific tags like !python/name:..."""
def get_yaml_loader() -> Any {
    loader = yaml.SafeLoader;
    
    # Add constructor that ignores unknown tags
    def ignore_unknown(ldr: Any, tag_suffix: str, yaml_node: Any) -> Any {
        return None;
    }
    
    loader.add_multi_constructor('', ignore_unknown);
    return loader;
}


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

"""Recursively extract navigation items from the mkdocs nav structure.
    
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
            if isinstance(value, str) {
                # Only process .md files
                if value.endswith('.md') {
                    title = " ● ".join(parent_sections + [key]) if parent_sections else key;
                    url = construct_url(site_url, value);
                    results.append({"title": title, "url": url});
                }
            } elif isinstance(value, list) {
                # Section with nested items
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
        # Only process .md files
        if nav_item.endswith('.md') {
            title = " ● ".join(parent_sections) if parent_sections else nav_item;
            url = construct_url(site_url, nav_item);
            results.append({"title": title, "url": url});
        }
    }
    
    return results;
}


"""Parse mkdocs.yml and generate all_section_links.json.
    
Args:
    mkdocs_path: Path to mkdocs.yml file
    output_path: Path where all_section_links.json should be created
"""
def parse_mkdocs_nav(mkdocs_path: str, output_path: str) {
    # Read mkdocs.yml (using custom loader to ignore MkDocs-specific tags)
    with open(mkdocs_path, 'r', encoding='utf-8') as f {
        mkdocs_config = yaml.load(f, Loader=get_yaml_loader());
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
    
    print(f"Successfully generated {len(all_links)} documentation links with embeddings");
}


"""
Match each default title to the most semantically related documentation link from all available links.

Given:
- default_titles: A list of topic/concept titles (e.g., "AI integration", "Object Spatial Programming")
- all_links: A list of documentation pages, where each item contains:
  - 'title': The page title (may include hierarchical sections separated by ●)
  - 'url': The full URL to the documentation page

Task:
For each default_title, analyze all available documentation links and select the single most relevant match based on semantic similarity and topic relevance. Consider the full hierarchical context in link titles.

Return a JSON object mapping each default title to its best matching documentation URL:
{
    "AI integration": "https://jac-lang.org/learn/guide/...",
    "Object Spatial Programming": "https://jac-lang.org/learn/..."
}

Ensure all default titles are included in the output, even if the match is approximate.
"""
def determine_default_doc_links(default_titles: List[str], all_links: List[Dict[str, str]]) -> Dict[str, str] by llm(method="Reason", temperature=0.4);


def generate_default_doc_links(mkdocs_path: str, output_path: str) -> Dict[str, str] {
    titles = [
        "Introduction to Jac programming language",
        "Object Spatial Programming",
        "AI integration",
        "Building full stack applications"
    ];
    
    with open(mkdocs_path, 'r', encoding='utf-8') as f {
        mkdocs_config = yaml.load(f, Loader=get_yaml_loader());
    }
    
    # Ensure site_url has trailing slash
    site_url = mkdocs_config.get('site_url', 'https://jac-lang.org/');
    if not site_url.endswith('/') {
        site_url += '/';
    }
    
    result = determine_default_doc_links(titles, extract_nav_items(mkdocs_config.get('nav', []), [], site_url, site_url));
    
    # Convert dict to array format for JSON file
    links_array = [{"url": url, "title": title} for (title, url) in result.items()];
    
    # Ensure output directory exists
    Path(output_path).parent.mkdir(parents=True, exist_ok=True);
    
    # Write to JSON file
    with open(output_path, 'w', encoding='utf-8') as f {
        json.dump(links_array, f, indent=2, ensure_ascii=False);
    }
    
    print(f"Successfully generated {len(links_array)} default documentation links");
}

with entry {
    # Determine paths relative to this script
    script_dir = Path(__file__).parent;
    mkdocs_path = script_dir.parent.parent / "jaseci" / "docs" / "mkdocs.yml";
    output_path = script_dir / "docs_links" / "all_section_links.json";
    default_links_path = script_dir / "docs_links" / "default_suggestion_links.json";
    
    # Ensure output directory exists
    output_path.parent.mkdir(parents=True, exist_ok=True);
    
    # Check if mkdocs.yml exists
    if not mkdocs_path.exists() {
        print(f"Error: mkdocs.yml not found at {mkdocs_path}");
        print("Please provide the correct path to mkdocs.yml");
        exit(1);
    }
    
    # Generate all documentation links with embeddings
    parse_mkdocs_nav(str(mkdocs_path), str(output_path));
    
    # Generate default suggestion links
    generate_default_doc_links(str(mkdocs_path), str(default_links_path));
}