import { useAuth } from '@/contexts/AuthContext';
import JacChatbot from '@/components/JacChatbot';
import AdminDashboard from '@/components/AdminDashboard';

const Dashboard = () => {
  const { user } = useAuth();

  // Show admin dashboard for admin users, regular chat for others
  if (user?.role === 'admin') {
    return <AdminDashboard />;
  }

  return <JacChatbot />;
};

export default Dashboard;
