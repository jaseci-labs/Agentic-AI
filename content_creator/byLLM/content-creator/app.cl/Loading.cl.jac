def Loading(props: dict) -> any {
    let message = props.message if props.message else "Generating your content...";
    let showProgress = props.showProgress if props.showProgress else False;
    let currentStep = props.currentStep if props.currentStep else "";
    
    # Progress history tracking - array of completed steps with iterations
    # Example: [{"agent": "planner", "iteration": 1, "status": "completed"}, ...]
    let progressHistory = props.progressHistory if props.progressHistory else [];
    
    # Current active agent with iteration count
    let currentAgent = props.currentAgent if props.currentAgent else "";
    let currentIteration = props.currentIteration if props.currentIteration else 1;
    
    # Helper function to get step status
    def getStepStatus(agentName: str) -> str {
        let completed = False;
        let active = False;
        let iterationCount = 0;
        
        for step in progressHistory {
            if step["agent"] == agentName {
                iterationCount = iterationCount + 1;
                if step["status"] == "completed" {
                    completed = True;
                }
            }
        }
        
        if currentAgent == agentName {
            active = True;
            iterationCount = currentIteration;
        }
        
        return {"completed": completed, "active": active, "iterations": iterationCount};
    }
    
    let plannerStatus = getStepStatus("planner");
    let writerStatus = getStepStatus("writer");
    let reviewerStatus = getStepStatus("reviewer");
    let mediaStatus = getStepStatus("media");
    
    return <div className="w-full max-w-4xl mx-auto">
        <div className="bg-white rounded-2xl shadow-2xl p-8 md:p-12">
            <div className="flex flex-col items-center justify-center space-y-6">
                # Animated Spinner
                <div className="relative">
                    <div className="w-24 h-24 border-8 border-indigo-200 border-t-indigo-600 rounded-full animate-spin"></div>
                    <div className="absolute inset-0 flex items-center justify-center">
                        <div className="w-16 h-16 border-8 border-purple-200 border-t-purple-600 rounded-full animate-spin-reverse"></div>
                    </div>
                </div>

                # Loading Message
                <div className="text-center space-y-3">
                    <h2 className="text-2xl md:text-3xl font-bold text-gray-800">
                        {message}
                    </h2>
                    
                    {currentStep != "" and (
                        <p className="text-lg text-indigo-600 font-semibold animate-pulse">
                            {currentStep}
                        </p>
                    )}
                    
                    <p className="text-gray-600 text-base">
                        This may take a few moments. Please wait...
                    </p>
                </div>

                # Dynamic Progress Steps with Iteration Tracking
                {showProgress and (
                    <div className="w-full max-w-md space-y-3 pt-4">
                        # Planner
                        <div className="flex items-center space-x-3">
                            {plannerStatus["active"] and (
                                <div className="w-8 h-8 rounded-full bg-indigo-500 flex items-center justify-center">
                                    <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                                </div>
                            )}
                            {not plannerStatus["active"] and plannerStatus["completed"] and (
                                <div className="w-8 h-8 rounded-full bg-green-500 flex items-center justify-center text-white font-bold">
                                    ✓
                                </div>
                            )}
                            {not plannerStatus["active"] and not plannerStatus["completed"] and (
                                <div className="w-8 h-8 rounded-full bg-gray-300 flex items-center justify-center text-gray-500 font-bold">
                                    1
                                </div>
                            )}
                            <div className="flex-1 flex items-center justify-between">
                                {plannerStatus["active"] or plannerStatus["completed"] and (
                                    <span className="text-gray-700 font-semibold">
                                        Planning content structure
                                    </span>
                                )}
                                {not plannerStatus["active"] and not plannerStatus["completed"] and (
                                    <span className="text-gray-500">
                                        Planning content structure
                                    </span>
                                )}
                                {plannerStatus["iterations"] > 1 and (
                                    <span className="text-xs bg-amber-100 text-amber-700 px-2 py-1 rounded-full font-semibold">
                                        Attempt {plannerStatus["iterations"]}
                                    </span>
                                )}
                            </div>
                        </div>
                        
                        # Writer
                        <div className="flex items-center space-x-3">
                            {writerStatus["active"] and (
                                <div className="w-8 h-8 rounded-full bg-indigo-500 flex items-center justify-center">
                                    <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                                </div>
                            )}
                            {not writerStatus["active"] and writerStatus["completed"] and (
                                <div className="w-8 h-8 rounded-full bg-green-500 flex items-center justify-center text-white font-bold">
                                    ✓
                                </div>
                            )}
                            {not writerStatus["active"] and not writerStatus["completed"] and (
                                <div className="w-8 h-8 rounded-full bg-gray-300 flex items-center justify-center text-gray-500 font-bold">
                                    2
                                </div>
                            )}
                            <div className="flex-1 flex items-center justify-between">
                                {writerStatus["active"] or writerStatus["completed"] and (
                                    <span className="text-gray-700 font-semibold">
                                        Writing content
                                    </span>
                                )}
                                {not writerStatus["active"] and not writerStatus["completed"] and (
                                    <span className="text-gray-500">
                                        Writing content
                                    </span>
                                )}
                                {writerStatus["iterations"] > 1 and (
                                    <span className="text-xs bg-blue-100 text-blue-700 px-2 py-1 rounded-full font-semibold">
                                        Revision {writerStatus["iterations"]}
                                    </span>
                                )}
                            </div>
                        </div>
                        
                        # Reviewer
                        <div className="flex items-center space-x-3">
                            {reviewerStatus["active"] and (
                                <div className="w-8 h-8 rounded-full bg-indigo-500 flex items-center justify-center">
                                    <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                                </div>
                            )}
                            {not reviewerStatus["active"] and reviewerStatus["completed"] and (
                                <div className="w-8 h-8 rounded-full bg-green-500 flex items-center justify-center text-white font-bold">
                                    ✓
                                </div>
                            )}
                            {not reviewerStatus["active"] and not reviewerStatus["completed"] and (
                                <div className="w-8 h-8 rounded-full bg-gray-300 flex items-center justify-center text-gray-500 font-bold">
                                    3
                                </div>
                            )}
                            <div className="flex-1 flex items-center justify-between">
                                {reviewerStatus["active"] or reviewerStatus["completed"] and (
                                    <span className="text-gray-700 font-semibold">
                                        Reviewing quality
                                    </span>
                                )}
                                {not reviewerStatus["active"] and not reviewerStatus["completed"] and (
                                    <span className="text-gray-500">
                                        Reviewing quality
                                    </span>
                                )}
                                {reviewerStatus["iterations"] > 1 and (
                                    <span className="text-xs bg-purple-100 text-purple-700 px-2 py-1 rounded-full font-semibold">
                                        Review {reviewerStatus["iterations"]}
                                    </span>
                                )}
                            </div>
                        </div>
                        
                        # Media Generator
                        <div className="flex items-center space-x-3">
                            {mediaStatus["active"] and (
                                <div className="w-8 h-8 rounded-full bg-indigo-500 flex items-center justify-center">
                                    <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                                </div>
                            )}
                            {not mediaStatus["active"] and mediaStatus["completed"] and (
                                <div className="w-8 h-8 rounded-full bg-green-500 flex items-center justify-center text-white font-bold">
                                    ✓
                                </div>
                            )}
                            {not mediaStatus["active"] and not mediaStatus["completed"] and (
                                <div className="w-8 h-8 rounded-full bg-gray-300 flex items-center justify-center text-gray-500 font-bold">
                                    4
                                </div>
                            )}
                            <div className="flex-1 flex items-center justify-between">
                                {mediaStatus["active"] or mediaStatus["completed"] and (
                                    <span className="text-gray-700 font-semibold">
                                        Generating media
                                    </span>
                                )}
                                {not mediaStatus["active"] and not mediaStatus["completed"] and (
                                    <span className="text-gray-500">
                                        Generating media
                                    </span>
                                )}
                            </div>
                        </div>
                    </div>
                )}

                # Animated Dots
                <div className="flex space-x-2">
                    <div className="w-3 h-3 bg-indigo-600 rounded-full animate-bounce"></div>
                    <div className="w-3 h-3 bg-indigo-600 rounded-full animate-bounce"></div>
                    <div className="w-3 h-3 bg-indigo-600 rounded-full animate-bounce"></div>
                </div>
            </div>
        </div>
    </div>;
}
