sem Supervisor.call_next_agent = """Decide the next agent based on current_state:
    
    First, check end conditions:
    - If current_state["approved"] == True → return END
    - If current_state.get("revision_count", 0) >= 5 → return END
    
    Then route based on current_state["stage"]:
    - PLANNING → PLANNER_AGENT
    - WRITING → WRITER_AGENT
    - REVIEWING → REVIEW_AGENT
    - REVISING → WRITER_AGENT (content needs rewriting)
    - COMPLETED → END
    
    Return the appropriate AgentTypes value.""";


sem PlannerAgent.plan_content = """Create a detailed content plan including: 
                                    1) Target audience, 
                                    2) Key objectives, 
                                    3) Content structure, 
                                    4) Key points to cover, 
                                    5) Tone and style guidelines. 
                                Be specific and actionable.""";


sem WriterAgent.write_content = """Create high-quality content based on the provided plan. If feedback is provided, incorporate it to improve the content. Focus on clarity, engagement, and meeting the objectives outlined in the plan.""";

sem ReviewAgent.review_content = """Review the content for APPROVAL. Only reject if content has CRITICAL issues:

    CRITICAL REJECTION CRITERIA (is_approved = false):
    1. Word count exceeds 100 words (MANDATORY rejection)
    2. Content is completely unrelated to the plan
    3. Content is gibberish or incomprehensible

    APPROVAL CRITERIA (is_approved = true):
    - Word count is 100 words or less
    - Content is reasonably related to the plan  
    - Content is understandable

    DO NOT reject for minor improvements, suggestions, or subjective preferences.
    If content meets basic requirements, APPROVE it even if it could be improved.""";