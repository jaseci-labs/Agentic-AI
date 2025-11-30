# import from react {useState}

def InputForm(props: dict) -> any {
    let onSubmit = props.onSubmit;
    let isLoading = props.isLoading;
    
    # State for each form field separately
    let [field, setField] = useState("technology");
    let [topic, setTopic] = useState("");
    let [outputFormat, setOutputFormat] = useState("markdown");
    let [tone, setTone] = useState("");
    let [audience, setAudience] = useState("");
    let [writeAs, setWriteAs] = useState("personal blog post");

    # Field options for dropdown
    let fieldOptions = [
        "technology", 
        "health", 
        "finance", 
        "education", 
        "lifestyle", 
        "business",
        "science",
        "entertainment",
    ];

    # Output format options
    let formatOptions = [
        "markdown",
        "html", 
        "plain text",
    ];

    # Write as options
    let writeAsOptions = [
        "personal blog post",
        "professional article",
        "tutorial",
        "guide",
        "opinion piece",
        "news article",
    ];

    # Handle form submission
    def handleSubmit(e: any) -> None {
        e.preventDefault();
        if onSubmit {
            let formData = {
                "field": field,
                "topic": topic,
                "output_format": outputFormat,
                "tone": tone,
                "audience": audience,
                "write_as": writeAs,
            };
            onSubmit(formData);
        }
    }

    return <div className="w-full max-w-4xl mx-auto">
        <div className="bg-white rounded-2xl shadow-2xl p-8 md:p-12">
            <div className="mb-8 text-center">
                <h1 className="text-4xl md:text-5xl font-bold text-gray-800 mb-3">
                    AI Content Creator
                </h1>
                <p className="text-gray-600 text-lg">
                    Generate high-quality content with AI assistance
                </p>
            </div>

            <form onSubmit={handleSubmit} className="space-y-6">
                # Field Dropdown
                <div className="form-group">
                    <label className="block text-sm font-semibold text-gray-700 mb-2">
                        Field <span className="text-red-500">*</span>
                    </label>
                    <select
                        value={field}
                        onChange={lambda e: any -> None { setField(e.target.value); }}
                        className="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition duration-200"
                        required={True}
                    >
                        {fieldOptions.map(lambda option: any -> any {
                            return <option key={option} value={option}>
                                {option.charAt(0).toUpperCase() + option.slice(1)}
                            </option>;
                        })}
                    </select>
                </div>

                # Topic Input
                <div className="form-group">
                    <label className="block text-sm font-semibold text-gray-700 mb-2">
                        Topic <span className="text-red-500">*</span>
                    </label>
                    <input
                        type="text"
                        value={topic}
                        onChange={lambda e: any -> None { setTopic(e.target.value); }}
                        placeholder="e.g., The Future of AI in Content Creation"
                        className="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition duration-200"
                        required={True}
                    />
                </div>

                # Output Format Dropdown
                <div className="form-group">
                    <label className="block text-sm font-semibold text-gray-700 mb-2">
                        Output Format <span className="text-red-500">*</span>
                    </label>
                    <select
                        value={outputFormat}
                        onChange={lambda e: any -> None { setOutputFormat(e.target.value); }}
                        className="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition duration-200"
                        required={True}
                    >
                        {formatOptions.map(lambda option: any -> any {
                            return <option key={option} value={option}>
                                {option.charAt(0).toUpperCase() + option.slice(1)}
                            </option>;
                        })}
                    </select>
                </div>

                # Tone Input
                <div className="form-group">
                    <label className="block text-sm font-semibold text-gray-700 mb-2">
                        Tone <span className="text-red-500">*</span>
                    </label>
                    <input
                        type="text"
                        value={tone}
                        onChange={lambda e: any -> None { setTone(e.target.value); }}
                        placeholder="e.g., informative and engaging"
                        className="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition duration-200"
                        required={True}
                    />
                </div>

                # Audience Input
                <div className="form-group">
                    <label className="block text-sm font-semibold text-gray-700 mb-2">
                        Target Audience <span className="text-red-500">*</span>
                    </label>
                    <input
                        type="text"
                        value={audience}
                        onChange={lambda e: any -> None { setAudience(e.target.value); }}
                        placeholder="e.g., tech enthusiasts and professionals"
                        className="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition duration-200"
                        required={True}
                    />
                </div>

                # Write As Dropdown
                <div className="form-group">
                    <label className="block text-sm font-semibold text-gray-700 mb-2">
                        Write As <span className="text-red-500">*</span>
                    </label>
                    <select
                        value={writeAs}
                        onChange={lambda e: any -> None { setWriteAs(e.target.value); }}
                        className="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition duration-200"
                        required={True}
                    >
                        {writeAsOptions.map(lambda option: any -> any {
                            return <option key={option} value={option}>
                                {option.charAt(0).toUpperCase() + option.slice(1)}
                            </option>;
                        })}
                    </select>
                </div>

                # Submit Button
                <div className="pt-4">
                    <button
                        type="submit"
                        disabled={isLoading}
                        className="w-full bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-700 hover:to-purple-700 text-white font-bold py-4 px-6 rounded-lg transition duration-200 ease-in-out transform hover:scale-[1.02] active:scale-[0.98] disabled:opacity-50 disabled:cursor-not-allowed shadow-lg"
                    >
                        {"🚀 Generating Content..." if isLoading else "Generate Content"}
                    </button>
                </div>
            </form>
        </div>
    </div>;
}
