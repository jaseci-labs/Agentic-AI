import { useState, useEffect } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { ScrollArea } from '@/components/ui/scroll-area';
import { Separator } from '@/components/ui/separator';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Input } from '@/components/ui/input';
import { Loader2, Users, MessageSquare, Calendar, Eye, EyeOff, LogOut, HelpCircle } from 'lucide-react';

interface User {
  email: string;
  name: string;
  role: string;
  created_at: string;
  last_login?: string;
  location?: {
    city?: string;
    region?: string;
    country?: string;
    country_code?: string;
    latitude?: number;
    longitude?: number;
    source?: string;
  };
  location_updated_at?: string;
}

interface Session {
  session_id: string;
  user_email?: string;
  created_at: string;
  updated_at: string;
  status: string;
  message_count: number;
  first_message?: string;
  first_message_time?: string;
}

interface Message {
  role: string;
  content: string;
  timestamp: string;
}

interface SessionDetail {
  session_id: string;
  messages: Message[];
  stats: any;
  total_messages: number;
}

interface UserQuestion {
  question: string;
  user_email?: string;
  user_name?: string;
  session_id: string;
  timestamp: string;
}

const AdminDashboard = () => {
  const { user, logout } = useAuth();
  const [users, setUsers] = useState<User[]>([]);
  const [sessions, setSessions] = useState<Session[]>([]);
  const [userQuestions, setUserQuestions] = useState<UserQuestion[]>([]);
  const [questionSearchTerm, setQuestionSearchTerm] = useState('');
  const [selectedSession, setSelectedSession] = useState<SessionDetail | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [activeTab, setActiveTab] = useState<'overview' | 'users' | 'sessions' | 'questions'>('overview');

  const fetchUsers = async () => {
    try {
      const response = await fetch(`${import.meta.env.VITE_API_URL || 'http://localhost:8000'}/walker/get_all_users`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ requester_email: user?.email }),
      });

      const data = await response.json();
      if (data.reports && data.reports[0]) {
        const result = data.reports[0];
        if (result.error) {
          setError(result.error);
        } else {
          setUsers(result.users || []);
        }
      }
    } catch (error) {
      console.error('Error fetching users:', error);
      setError('Failed to fetch users');
    }
  };

  const fetchSessions = async () => {
    try {
      const response = await fetch(`${import.meta.env.VITE_API_URL || 'http://localhost:8000'}/walker/get_all_sessions_admin`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ requester_email: user?.email }),
      });

      const data = await response.json();
      if (data.reports && data.reports[0]) {
        const result = data.reports[0];
        if (result.error) {
          setError(result.error);
        } else {
          setSessions(result.sessions || []);
        }
      }
    } catch (error) {
      console.error('Error fetching sessions:', error);
      setError('Failed to fetch sessions');
    }
  };

  const fetchSessionMessages = async (sessionId: string) => {
    try {
      setLoading(true);
      const response = await fetch(`${import.meta.env.VITE_API_URL || 'http://localhost:8000'}/walker/get_session_messages_admin`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ 
          session_id: sessionId,
          requester_email: user?.email 
        }),
      });

      const data = await response.json();
      if (data.reports && data.reports[0]) {
        const result = data.reports[0];
        if (result.error) {
          setError(result.error);
        } else {
          setSelectedSession(result);
        }
      }
    } catch (error) {
      console.error('Error fetching session messages:', error);
      setError('Failed to fetch session messages');
    } finally {
      setLoading(false);
    }
  };

  const fetchUserQuestions = async () => {
    try {
      const questions: UserQuestion[] = [];
      
      // First get all sessions with their messages
      for (const session of sessions) {
        try {
          const response = await fetch(`${import.meta.env.VITE_API_URL || 'http://localhost:8000'}/walker/get_session_messages_admin`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({ 
              session_id: session.session_id,
              requester_email: user?.email 
            }),
          });

          const data = await response.json();
          if (data.reports && data.reports[0] && data.reports[0].messages) {
            const sessionMessages = data.reports[0].messages;
            
            // Filter only user messages (questions)
            const userMessages = sessionMessages.filter((msg: Message) => msg.role === 'user');
            
            // Find user name from users array
            const sessionUser = users.find(u => u.email === session.user_email);
            
            userMessages.forEach((msg: Message) => {
              questions.push({
                question: msg.content,
                user_email: session.user_email,
                user_name: sessionUser?.name,
                session_id: session.session_id,
                timestamp: msg.timestamp
              });
            });
          }
        } catch (err) {
          console.error(`Error fetching messages for session ${session.session_id}:`, err);
        }
      }
      
      // Sort questions by timestamp (newest first)
      questions.sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime());
      
      setUserQuestions(questions);
    } catch (error) {
      console.error('Error fetching user questions:', error);
      setError('Failed to fetch user questions');
    }
  };

  useEffect(() => {
    const loadData = async () => {
      setLoading(true);
      await Promise.all([fetchUsers(), fetchSessions()]);
      setLoading(false);
    };

    if (user?.role === 'admin') {
      loadData();
    }
  }, [user]);

  // Separate useEffect to fetch user questions after sessions and users are loaded
  useEffect(() => {
    if (sessions.length > 0 && users.length > 0 && user?.role === 'admin') {
      fetchUserQuestions();
    }
  }, [sessions, users]);

  if (!user || user.role !== 'admin') {
    return (
      <Alert>
        <AlertDescription>
          Access denied. Admin privileges required.
        </AlertDescription>
      </Alert>
    );
  }

  if (loading && !users.length && !sessions.length) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="flex flex-col items-center space-y-4">
          <Loader2 className="h-8 w-8 animate-spin" />
          <p className="text-muted-foreground">Loading admin dashboard...</p>
        </div>
      </div>
    );
  }

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleString();
  };

  const truncateText = (text: string, maxLength: number = 100) => {
    return text.length > maxLength ? text.substring(0, maxLength) + '...' : text;
  };

  const getFilteredQuestions = () => {
    return userQuestions.filter(question => 
      question.question.toLowerCase().includes(questionSearchTerm.toLowerCase()) ||
      question.user_email?.toLowerCase().includes(questionSearchTerm.toLowerCase()) ||
      question.user_name?.toLowerCase().includes(questionSearchTerm.toLowerCase())
    );
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-white">
      <div className="container mx-auto p-6">
        <div className="mb-8 flex justify-between items-start">
          <div>
            <h1 className="text-3xl font-bold text-gray-900 mb-2">Admin Dashboard</h1>
            <p className="text-gray-600">
              Welcome, {user.name || user.email}. Monitor all user activity and chat sessions.
            </p>
          </div>
          <Button
            variant="outline"
            onClick={logout}
            className="flex items-center space-x-2 border-gray-300 hover:bg-gray-50"
          >
            <LogOut className="w-4 h-4" />
            <span>Logout</span>
          </Button>
        </div>

        {error && (
          <Alert className="mb-6">
            <AlertDescription>{error}</AlertDescription>
          </Alert>
        )}

        {/* Navigation Tabs */}
        <div className="flex space-x-4 mb-6">
          <Button
            variant={activeTab === 'overview' ? 'default' : 'outline'}
            onClick={() => setActiveTab('overview')}
          >
            Overview
          </Button>
          <Button
            variant={activeTab === 'users' ? 'default' : 'outline'}
            onClick={() => setActiveTab('users')}
          >
            <Users className="w-4 h-4 mr-2" />
            Users ({users.length})
          </Button>
          <Button
            variant={activeTab === 'sessions' ? 'default' : 'outline'}
            onClick={() => setActiveTab('sessions')}
          >
            <MessageSquare className="w-4 h-4 mr-2" />
            Sessions ({sessions.length})
          </Button>
          <Button
            variant={activeTab === 'questions' ? 'default' : 'outline'}
            onClick={() => setActiveTab('questions')}
          >
            <HelpCircle className="w-4 h-4 mr-2" />
            Questions ({userQuestions.length})
          </Button>
        </div>

        {/* Overview Tab */}
        {activeTab === 'overview' && (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
            <Card className="bg-white border border-gray-200 shadow-lg hover:shadow-xl transition-shadow">
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2 bg-gradient-to-r from-orange-50 to-orange-100 rounded-t-lg">
                <CardTitle className="text-sm font-medium text-gray-900">Total Users</CardTitle>
                <Users className="h-5 w-5 text-orange-500" />
              </CardHeader>
              <CardContent className="p-4">
                <div className="text-3xl font-bold text-gray-900">{users.length}</div>
                <p className="text-sm text-gray-600 mt-1">
                  {users.filter(u => u.role === 'admin').length} admin(s), {users.filter(u => u.role === 'user').length} user(s)
                </p>
              </CardContent>
            </Card>

            <Card className="bg-white border border-gray-200 shadow-lg hover:shadow-xl transition-shadow">
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2 bg-gradient-to-r from-blue-50 to-blue-100 rounded-t-lg">
                <CardTitle className="text-sm font-medium text-gray-900">Total Sessions</CardTitle>
                <MessageSquare className="h-5 w-5 text-blue-500" />
              </CardHeader>
              <CardContent className="p-4">
                <div className="text-3xl font-bold text-gray-900">{sessions.length}</div>
                <p className="text-sm text-gray-600 mt-1">
                  {sessions.filter(s => s.status === 'active').length} active sessions
                </p>
              </CardContent>
            </Card>

            <Card className="bg-white border border-gray-200 shadow-lg hover:shadow-xl transition-shadow">
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2 bg-gradient-to-r from-green-50 to-green-100 rounded-t-lg">
                <CardTitle className="text-sm font-medium text-gray-900">Total Messages</CardTitle>
                <Calendar className="h-5 w-5 text-green-500" />
              </CardHeader>
              <CardContent className="p-4">
                <div className="text-3xl font-bold text-gray-900">
                  {sessions.reduce((total, session) => total + session.message_count, 0)}
                </div>
                <p className="text-sm text-gray-600 mt-1">
                  Across all sessions
                </p>
              </CardContent>
            </Card>
          </div>
        )}

        {/* Users Tab */}
        {activeTab === 'users' && (
          <Card className="bg-white border border-gray-200 shadow-sm">
            <CardHeader className="bg-gray-50 border-b border-gray-200">
              <CardTitle className="text-gray-900">Users</CardTitle>
              <CardDescription className="text-gray-600">Manage and monitor all registered users</CardDescription>
            </CardHeader>
            <CardContent className="p-4">
              <div className="space-y-4">
                {users.map((user, index) => (
                  <div key={index} className="flex items-center justify-between p-4 bg-white border border-gray-200 rounded-lg shadow-sm hover:shadow-md transition-shadow">
                    <div className="flex-1">
                      <div className="flex items-center space-x-2">
                        <span className="font-medium text-gray-900">{user.email}</span>
                        <Badge 
                          variant={user.role === 'admin' ? 'default' : 'secondary'}
                          className={user.role === 'admin' ? 'bg-orange-500 hover:bg-orange-600' : ''}
                        >
                          {user.role}
                        </Badge>
                      </div>
                      {user.name && (
                        <p className="text-sm text-gray-600">{user.name}</p>
                      )}
                      <div className="text-xs text-gray-500 mt-1">
                        <span>Created: {formatDate(user.created_at)}</span>
                        {user.last_login && (
                          <span className="ml-4">Last login: {formatDate(user.last_login)}</span>
                        )}
                        {user.location && (
                          <div className="mt-1">
                            <span className="text-blue-600">📍 {user.location.city ? `${user.location.city}, ` : ''}{user.location.country || 'Unknown location'}</span>
                            {user.location_updated_at && (
                              <span className="ml-2 text-gray-400">({formatDate(user.location_updated_at)})</span>
                            )}
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        )}

        {/* Sessions Tab */}
        {activeTab === 'sessions' && (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <Card className="bg-white border border-gray-200 shadow-sm">
              <CardHeader className="bg-gray-50 border-b border-gray-200">
                <CardTitle className="text-gray-900">Chat Sessions</CardTitle>
                <CardDescription className="text-gray-600">Click on a session to view conversation details</CardDescription>
              </CardHeader>
              <CardContent className="p-4">
                <ScrollArea className="h-96">
                  <div className="space-y-2">
                    {sessions.map((session, index) => (
                      <div
                        key={index}
                        className={`p-3 border rounded-lg cursor-pointer transition-colors ${
                          selectedSession?.session_id === session.session_id
                            ? 'bg-orange-50 border-orange-200'
                            : 'bg-white hover:bg-gray-50 border-gray-200'
                        }`}
                        onClick={() => fetchSessionMessages(session.session_id)}
                      >
                        <div className="flex items-center justify-between">
                          <div className="flex items-center space-x-2">
                            <span className="text-sm font-medium text-gray-900">
                              {session.session_id.substring(0, 12)}...
                            </span>
                            <Badge 
                              variant={session.status === 'active' ? 'default' : 'secondary'}
                              className={session.status === 'active' ? 'bg-orange-500 hover:bg-orange-600' : ''}
                            >
                              {session.status}
                            </Badge>
                            {session.user_email && (
                              <Badge variant="outline" className="text-xs border-gray-300 text-gray-700">
                                {session.user_email}
                              </Badge>
                            )}
                          </div>
                          <span className="text-xs text-gray-600">
                            {session.message_count} messages
                          </span>
                        </div>
                        {session.first_message && (
                          <p className="text-xs text-gray-600 mt-1">
                            "{truncateText(session.first_message, 60)}"
                          </p>
                        )}
                        <div className="text-xs text-gray-500 mt-1">
                          <span>Created: {formatDate(session.created_at)}</span>
                          <span className="ml-2">Updated: {formatDate(session.updated_at)}</span>
                        </div>
                      </div>
                    ))}
                  </div>
                </ScrollArea>
              </CardContent>
            </Card>

            {/* Session Details */}
            <Card className="bg-white border border-gray-200 shadow-sm">
              <CardHeader className="bg-gray-50 border-b border-gray-200">
                <CardTitle className="text-gray-900">Session Details</CardTitle>
                <CardDescription className="text-gray-600">
                  {selectedSession 
                    ? `Viewing conversation: ${selectedSession.session_id.substring(0, 12)}...`
                    : 'Select a session to view conversation details'
                  }
                </CardDescription>
              </CardHeader>
              <CardContent className="p-4">
                {loading ? (
                  <div className="flex items-center justify-center h-64">
                    <Loader2 className="h-6 w-6 animate-spin" />
                  </div>
                ) : selectedSession ? (
                  <ScrollArea className="h-96">
                    <div className="space-y-4">
                      {selectedSession.messages.map((message, index) => (
                        <div key={index} className={`p-4 rounded-lg border ${
                          message.role === 'user' 
                            ? 'bg-orange-50 border-orange-200 ml-4' 
                            : 'bg-white border-gray-200 mr-4'
                        }`}>
                          <div className="flex items-center justify-between mb-2">
                            <Badge 
                              variant={message.role === 'user' ? 'default' : 'secondary'}
                              className={message.role === 'user' ? 'bg-orange-500 hover:bg-orange-600' : ''}
                            >
                              {message.role}
                            </Badge>
                            <span className="text-xs text-gray-600">
                              {formatDate(message.timestamp)}
                            </span>
                          </div>
                          <p className="text-sm whitespace-pre-wrap text-gray-900">{message.content}</p>
                        </div>
                      ))}
                    </div>
                  </ScrollArea>
                ) : (
                  <div className="flex items-center justify-center h-64 text-gray-500">
                    <div className="text-center">
                      <Eye className="h-12 w-12 mx-auto mb-4 opacity-50" />
                      <p>Select a session to view the conversation</p>
                    </div>
                  </div>
                )}
              </CardContent>
            </Card>
          </div>
        )}

        {/* Questions Tab */}
        {activeTab === 'questions' && (
          <Card className="bg-white border border-gray-200 shadow-sm">
            <CardHeader className="bg-gray-50 border-b border-gray-200">
              <CardTitle className="text-gray-900">User Questions</CardTitle>
              <CardDescription className="text-gray-600">
                All questions asked by users across all chat sessions
                {questionSearchTerm && (
                  <span className="ml-2 text-orange-600">
                    • {getFilteredQuestions().length} of {userQuestions.length} questions shown
                  </span>
                )}
              </CardDescription>
            </CardHeader>
            <CardContent className="p-4">
              <div className="mb-4">
                <Input
                  placeholder="Search questions..."
                  value={questionSearchTerm}
                  onChange={(e) => setQuestionSearchTerm(e.target.value)}
                  className="max-w-md bg-gray-50 border-gray-200 text-gray-700 placeholder:text-gray-500 focus:bg-white focus:border-orange-300 focus:ring-orange-200"
                />
              </div>
              <ScrollArea className="h-96">
                <div className="space-y-4">
                  {userQuestions.length > 0 ? (
                    getFilteredQuestions().length > 0 ? (
                      getFilteredQuestions().map((question, index) => (
                        <div key={index} className="p-4 bg-white border border-gray-200 rounded-lg shadow-sm hover:shadow-md transition-shadow">
                          <div className="flex items-start justify-between mb-3">
                            <div className="flex items-center space-x-2">
                              {question.user_name && (
                                <Badge variant="outline" className="border-blue-300 text-blue-700 bg-blue-50">
                                  {question.user_name}
                                </Badge>
                              )}
                              {question.user_email && (
                                <Badge variant="outline" className="border-gray-300 text-gray-700">
                                  {question.user_email}
                                </Badge>
                              )}
                              <Badge variant="outline" className="border-orange-300 text-orange-700 bg-orange-50">
                                {question.session_id.substring(0, 8)}...
                              </Badge>
                            </div>
                            <span className="text-xs text-gray-500">
                              {formatDate(question.timestamp)}
                            </span>
                          </div>
                          <div className="bg-gray-50 p-3 rounded-lg border-l-4 border-orange-400">
                            <p className="text-sm text-gray-900 whitespace-pre-wrap">
                              {question.question}
                            </p>
                          </div>
                        </div>
                      ))
                    ) : (
                      <div className="flex items-center justify-center h-64 text-gray-500">
                        <div className="text-center">
                          <HelpCircle className="h-12 w-12 mx-auto mb-4 opacity-50" />
                          <p>No questions match your search</p>
                          <p className="text-sm mt-2">Try different search terms</p>
                        </div>
                      </div>
                    )
                  ) : (
                    <div className="flex items-center justify-center h-64 text-gray-500">
                      <div className="text-center">
                        <HelpCircle className="h-12 w-12 mx-auto mb-4 opacity-50" />
                        <p>No user questions found</p>
                        <p className="text-sm mt-2">Questions will appear here once users start chatting</p>
                      </div>
                    </div>
                  )}
                </div>
              </ScrollArea>
            </CardContent>
          </Card>
        )}
      </div>
    </div>
  );
};

export default AdminDashboard;
