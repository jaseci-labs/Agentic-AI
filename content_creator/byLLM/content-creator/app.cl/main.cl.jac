import from react {useState, useEffect}
import ".global.css";

def app() -> any {
    let [isLoading, setIsLoading] = useState(False);
    let [currentStep, setCurrentStep] = useState("");
    let [generatedContent, setGeneratedContent] = useState(null);
    
    async def handleFormSubmit(formData: dict) -> None {
        console.log("Form Data Submitted: ", formData);
        setIsLoading(True);
        setCurrentStep("Planning content structure...");
        
        try {
            # Prepare user input in the expected format
            let user_input = {
                "field": formData["field"],
                "topic": formData["topic"],
                "output_format": formData["outputFormat"],
                "tone": formData["tone"],
                "audience": formData["audience"],
                "write_as": formData["writeAs"]
            };
            
            # Call the SupervisorAgent with the user input
            response = root spawn SupervisorAgent(user_input, "");
            
            # TODO: Poll or listen for progress updates from session state
            # For now, wait and get final result
            setIsLoading(False);
            
            # Extract content from response/session
            # if response and response.session and response.session.current_state {
            #     let article = response.session.current_state["article"] or "No content generated";
            #     let imageUrl = null;
            #     if response.session.current_state["media_generated"] {
            #         imageUrl = "article_image.png";
            #     }
                
            #     setGeneratedContent({
            #         "content": article,
            #         "imageUrl": imageUrl
            #     });
            # } else {
            #     setGeneratedContent({
            #         "content": "# Content Generation Complete\n\nPlease check the output files.",
            #         "imageUrl": null
            #     });
            # }
        } except error {
            console.error("Error generating content: ", error);
            setIsLoading(False);
            # TODO: Show error message to user
        }
    }
    
    def handleReset() -> None {
        setGeneratedContent(null);
        setIsLoading(False);
        setCurrentStep("");
    }
    
    
    # -------------------------------- UI Rendering ----------------------------
    let content = <InputForm onSubmit={handleFormSubmit} isLoading={isLoading} />;
    
    if isLoading {
        content = <Loading message="AI is creating your content" currentStep={currentStep} showProgress={True} />;
    }
    
    if generatedContent {
        content = <ContentDisplay 
            content={generatedContent["content"]} 
            imageUrl={generatedContent["imageUrl"]} 
            onReset={handleReset} 
        />;
    }
    
    return <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4">
        {content}
    </div>;
}