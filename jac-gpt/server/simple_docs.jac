# Documentation API for serving Jac documentation content

walker get_sitemap {
    """Get sitemap URLs for documentation"""
    
    obj __specs__ {
        static has methods: list = ["get"];
        static has auth: bool = False;
    }

    can serve_sitemap with `root entry {
        import os;
        
        try {
            sitemap_path = os.path.join(os.path.dirname(__file__), "sitemap.xml");
            with open(sitemap_path, 'r', encoding='utf-8') as f {
                content = f.read();
            }
            
            report {
                "success": True,
                "content": content
            };
        } except Exception as e {
            report {
                "success": False,
                "error": str(e)
            };
        }
    }
}

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
    """Suggest relevant documentation based on user message"""
    has message: str;
    has chat_history: list[dict] = [];
    
    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = False;
    }

    can get_suggestions with `root entry {
        # Simple keyword-based suggestions
        message_lower = self.message.lower();
        suggestions = [];
        
        # Helper function to check if message contains keywords
        def has_keywords(text: str, words: list[str]) -> bool {
            for word in words {
                if word in text {
                    return True;
                }
            }
            return False;
        }
        
        # Getting started
        start_words = ["start", "begin", "new", "intro", "hello", "hi"];
        if has_keywords(message_lower, start_words) {
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/introduction/",
                "title": "Introduction to Jac",
                "reason": "Perfect starting point for learning Jac programming language"
            });
        }
        
        # Object-Spatial Programming
        spatial_words = ["node", "edge", "graph", "spatial", "object"];
        if has_keywords(message_lower, spatial_words) {
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/data_spatial/nodes_and_edges/",
                "title": "Nodes and Edges",
                "reason": "Learn about Object-Spatial Programming with nodes and edges"
            });
        }
        
        # AI and LLM integration
        ai_words = ["ai", "llm", "intelligence", "model", "gpt", "claude"];
        if has_keywords(message_lower, ai_words) {
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/jac-mtllm/quickstart/",
                "title": "AI Integration Quickstart",
                "reason": "Learn how to integrate AI and LLM capabilities in your Jac applications"
            });
        }
        
        # Cloud and deployment
        cloud_words = ["cloud", "deploy", "server", "scale", "production"];
        if has_keywords(message_lower, cloud_words) {
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/jac-cloud/introduction/",
                "title": "Jac Cloud Introduction",
                "reason": "Learn about cloud deployment and scaling with Jac"
            });
        }
        
        # Walkers
        walker_words = ["walker", "walk", "traverse", "visit"];
        if has_keywords(message_lower, walker_words) {
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/data_spatial/walkers/",
                "title": "Walkers Guide",
                "reason": "Complete guide to using walkers for data traversal and processing"
            });
        }
        
        # Examples and tutorials
        example_words = ["example", "tutorial", "sample", "demo", "project"];
        if has_keywords(message_lower, example_words) {
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/examples/rag_chatbot/Overview/",
                "title": "RAG Chatbot Example",
                "reason": "Build a complete RAG-powered chatbot with Jac"
            });
        }
        
        # Default suggestions if no specific keywords found
        if len(suggestions) == 0 {
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/introduction/",
                "title": "Introduction to Jac",
                "reason": "Perfect starting point for learning Jac programming language"
            });
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/data_spatial/nodes_and_edges/",
                "title": "Nodes and Edges",
                "reason": "Learn about Object-Spatial Programming core concepts"
            });
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/jac-mtllm/quickstart/",
                "title": "AI Integration",
                "reason": "Discover how to integrate AI capabilities in Jac"
            });
        }
        
        # Return top 3 suggestions
        limited_suggestions = [];
        count = 0;
        for suggestion in suggestions {
            if count < 3 {
                limited_suggestions.append(suggestion);
                count += 1;
            }
        }
        
        report {
            "success": True,
            "suggestions": limited_suggestions,
            "total": len(limited_suggestions)
        };
    }
}
