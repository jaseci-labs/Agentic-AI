# Multi-Agent Content Creator

- Trend Agent: Identifies trending topics (as in the guide).

 - Research Agent: Picks the most promising topic, researches it, and creates a detailed outline and fact sheet.

 - Writer Agent: Takes the outline and writes a first draft of the article.

- Critique Agent (The Loop): It reviews the draft from the Writer against a set of criteria (clarity, SEO, brand voice, factual accuracy using citations).

If revisions are needed: The critique and the draft are sent back to the Writer Agent for another round of editing. 
If the draft is approved: The state is passed to the Media and Publisher agents.


- Media Agent: Once the article is finalized, this agent generates a thumbnail and a video script/short video based on the approved content.

- Publisher Agent: Takes all the final assets (article, thumbnail, video) and "publishes" them (or stages them for publishing).