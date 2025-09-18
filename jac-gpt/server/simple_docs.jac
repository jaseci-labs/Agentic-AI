# Documentation API for serving Jac documentation content

# walker get_sitemap {
#     """Get sitemap URLs for documentation"""
    
#     obj __specs__ {
#         static has methods: list = ["get"];
#         static has auth: bool = False;
#     }

#     can serve_sitemap with `root entry {
#         import os;
        
#         try {
#             sitemap_path = os.path.join(os.path.dirname(__file__), "sitemap.xml");
#             with open(sitemap_path, 'r', encoding='utf-8') as f {
#                 content = f.read();
#             }
            
#             report {
#                 "success": True,
#                 "content": content
#             };
#         } except Exception as e {
#             report {
#                 "success": False,
#                 "error": str(e)
#             };
#         }
#     }
# }

walker get_doc_content {
    """Fetch documentation content from URL or local files"""
    has url: str;
    
    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = False;
    }

    can fetch_doc with `root entry {
        import os;
        import requests;
        import re;
        
        try {
            # Basic URL validation
            if "jac-lang.org" not in self.url {
                report {
                    "success": False,
                    "error": "Only jac-lang.org URLs supported",
                    "content": "",
                    "title": ""
                };
                return;
            }
            
            # Extract path from URL
            url_parts = self.url.split("jac-lang.org");
            if len(url_parts) > 1 {
                path = url_parts[1].strip("/");
            } else {
                path = "";
            }
            
            # Try to find local documentation file
            local_doc_path = os.path.join(os.path.dirname(__file__), "docs", path);
            
            # Check for index.html in directory
            if os.path.isdir(local_doc_path) {
                index_path = os.path.join(local_doc_path, "index.html");
                if os.path.exists(index_path) {
                    local_doc_path = index_path;
                }
            }
            
            # Check for .html extension
            if not local_doc_path.endswith(".html") and os.path.exists(local_doc_path + ".html") {
                local_doc_path += ".html";
            }
            
            content = "";
            title = "";
            source = "remote";
            
            if os.path.exists(local_doc_path) {
                # Read local file
                with open(local_doc_path, 'r', encoding='utf-8') as f {
                    content = f.read();
                }
                source = "local";
            } else {
                # Fetch from remote URL
                response = requests.get(self.url, timeout=10);
                response.raise_for_status();
                content = response.text;
            }
            
            # Extract title from HTML
            title_match = re.search(r'<title>(.*?)</title>', content, re.IGNORECASE | re.DOTALL);
            if title_match {
                title = title_match.group(1).strip();
            } else {
                title = "Documentation";
            }
            
            # Clean up content for better display
            # Extract main content area
            main_content = "";
            
            # Try to extract the main article content
            article_match = re.search(r'<article[^>]*class="md-content__inner[^"]*"[^>]*>(.*?)</article>', content, re.DOTALL | re.IGNORECASE);
            if article_match {
                main_content = article_match.group(1);
            } else {
                # Fallback: try to find content div
                content_match = re.search(r'<div[^>]*class="md-content"[^>]*>(.*?)</div>', content, re.DOTALL | re.IGNORECASE);
                if content_match {
                    main_content = content_match.group(1);
                } else {
                    # Use full content as fallback
                    main_content = content;
                }
            }
            
            # Remove unwanted elements
            main_content = re.sub(r'<script[^>]*>.*?</script>', '', main_content, flags=re.DOTALL | re.IGNORECASE);
            main_content = re.sub(r'<style[^>]*>.*?</style>', '', main_content, flags=re.DOTALL | re.IGNORECASE);
            main_content = re.sub(r'<nav[^>]*>.*?</nav>', '', main_content, flags=re.DOTALL | re.IGNORECASE);
            main_content = re.sub(r'<footer[^>]*>.*?</footer>', '', main_content, flags=re.DOTALL | re.IGNORECASE);
            main_content = re.sub(r'<header[^>]*>.*?</header>', '', main_content, flags=re.DOTALL | re.IGNORECASE);
            
            # Remove edit buttons and source buttons
            main_content = re.sub(r'<a[^>]*class="md-content__button[^"]*"[^>]*>.*?</a>', '', main_content, flags=re.DOTALL | re.IGNORECASE);
            
            # Clean up extra whitespace
            main_content = re.sub(r'\s+', ' ', main_content);
            cleaned_content = main_content.strip();
            
            report {
                "success": True,
                "content": cleaned_content,
                "title": title,
                "url": self.url,
                "source": source
            };
            
        } except Exception as e {
            report {
                "success": False,
                "error": str(e),
                "content": "",
                "title": "",
                "url": self.url
            };
        }
    }
}

walker suggest_docs {
    """Enhanced suggest relevant documentation based on user message with section-level links"""
    has message: str;
    has chat_history: list[dict] = [];
    
    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = False;
    }

    can get_suggestions with `root entry {
        import json;
        import os;
        
        # Load section-level documentation links
        section_links = [];
        try {
            links_file = os.path.join(os.path.dirname(__file__), "docs_links", "all_section_links.json");
            with open(links_file, 'r', encoding='utf-8') as f {
                section_links = json.load(f);
            }
        } except Exception as e {
            print(f"Error loading section links: {str(e)}");
        }
        
        message_lower = self.message.lower();
        suggestions = [];
        
        print(f"Processing message: {message_lower}");
        
        # First: Check for specific section matches with high priority
        for link in section_links {
            section_title_lower = link.get("section_title", "").lower();
            
            # High priority exact matches
            if ("beyond oop" in message_lower and "beyond oop" in section_title_lower) {
                suggestions.append({
                    "url": link["url"],
                    "title": link["section_title"],
                    "reason": f"Direct match for {link['section_title']} concept",
                    "score": 25
                });
            } elif ("agentic programming" in message_lower and "agentic" in section_title_lower) {
                suggestions.append({
                    "url": link["url"],
                    "title": link["section_title"],
                    "reason": f"Learn about {link['section_title']}",
                    "score": 25
                });
            } elif ("programming abstractions" in message_lower and "programming abstractions" in section_title_lower) {
                suggestions.append({
                    "url": link["url"],
                    "title": link["section_title"],
                    "reason": f"Discover {link['section_title']}",
                    "score": 24
                });
            }
        }
        
        print(f"Found {len(suggestions)} exact section matches");
        
        # Second: Keyword-based suggestions (always add if keywords match)
        
        # Walker-specific
        if "walker" in message_lower {
            print("Found walker keyword");
            # Look for walker-specific sections
            for link in section_links {
                section_title_lower = link.get("section_title", "").lower();
                if "walker" in section_title_lower {
                    suggestions.append({
                        "url": link["url"],
                        "title": link["section_title"],
                        "reason": f"Learn about {link['section_title']}",
                        "score": 20
                    });
                }
            }
            # Add general walker documentation
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/data_spatial/walkers/",
                "title": "Walkers Guide",
                "reason": "Complete guide to using walkers for data traversal and processing",
                "score": 20
            });
        }
        
        # Node/Edge/Graph concepts and OSP (Object-Spatial Programming)
        spatial_keywords = ["node", "edge", "graph", "spatial", "object", "osp", "object spatial", "object-spatial"];
        spatial_found = False;
        osp_specific = False;
        
        for keyword in spatial_keywords {
            if keyword in message_lower {
                spatial_found = True;
                if keyword == "osp" or "object spatial" in message_lower or "object-spatial" in message_lower {
                    osp_specific = True;
                }
                print(f"Found spatial keyword: {keyword}");
                break;
            }
        }
        
        if osp_specific {
            # OSP-specific comprehensive suggestions
            suggestions.extend([
                {
                    "url": "https://www.jac-lang.org/learn/dspfoundation/",
                    "title": "Object Spatial Programming Specification",
                    "reason": "Complete specification and foundation of Object-Spatial Programming",
                    "score": 22
                },
                {
                    "url": "https://www.jac-lang.org/learn/data_spatial/nodes_and_edges/",
                    "title": "Nodes and Edges",
                    "reason": "Core concepts of nodes and edges in Object-Spatial Programming",
                    "score": 21
                },
                {
                    "url": "https://www.jac-lang.org/learn/data_spatial/walkers/",
                    "title": "Walkers",
                    "reason": "Learn about walkers for traversing spatial data structures",
                    "score": 20
                },
                {
                    "url": "https://www.jac-lang.org/learn/data_spatial/filtering/",
                    "title": "Node and Edges Filtering",
                    "reason": "Advanced filtering techniques for nodes and edges",
                    "score": 19
                },
                {
                    "url": "https://www.jac-lang.org/learn/data_spatial/sequence/",
                    "title": "Walker and Node ability trigger sequence",
                    "reason": "Understanding execution sequences in Object-Spatial Programming",
                    "score": 18
                }
            ]);
        } elif spatial_found {
            # General spatial programming suggestions
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/data_spatial/nodes_and_edges/",
                "title": "Nodes and Edges",
                "reason": "Learn about Object-Spatial Programming with nodes and edges",
                "score": 18
            });
        }
        
        # AI/LLM related
        ai_keywords = ["ai", "llm", "artificial intelligence", "language model"];
        ai_found = False;
        for keyword in ai_keywords {
            if keyword in message_lower {
                ai_found = True;
                print(f"Found AI keyword: {keyword}");
                break;
            }
        }
        
        if ai_found {
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/introduction/#programming-abstractions-for-ai",
                "title": "Programming Abstractions for AI",
                "reason": "Learn about Jac's AI-first programming constructs",
                "score": 17
            });
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/jac-byllm/with_llm/",
                "title": "Working with LLMs",
                "reason": "Deep dive into using Large Language Models in Jac",
                "score": 16
            });
        }
        
        # Getting started
        start_keywords = ["start", "begin", "new", "intro", "hello", "getting started"];
        start_found = False;
        for keyword in start_keywords {
            if keyword in message_lower {
                start_found = True;
                print(f"Found start keyword: {keyword}");
                break;
            }
        }
        
        if start_found {
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/introduction/#beyond-oop-an-agentic-programming-model",
                "title": "Beyond OOP: An Agentic Programming Model",
                "reason": "Perfect introduction to Jac's innovative paradigm",
                "score": 15
            });
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/getting_started/",
                "title": "Getting Started",
                "reason": "Step-by-step guide to start coding in Jac",
                "score": 14
            });
        }
        
        print(f"Total suggestions after keyword matching: {len(suggestions)}");
        
        # Sort by score (highest first) - Manual bubble sort
        for i in range(len(suggestions)) {
            for j in range(len(suggestions) - 1 - i) {
                if suggestions[j]["score"] < suggestions[j + 1]["score"] {
                    temp = suggestions[j];
                    suggestions[j] = suggestions[j + 1];
                    suggestions[j + 1] = temp;
                }
            }
        }
        
        # Default suggestions if still no matches
        if len(suggestions) == 0 {
            suggestions = [
                {
                    "url": "https://www.jac-lang.org/learn/introduction/",
                    "title": "Tour of Jac",
                    "reason": "Complete introduction and tour of the Jac programming language",
                    "score": 1
                },
                {
                    "url": "https://www.jac-lang.org/learn/jac_ref/",
                    "title": "Jac Language Reference",
                    "reason": "Comprehensive reference for Jac language syntax and features",
                    "score": 1
                },
                {
                    "url": "https://www.jac-lang.org/learn/data_spatial/nodes_and_edges/",
                    "title": "Nodes and Edges",
                    "reason": "Master Object-Spatial Programming basics with nodes and edges",
                    "score": 1
                }
            ];
        }
        
        # Return top 5 suggestions
        limited_suggestions = [];
        for i in range(min(5, len(suggestions))) {
            suggestion = suggestions[i];
            limited_suggestions.append({
                "url": suggestion["url"],
                "title": suggestion["title"],
                "reason": suggestion["reason"]
            });
        }
        
        report {
            "success": True,
            "suggestions": limited_suggestions,
            "total": len(limited_suggestions)
        };
    }
}
