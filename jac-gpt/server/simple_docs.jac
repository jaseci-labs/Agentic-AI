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
        # Enhanced keyword-based suggestions with priority scoring
        message_lower = self.message.lower();
        suggestions = [];
        
        # Helper function to check if message contains keywords and return score
        def has_keywords_with_score(text: str, words: list[str]) -> int {
            score = 0;
            for word in words {
                if word in text {
                    score += 1;
                }
            }
            return score;
        }
        
        # MTLLM/MTP specific - High priority for AI/LLM related queries
        mtllm_words = ["mtllm", "mtp", "multi-turn", "conversation", "context", "llm integration", "language model"];
        mtllm_score = has_keywords_with_score(message_lower, mtllm_words);
        if mtllm_score > 0 {
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/jac-byllm/with_llm/",
                "title": "Working with LLMs - MTLLM",
                "reason": "Complete guide to Multi-Turn LLM integration and context management",
                "score": mtllm_score + 10  # High priority
            });
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/jac-mtllm/quickstart/",
                "title": "AI Integration Quickstart",
                "reason": "Quick start guide for integrating AI capabilities in Jac",
                "score": mtllm_score + 8
            });
        }
        
        # AI and LLM integration - General
        ai_words = ["ai", "llm", "intelligence", "model", "gpt", "claude", "openai", "artificial intelligence", "machine learning"];
        ai_score = has_keywords_with_score(message_lower, ai_words);
        if ai_score > 0 {
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/jac-byllm/with_llm/",
                "title": "Working with LLMs",
                "reason": "Deep dive into using Large Language Models in Jac applications",
                "score": ai_score + 9
            });
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/jac-mtllm/quickstart/",
                "title": "AI Integration Quickstart",
                "reason": "Learn how to integrate AI and LLM capabilities in your Jac applications",
                "score": ai_score + 7
            });
        }
        
        # Object-Spatial Programming
        spatial_words = ["node", "edge", "graph", "spatial", "object", "relationship", "data structure"];
        spatial_score = has_keywords_with_score(message_lower, spatial_words);
        if spatial_score > 0 {
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/data_spatial/nodes_and_edges/",
                "title": "Nodes and Edges",
                "reason": "Learn about Object-Spatial Programming with nodes and edges",
                "score": spatial_score + 8
            });
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/data_spatial/",
                "title": "Data-Spatial Programming",
                "reason": "Complete guide to data-spatial programming concepts",
                "score": spatial_score + 6
            });
        }
        
        # Walkers
        walker_words = ["walker", "walk", "traverse", "visit", "navigation", "path"];
        walker_score = has_keywords_with_score(message_lower, walker_words);
        if walker_score > 0 {
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/data_spatial/walkers/",
                "title": "Walkers Guide",
                "reason": "Complete guide to using walkers for data traversal and processing",
                "score": walker_score + 8
            });
        }
        
        # Cloud and deployment
        cloud_words = ["cloud", "deploy", "server", "scale", "production", "hosting", "deployment"];
        cloud_score = has_keywords_with_score(message_lower, cloud_words);
        if cloud_score > 0 {
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/jac-cloud/introduction/",
                "title": "Jac Cloud Introduction",
                "reason": "Learn about cloud deployment and scaling with Jac",
                "score": cloud_score + 7
            });
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/jac-cloud/deployment/",
                "title": "Deployment Guide",
                "reason": "Step-by-step deployment instructions for production",
                "score": cloud_score + 6
            });
        }
        
        # Examples and tutorials
        example_words = ["example", "tutorial", "sample", "demo", "project", "build", "create"];
        example_score = has_keywords_with_score(message_lower, example_words);
        if example_score > 0 {
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/examples/rag_chatbot/Overview/",
                "title": "RAG Chatbot Example",
                "reason": "Build a complete RAG-powered chatbot with Jac",
                "score": example_score + 7
            });
            suggestions.append({
                "url": "https://www.jac-lang.org/jac_book/chapter_1/",
                "title": "Jac Book - Examples",
                "reason": "Comprehensive examples and tutorials",
                "score": example_score + 6
            });
        }
        
        # Syntax and language features
        syntax_words = ["syntax", "code", "function", "class", "variable", "programming", "keyword"];
        syntax_score = has_keywords_with_score(message_lower, syntax_words);
        if syntax_score > 0 {
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/keywords/",
                "title": "Jac Keywords Reference",
                "reason": "Complete reference for Jac language keywords and syntax",
                "score": syntax_score + 6
            });
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/jac_ref/",
                "title": "Language Reference",
                "reason": "Complete Jac language reference and syntax guide",
                "score": syntax_score + 5
            });
        }
        
        # Getting started
        start_words = ["start", "begin", "new", "intro", "hello", "hi", "getting started"];
        start_score = has_keywords_with_score(message_lower, start_words);
        if start_score > 0 {
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/introduction/",
                "title": "Introduction to Jac",
                "reason": "Perfect starting point for learning Jac programming language",
                "score": start_score + 6
            });
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/getting_started/",
                "title": "Getting Started Guide",
                "reason": "Step-by-step guide to set up and start coding in Jac",
                "score": start_score + 5
            });
        }
        
        # Tools and development
        tools_words = ["tool", "cli", "debug", "development", "playground", "ide"];
        tools_score = has_keywords_with_score(message_lower, tools_words);
        if tools_score > 0 {
            suggestions.append({
                "url": "https://www.jac-lang.org/playground/",
                "title": "Jac Playground",
                "reason": "Try Jac code online without any setup",
                "score": tools_score + 6
            });
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/tools/cli/",
                "title": "CLI Tools",
                "reason": "Learn about Jac command-line tools and utilities",
                "score": tools_score + 5
            });
        }
        
        # Sort suggestions by score (highest first) - Manual sorting for Jac
        # Simple bubble sort by score
        for i in range(len(suggestions)) {
            for j in range(len(suggestions) - 1 - i) {
                if suggestions[j]["score"] < suggestions[j + 1]["score"] {
                    temp = suggestions[j];
                    suggestions[j] = suggestions[j + 1];
                    suggestions[j + 1] = temp;
                }
            }
        }
        
        # Default suggestions if no specific keywords found
        if len(suggestions) == 0 {
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/introduction/",
                "title": "Introduction to Jac",
                "reason": "Perfect starting point for learning Jac programming language",
                "score": 1
            });
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/data_spatial/nodes_and_edges/",
                "title": "Nodes and Edges",
                "reason": "Learn about Object-Spatial Programming core concepts",
                "score": 1
            });
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/jac-mtllm/quickstart/",
                "title": "AI Integration",
                "reason": "Discover how to integrate AI capabilities in Jac",
                "score": 1
            });
        }
        
        # Return top 3 suggestions without score in the response
        limited_suggestions = [];
        count = 0;
        for suggestion in suggestions {
            if count < 3 {
                clean_suggestion = {
                    "url": suggestion["url"],
                    "title": suggestion["title"],
                    "reason": suggestion["reason"]
                };
                limited_suggestions.append(clean_suggestion);
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
