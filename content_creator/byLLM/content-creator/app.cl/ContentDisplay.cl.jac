def ContentDisplay(props: dict) -> any {
    let content = props.content;
    let imageUrl = props.imageUrl;
    let onReset = props.onReset;
    
    let [copied, setCopied] = useState(False);
    
    def handleCopy() -> None {
        navigator.clipboard.writeText(content);
        setCopied(True);
        setTimeout(lambda -> None {
            setCopied(False);
        }, 2000);
    }
    
    def handleDownload() -> None {
        let blob = Blob([content], {"type": "text/markdown"});
        let url = URL.createObjectURL(blob);
        let a = document.createElement("a");
        a.href = url;
        a.download = "generated-content.md";
        a.click();
        URL.revokeObjectURL(url);
    }
    
    return <div className="w-full max-w-6xl mx-auto space-y-6">
        # Header with actions
        <div className="bg-white rounded-2xl shadow-2xl p-6">
            <div className="flex flex-col md:flex-row justify-between items-center gap-4">
                <div>
                    <h2 className="text-3xl font-bold text-gray-800">Your Content is Ready!</h2>
                    <p className="text-gray-600 mt-1">Generated with AI</p>
                </div>
                
                <div className="flex gap-3">
                    <button
                        onClick={handleCopy}
                        className="px-6 py-3 bg-indigo-600 hover:bg-indigo-700 text-white font-semibold rounded-lg transition duration-200 flex items-center gap-2"
                    >
                        {"Copied!" if copied else "Copy"}
                    </button>
                    
                    <button
                        onClick={handleDownload}
                        className="px-6 py-3 bg-green-600 hover:bg-green-700 text-white font-semibold rounded-lg transition duration-200"
                    >
                        Download
                    </button>
                    
                    <button
                        onClick={onReset}
                        className="px-6 py-3 bg-gray-600 hover:bg-gray-700 text-white font-semibold rounded-lg transition duration-200"
                    >
                        New Content
                    </button>
                </div>
            </div>
        </div>
        
        # Generated Image
        {imageUrl and (
            <div className="bg-white rounded-2xl shadow-2xl p-6">
                <h3 className="text-xl font-bold text-gray-800 mb-4">Generated Image</h3>
                <div className="flex justify-center">
                    <img 
                        src={imageUrl} 
                        alt="Generated content image" 
                        className="max-w-full rounded-lg shadow-lg"
                    />
                </div>
            </div>
        )}
        
        # Content Display
        <div className="bg-white rounded-2xl shadow-2xl p-8">
            <h3 className="text-xl font-bold text-gray-800 mb-4">Generated Content</h3>
            
            # Markdown Preview
            <div className="prose prose-lg max-w-none">
                <div className="bg-gray-50 rounded-lg p-6 border border-gray-200">
                    <pre className="whitespace-pre-wrap font-sans text-gray-800 leading-relaxed">
                        {content}
                    </pre>
                </div>
            </div>
        </div>
    </div>;
}
