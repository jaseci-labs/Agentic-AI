import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Header } from '@/components/Layout/Header';
import { PlatformButton } from '@/components/ui/platform-button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { ScrollArea } from '@/components/ui/scroll-area';
import { CheckCircle, Bot, User } from 'lucide-react';

interface QAPair {
  question: string;
  answer: string;
}

const InterviewComplete = () => {
  const navigate = useNavigate();
  const [transcript, setTranscript] = useState<QAPair[]>([]);

    useEffect(() => {
    // Get final transcript from session storage (matches Streamlit logic)
    const storedTranscript = sessionStorage.getItem('finalTranscript');
    if (storedTranscript) {
      try {
        const parsedTranscript = JSON.parse(storedTranscript);
        // Transform the API response format to match component expectations
        if (Array.isArray(parsedTranscript) && parsedTranscript.length > 0) {
          // Check if it's the API format with nested context
          if (parsedTranscript[0]?.context) {
            const transformedTranscript = parsedTranscript.map(item => ({
              question: item.context.question,
              answer: item.context.answer
            }));
            setTranscript(transformedTranscript);
          } else {
            // Already in the expected format
            setTranscript(parsedTranscript);
          }
        }
      } catch (error) {
        console.error('Error parsing transcript:', error);
      }
    }
  }, []);

  // Mock interview transcript data for fallback
  const mockTranscript = [
    {
      type: 'ai',
      content: 'Welcome! Thank you for your interest in the Senior Software Engineer position at Tech Corp Inc. Can you start by telling me about yourself and your background in software development?',
      timestamp: '10:00 AM'
    },
    {
      type: 'candidate',
      content: "I'm a passionate software engineer with over 5 years of experience in full-stack development. I've worked extensively with React, Node.js, and Python, building scalable web applications. My background includes both startup environments and larger corporations, which has given me a well-rounded perspective on software development lifecycle and team collaboration.",
      timestamp: '10:01 AM'
    },
    {
      type: 'ai',
      content: 'What programming languages and technologies are you most comfortable with, and can you describe a challenging project you\'ve worked on recently?',
      timestamp: '10:02 AM'
    },
    {
      type: 'candidate',
      content: "I'm most proficient in JavaScript/TypeScript, Python, and SQL. Recently, I led the development of a real-time analytics dashboard that processes over 1 million events per day. The main challenge was optimizing database queries and implementing efficient caching strategies. We used Redis for caching and PostgreSQL with proper indexing, which reduced response times by 75%.",
      timestamp: '10:04 AM'
    },
    {
      type: 'ai',
      content: 'How do you approach problem-solving when you encounter a complex technical issue? Can you walk me through your process?',
      timestamp: '10:05 AM'
    },
    {
      type: 'candidate',
      content: "My problem-solving approach follows a structured methodology: First, I thoroughly understand the problem by reproducing it and gathering all relevant information. Then I break it down into smaller, manageable components. I research existing solutions and similar problems, often consulting documentation and community resources. I create hypotheses and test them systematically, documenting each attempt. Finally, I implement the solution and create comprehensive tests to prevent regression.",
      timestamp: '10:07 AM'
    },
    {
      type: 'ai',
      content: 'Tell me about a time when you had to work with a difficult team member or handle conflicting priorities. How did you manage the situation?',
      timestamp: '10:08 AM'
    },
    {
      type: 'candidate',
      content: "I once worked with a team member who was resistant to code reviews and best practices. Rather than confronting them directly, I initiated one-on-one conversations to understand their concerns. It turned out they felt their experience wasn't being valued. I suggested they lead a knowledge-sharing session about their expertise area, which boosted their confidence. We also established clearer code review guidelines that everyone agreed upon. This transformed our working relationship and improved team productivity.",
      timestamp: '10:10 AM'
    },
    {
      type: 'ai',
      content: 'What interests you most about this role at Tech Corp Inc., and how do you see yourself contributing to our team?',
      timestamp: '10:11 AM'
    },
    {
      type: 'candidate',
      content: "I'm particularly excited about Tech Corp Inc.'s focus on innovative solutions and technical excellence. Your recent work in AI-driven applications aligns perfectly with my interest in emerging technologies. I believe I can contribute through my experience in scalable architecture design, my collaborative approach to problem-solving, and my passion for mentoring junior developers. I'm also eager to learn from your talented team and help drive the company's technical vision forward.",
      timestamp: '10:13 AM'
    },
    {
      type: 'ai',
      content: 'Thank you for your thoughtful responses! That concludes our interview. Your answers have been recorded and will be reviewed by our hiring team. You should receive feedback within 5-7 business days. Have a great day!',
      timestamp: '10:14 AM'
    }
  ];

  const handleEndSession = () => {
    // Clear all session data (matches Streamlit reset logic)
    sessionStorage.removeItem('candidateId');
    sessionStorage.removeItem('authToken');
    sessionStorage.removeItem('currentQuestion');
    sessionStorage.removeItem('candidateName');
    sessionStorage.removeItem('jobRole');
    sessionStorage.removeItem('finalTranscript');
    navigate('/');
  };

  return (
    <div className="min-h-screen bg-background">
      <Header showAuth={false} />
      
      <div className="container mx-auto px-6 py-12">
        <div className="max-w-4xl mx-auto">
          {/* Completion Message */}
          <Card className="card-shadow-lg border-0 mb-8">
            <CardContent className="p-8 text-center">
              <div className="mb-6 flex justify-center">
                <CheckCircle className="h-16 w-16 text-success" />
              </div>
              <h1 className="mb-4 text-3xl font-bold text-foreground">
                Thank You! Your Interview is Complete.
              </h1>
              <p className="text-lg text-muted-foreground max-w-2xl mx-auto leading-relaxed">
                Your responses have been successfully recorded and will be reviewed by our hiring team. 
                You should receive feedback within 5-7 business days.
              </p>
            </CardContent>
          </Card>

          {/* Interview Transcript */}
          <Card className="card-shadow-lg border-0">
            <CardHeader>
              <CardTitle className="text-2xl font-semibold">
                Final Interview Transcript
              </CardTitle>
              <p className="text-muted-foreground">
                Complete record of your interview session
              </p>
            </CardHeader>
            <CardContent>
              <ScrollArea className="h-96 w-full rounded-lg border p-4">
                <div className="space-y-6">
                  {transcript.length > 0 ? (
                    transcript.map((qa, index) => (
                      <div key={index} className="space-y-4">
                        {/* AI Question */}
                        <div className="flex space-x-3">
                          <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-secondary text-secondary-foreground">
                            <Bot className="h-4 w-4" />
                          </div>
                          <div className="flex-1 space-y-1">
                            <div className="flex items-center space-x-2">
                              <span className="font-medium text-sm">AI Interviewer</span>
                            </div>
                            <p className="text-sm text-foreground leading-relaxed whitespace-pre-wrap">
                              {qa.question}
                            </p>
                          </div>
                        </div>
                        
                        {/* Candidate Answer */}
                        <div className="flex space-x-3">
                          <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-primary text-primary-foreground">
                            <User className="h-4 w-4" />
                          </div>
                          <div className="flex-1 space-y-1">
                            <div className="flex items-center space-x-2">
                              <span className="font-medium text-sm">You</span>
                            </div>
                            <p className="text-sm text-foreground leading-relaxed whitespace-pre-wrap">
                              {qa.answer}
                            </p>
                          </div>
                        </div>
                      </div>
                    ))
                  ) : (
                    <div className="text-center text-muted-foreground py-8">
                      <p>No interview transcript available.</p>
                    </div>
                  )}
                </div>
              </ScrollArea>
              
              <div className="mt-6 text-center">
                <PlatformButton variant="secondary" onClick={handleEndSession}>
                  End Session
                </PlatformButton>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
};

export default InterviewComplete;