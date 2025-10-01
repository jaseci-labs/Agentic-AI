import React, { useState, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { Header } from '@/components/Layout/Header';
import { PlatformButton } from '@/components/ui/platform-button';
import { Card, CardContent } from '@/components/ui/card';
import { Textarea } from '@/components/ui/textarea';
import { Bot, User } from 'lucide-react';
import { useToast } from '@/hooks/use-toast';
import { submitAnswer, APIError } from '@/services/api';

interface Message {
  id: string;
  type: 'ai' | 'candidate';
  content: string;
  timestamp: Date;
}

interface QAPair {
  question: string;
  answer: string;
}

const CandidateInterview = () => {
  const navigate = useNavigate();
  const { toast } = useToast();

  const [candidateId, setCandidateId] = useState<string | null>(null);
  const [authToken, setAuthToken] = useState<string | null>(null);
  const [interviewActive, setInterviewActive] = useState(false);
  const [currentQuestion, setCurrentQuestion] = useState('');
  const [qaTranscript, setQaTranscript] = useState<QAPair[]>([]);
  
  // UI state
  const [messages, setMessages] = useState<Message[]>([]);
  const [currentAnswer, setCurrentAnswer] = useState('');
  const [loading, setLoading] = useState(false);
  const chatEndRef = useRef<HTMLDivElement>(null);

  // Session info
  const [candidateName, setCandidateName] = useState('');
  const [jobRole, setJobRole] = useState('');

  useEffect(() => {
    // Check if user came from login (session data should be available)
    const storedCandidateId = sessionStorage.getItem('candidateId');
    const storedToken = sessionStorage.getItem('authToken');
    const storedQuestion = sessionStorage.getItem('currentQuestion');
    const storedCandidateName = sessionStorage.getItem('candidateName');
    const storedJobRole = sessionStorage.getItem('jobRole');

    if (storedCandidateId && storedToken && storedQuestion) {
      setCandidateId(storedCandidateId);
      setAuthToken(storedToken);
      setCurrentQuestion(storedQuestion);
      setInterviewActive(true);
      setCandidateName(storedCandidateName || '');
      setJobRole(storedJobRole || '');
      
      // Add the first question to messages
      addAIMessage(storedQuestion);
    } else {
      // No session data, redirect to login
      navigate('/candidate/login');
    }
  }, [navigate]);

  useEffect(() => {
    // Auto-scroll to bottom when new messages are added
    chatEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const addAIMessage = (content: string) => {
    const newMessage: Message = {
      id: Date.now().toString(),
      type: 'ai',
      content,
      timestamp: new Date()
    };
    setMessages(prev => [...prev, newMessage]);
  };

  const addCandidateMessage = (content: string) => {
    const newMessage: Message = {
      id: Date.now().toString(),
      type: 'candidate',
      content,
      timestamp: new Date()
    };
    setMessages(prev => [...prev, newMessage]);
  };

  const handleSubmitAnswer = async () => {
    if (!currentAnswer.trim() || !candidateId || !authToken) return;

    // Add candidate's response to UI
    addCandidateMessage(currentAnswer);

    const newQAPair: QAPair = {
      question: currentQuestion,
      answer: currentAnswer
    };
    setQaTranscript(prev => [...prev, newQAPair]);
    
    const answerToSubmit = currentAnswer;
    setCurrentAnswer('');
    setLoading(true);

    try {
      const response = await submitAnswer(candidateId, answerToSubmit, authToken);
      
      if (response.status === "ongoing") {
        // More questions available
        const nextQuestion = response.question!;
        setCurrentQuestion(nextQuestion);
        addAIMessage(nextQuestion);
      } else if (response.status === "completed") {
        // Interview complete
        setInterviewActive(false);
        const completionMessage = response.message || "Thank you! The interview is now complete.";
        addAIMessage(completionMessage);
        
        // Store final transcript
        if (response.final_transcript) {
          sessionStorage.setItem('finalTranscript', JSON.stringify(response.final_transcript));
        }
        
        setTimeout(() => {
          navigate('/candidate/complete');
        }, 3000);
      }
    } catch (error) {
      const errorMessage = error instanceof APIError ? error.message : 'Error submitting answer';
      toast({
        variant: "destructive",
        title: "Submission Error",
        description: errorMessage
      });
      
      setQaTranscript(prev => prev.slice(0, -1));
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = () => {
    sessionStorage.removeItem('candidateId');
    sessionStorage.removeItem('authToken');
    sessionStorage.removeItem('currentQuestion');
    sessionStorage.removeItem('candidateName');
    sessionStorage.removeItem('jobRole');
    sessionStorage.removeItem('finalTranscript');
    navigate('/candidate/login');
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSubmitAnswer();
    }
  };

  return (
    <div className="min-h-screen bg-background flex flex-col">
      <Header 
        showAuth={false} 
        showLogout={true} 
        title={jobRole ? `Interview - ${jobRole}` : "AI Interview"}
        onLogout={handleLogout} 
      />
      
      <div className="flex-1 flex flex-col">
        {/* Chat Messages Area */}
        <div className="flex-1 overflow-y-auto px-6 py-4">
          <div className="max-w-4xl mx-auto space-y-6">
            {messages.map((message) => (
              <div
                key={message.id}
                className={`flex ${message.type === 'candidate' ? 'justify-end' : 'justify-start'}`}
              >
                <div className={`flex items-start space-x-3 max-w-[80%] ${message.type === 'candidate' ? 'flex-row-reverse space-x-reverse' : ''}`}>
                  {/* Avatar */}
                  <div className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-full ${
                    message.type === 'ai' 
                      ? 'bg-secondary text-secondary-foreground' 
                      : 'bg-primary text-primary-foreground'
                  }`}>
                    {message.type === 'ai' ? (
                      <Bot className="h-5 w-5" />
                    ) : (
                      <User className="h-5 w-5" />
                    )}
                  </div>
                  
                  {/* Message Bubble */}
                  <Card className={`${
                    message.type === 'ai' 
                      ? 'bg-card border-border' 
                      : 'bg-primary text-primary-foreground border-primary'
                  } card-shadow`}>
                    <CardContent className="p-4">
                      <p className="text-sm leading-relaxed whitespace-pre-wrap">
                        {message.content}
                      </p>
                      <p className={`text-xs mt-2 ${
                        message.type === 'ai' 
                          ? 'text-muted-foreground' 
                          : 'text-primary-foreground/70'
                      }`}>
                        {message.timestamp.toLocaleTimeString()}
                      </p>
                    </CardContent>
                  </Card>
                </div>
              </div>
            ))}
            
            {loading && (
              <div className="flex justify-start">
                <div className="flex items-start space-x-3">
                  <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-secondary text-secondary-foreground">
                    <Bot className="h-5 w-5" />
                  </div>
                  <Card className="bg-card border-border card-shadow">
                    <CardContent className="p-4">
                      <div className="flex items-center space-x-2">
                        <div className="flex space-x-1">
                          <div className="w-2 h-2 bg-muted-foreground rounded-full animate-bounce"></div>
                          <div className="w-2 h-2 bg-muted-foreground rounded-full animate-bounce delay-100"></div>
                          <div className="w-2 h-2 bg-muted-foreground rounded-full animate-bounce delay-200"></div>
                        </div>
                        <span className="text-sm text-muted-foreground">AI is analyzing your response...</span>
                      </div>
                    </CardContent>
                  </Card>
                </div>
              </div>
            )}
            
            <div ref={chatEndRef} />
          </div>
        </div>

        {/* Answer Input Section */}
        <div className="border-t border-border bg-muted/30 p-6">
          <div className="max-w-4xl mx-auto">
            <div className="space-y-4">
              <div className="space-y-2">
                <label className="text-sm font-medium text-foreground">
                  Your Answer:
                </label>
                <Textarea
                  value={currentAnswer}
                  onChange={(e) => setCurrentAnswer(e.target.value)}
                  onKeyPress={handleKeyPress}
                  placeholder="Type your answer here... (Press Enter to submit, Shift+Enter for new line)"
                  rows={4}
                  disabled={loading}
                  className="resize-none"
                />
              </div>
              <div className="flex justify-end">
                <PlatformButton
                  onClick={handleSubmitAnswer}
                  disabled={!currentAnswer.trim() || loading}
                  loading={loading}
                >
                  Submit Answer
                </PlatformButton>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default CandidateInterview;