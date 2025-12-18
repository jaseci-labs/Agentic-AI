import sys;
import os;
import json;
import time;
import from datetime {datetime}
import from dotenv {load_dotenv}
import from server {infer}
import from rag_engine {load_config}


"""Load test dataset from JSON file"""
def load_test_dataset(file_path: str) -> dict {
    try {
        with open(file_path, "r", encoding="utf-8") as file {
            data = json.load(file);
            return data;
        }
    } except Exception as e {
        print(f"Error loading test dataset: {e}");
        return {"test_cases": []};
    }
}

"""Save results to JSON file in logs folder"""
def save_results(results: dict, output_dir: str = ".logs") -> str {
    try {
        # Create logs directory if it doesn't exist
        os.makedirs(output_dir, exist_ok=True);
        
        # Generate timestamp for filename
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S");
        filename = f"eval_results_{timestamp}.json";
        filepath = os.path.join(output_dir, filename);
        
        # Save results
        with open(filepath, "w", encoding="utf-8") as file {
            json.dump(results, file, indent=2, ensure_ascii=False);
        }
        
        return filepath;
    } except Exception as e {
        print(f"Error saving results: {e}");
        return "";
    }
}

"""Calculate summary statistics from test results"""
def calculate_summary(results: list[dict]) -> dict {
    if not results {
        return {
            "total_tests": 0,
            "min_latency_ms": 0.0,
            "max_latency_ms": 0.0
        };
    }
    
    successful = [r for r in results if r.get("success", False)];
    
    total_latencies = [r["latency_ms"] for r in successful if "latency_ms" in r];
    
    # Calculate min/max safely
    min_lat = 0.0;
    max_lat = 0.0;
    if total_latencies {
        min_lat = total_latencies[0];
        max_lat = total_latencies[0];
        for lat in total_latencies {
            if lat < min_lat {
                min_lat = lat;
            }
            if lat > max_lat {
                max_lat = lat;
            }
        }
    }
    
    return {
        "total_tests": len(results),
        "min_latency_ms": min_lat,
        "max_latency_ms": max_lat
    };
}

"""Evaluate a test dataset and generate results with latency metrics"""
def evaluate_test_dataset(
    test_file: str = "test_dataset.json",
    output_dir: str = ".logs",
    verbose: bool = True,
    notes: str = ""
) {
    # Get current configuration
    config_name = os.getenv('RAG_CONFIG', 'baseline');
    config = load_config(config_name);
    
    print(f"\n{'='*60}");
    print(f"Starting Test Evaluation");
    print(f"{'='*60}");
    print(f"Configuration: {config_name}");
    print(f"Test file: {test_file}");
    print(f"Output directory: {output_dir}\n");
    
    # Load test dataset
    dataset = load_test_dataset(test_file);
    test_cases = dataset.get("test_cases", []);
    
    if not test_cases {
        print("No test cases found in dataset!");
        return;
    }
    
    print(f"Loaded {len(test_cases)} test cases\n");
    
    # Run tests
    results = [];
    for idx in range(len(test_cases)) {
        test_case = test_cases[idx];
        test_id = test_case.get("id", f"test_{idx+1}");
        query = test_case.get("query", "");
        
        if verbose {
            print(f"\n[{idx+1}/{len(test_cases)}] Running: {test_id}");
            print(f"Query: {query[:80]}{'...' if len(query) > 80 else ''}");
        }
        
        # Measure total latency
        start_total = time.perf_counter();
        
        try {
            # Spawn infer walker from server.jac
            response_walker = infer(message=query, chat_history=[]) spawn root;
            
            end_total = time.perf_counter();
            total_latency_ms = (end_total - start_total) * 1000;
            
            # Extract response from walker
            response = response_walker.response;
            
            result = {
                "test_id": test_id,
                "query": query,
                "response": response,
                "response_length": len(response),
                "latency_ms": round(total_latency_ms, 2),
                "success": True,
                "error": None
            };
            
            if verbose {
                print(f"✓ Latency: {round(total_latency_ms, 2)}ms");
            }
            
        } except Exception as e {
            end_total = time.perf_counter();
            total_latency_ms = (end_total - start_total) * 1000;
            
            result = {
                "test_id": test_id,
                "query": query,
                "response": None,
                "response_length": 0,
                "latency_ms": round(total_latency_ms, 2),
                "success": False,
                "error": str(e)
            };
            
            if verbose {
                print(f"✗ Error: {str(e)}");
            }
        }
        
        results.append(result);
    }
    
    # Calculate summary
    summary = calculate_summary(results);
    
    # Prepare final output
    output = {
        "test_run_metadata": {
            "timestamp": datetime.now().isoformat(),
            "test_file": test_file,
            "total_tests": len(test_cases),
            "configuration_name": config_name,
            "configuration": config,
            "notes": notes if notes else "No notes provided"
        },
        "results": results,
        "summary": summary
    };
    
    # Save to file
    output_path = save_results(output, output_dir);
    
    # Print summary
    print(f"\n{'='*60}");
    print(f"Evaluation Complete");
    print(f"{'='*60}");
    print(f"Total Tests: {summary['total_tests']}");
    print(f"Min Latency: {summary['min_latency_ms']:.2f}ms");
    print(f"Max Latency: {summary['max_latency_ms']:.2f}ms");
    print(f"\nResults saved to: {output_path}");
    print(f"{'='*60}\n");
}

with entry {
    load_dotenv(override=True);
    
    print("\n=== Test Evaluator ===");
    print("1. Run test dataset");
    print("2. Test custom query");
    choice = input("Choose option (1 or 2): ").strip();
    
    if choice == "1" {
        notes = input("\nEnter notes for this test run (optional): ").strip();
        test_file_path = "test_datasets/test_dataset.json";
        evaluate_test_dataset(test_file=test_file_path, verbose=False, notes=notes);
    } elif choice == "2" {
        import from server {infer};
        query = input("\nEnter your query: ").strip();
        
        if query {
            print(f"\nProcessing: {query}");
            start = time.perf_counter();
            
            response_walker = infer(message=query, chat_history=[]) spawn root;
            
            end = time.perf_counter();
            latency = (end - start) * 1000;
            
            print(f"\n{'='*60}");
            print(f"Response:");
            print(f"{'='*60}");
            print(response_walker.response);
            print(f"\n{'='*60}");
            print(f"Latency: {latency:.2f}ms");
            print(f"{'='*60}\n");
        } else {
            print("No query provided.");
        }
    } else {
        print("Invalid choice. Exiting.");
    }
}
