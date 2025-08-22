import { useState, useEffect } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { ScrollArea } from '@/components/ui/scroll-area';
import { Separator } from '@/components/ui/separator';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Loader2, Users, MessageSquare, Calendar, Eye, EyeOff } from 'lucide-react';

interface User {
  email: string;
  name: string;
  role: string;
  created_at: string;
  last_login?: string;
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

const AdminDashboard = () => {
  const { user } = useAuth();
  const [users, setUsers] = useState<User[]>([]);
  const [sessions, setSessions] = useState<Session[]>([]);
  const [selectedSession, setSelectedSession] = useState<SessionDetail | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [activeTab, setActiveTab] = useState<'overview' | 'users' | 'sessions'>('overview');

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

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <div className="container mx-auto p-6">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white">Admin Dashboard</h1>
          <p className="text-gray-600 dark:text-gray-300 mt-2">
            Welcome, {user.name || user.email}. Monitor all user activity and chat sessions.
          </p>
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
        </div>

        {/* Overview Tab */}
        {activeTab === 'overview' && (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Total Users</CardTitle>
                <Users className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{users.length}</div>
                <p className="text-xs text-muted-foreground">
                  {users.filter(u => u.role === 'admin').length} admin(s), {users.filter(u => u.role === 'user').length} user(s)
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Total Sessions</CardTitle>
                <MessageSquare className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{sessions.length}</div>
                <p className="text-xs text-muted-foreground">
                  {sessions.filter(s => s.status === 'active').length} active sessions
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Total Messages</CardTitle>
                <Calendar className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">
                  {sessions.reduce((total, session) => total + session.message_count, 0)}
                </div>
                <p className="text-xs text-muted-foreground">
                  Across all sessions
                </p>
              </CardContent>
            </Card>
          </div>
        )}

        {/* Users Tab */}
        {activeTab === 'users' && (
          <Card>
            <CardHeader>
              <CardTitle>Users</CardTitle>
              <CardDescription>Manage and monitor all registered users</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {users.map((user, index) => (
                  <div key={index} className="flex items-center justify-between p-4 border rounded-lg">
                    <div className="flex-1">
                      <div className="flex items-center space-x-2">
                        <span className="font-medium">{user.email}</span>
                        <Badge variant={user.role === 'admin' ? 'default' : 'secondary'}>
                          {user.role}
                        </Badge>
                      </div>
                      {user.name && (
                        <p className="text-sm text-gray-500">{user.name}</p>
                      )}
                      <div className="text-xs text-gray-400 mt-1">
                        <span>Created: {formatDate(user.created_at)}</span>
                        {user.last_login && (
                          <span className="ml-4">Last login: {formatDate(user.last_login)}</span>
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
            <Card>
              <CardHeader>
                <CardTitle>Chat Sessions</CardTitle>
                <CardDescription>Click on a session to view conversation details</CardDescription>
              </CardHeader>
              <CardContent>
                <ScrollArea className="h-96">
                  <div className="space-y-2">
                    {sessions.map((session, index) => (
                      <div
                        key={index}
                        className={`p-3 border rounded-lg cursor-pointer transition-colors ${
                          selectedSession?.session_id === session.session_id
                            ? 'bg-blue-50 border-blue-200 dark:bg-blue-900/20'
                            : 'hover:bg-gray-50 dark:hover:bg-gray-800'
                        }`}
                        onClick={() => fetchSessionMessages(session.session_id)}
                      >
                        <div className="flex items-center justify-between">
                          <div className="flex items-center space-x-2">
                            <span className="text-sm font-medium">
                              {session.session_id.substring(0, 12)}...
                            </span>
                            <Badge variant={session.status === 'active' ? 'default' : 'secondary'}>
                              {session.status}
                            </Badge>
                            {session.user_email && (
                              <Badge variant="outline" className="text-xs">
                                {session.user_email}
                              </Badge>
                            )}
                          </div>
                          <span className="text-xs text-gray-500">
                            {session.message_count} messages
                          </span>
                        </div>
                        {session.first_message && (
                          <p className="text-xs text-gray-400 mt-1">
                            "{truncateText(session.first_message, 60)}"
                          </p>
                        )}
                        <div className="text-xs text-gray-400 mt-1">
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
            <Card>
              <CardHeader>
                <CardTitle>Session Details</CardTitle>
                <CardDescription>
                  {selectedSession 
                    ? `Viewing conversation: ${selectedSession.session_id.substring(0, 12)}...`
                    : 'Select a session to view conversation details'
                  }
                </CardDescription>
              </CardHeader>
              <CardContent>
                {loading ? (
                  <div className="flex items-center justify-center h-64">
                    <Loader2 className="h-6 w-6 animate-spin" />
                  </div>
                ) : selectedSession ? (
                  <ScrollArea className="h-96">
                    <div className="space-y-4">
                      {selectedSession.messages.map((message, index) => (
                        <div key={index} className={`p-3 rounded-lg ${
                          message.role === 'user' 
                            ? 'bg-blue-50 dark:bg-blue-900/20 ml-4' 
                            : 'bg-gray-50 dark:bg-gray-800 mr-4'
                        }`}>
                          <div className="flex items-center justify-between mb-2">
                            <Badge variant={message.role === 'user' ? 'default' : 'secondary'}>
                              {message.role}
                            </Badge>
                            <span className="text-xs text-gray-500">
                              {formatDate(message.timestamp)}
                            </span>
                          </div>
                          <p className="text-sm whitespace-pre-wrap">{message.content}</p>
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
      </div>
    </div>
  );
};

export default AdminDashboard;
