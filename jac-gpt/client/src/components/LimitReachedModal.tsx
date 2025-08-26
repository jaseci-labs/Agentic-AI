import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Link } from 'react-router-dom';
import { UserPlus, LogIn, MessageCircle } from 'lucide-react';

interface LimitReachedModalProps {
  isOpen: boolean;
  onClose: () => void;
  messageCount: number;
  maxFreeMessages: number;
}

const LimitReachedModal = ({ isOpen, onClose, messageCount, maxFreeMessages }: LimitReachedModalProps) => {
  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="sm:max-w-md bg-gray-800 border-gray-700">
        <DialogHeader>
          <DialogTitle className="text-white flex items-center gap-2">
            <MessageCircle className="h-5 w-5 text-orange-500" />
            Message Limit Reached
          </DialogTitle>
          <DialogDescription className="text-gray-300">
            You've used all {maxFreeMessages} free messages. Sign up to continue chatting with unlimited access!
          </DialogDescription>
        </DialogHeader>
        
        <div className="space-y-4 pt-4">
          <div className="bg-gray-700/50 p-4 rounded-lg">
            <h4 className="text-sm font-medium text-white mb-2">With a free account, you get:</h4>
            <ul className="text-sm text-gray-300 space-y-1">
              <li>• Unlimited conversations</li>
              <li>• Chat history saved</li>
              <li>• Advanced Jac programming assistance</li>
              <li>• Code generation and debugging</li>
            </ul>
          </div>
          
          <div className="flex flex-col gap-2">
            <Link to="/register" onClick={onClose}>
              <Button className="w-full bg-orange-600 hover:bg-orange-700 text-white">
                <UserPlus className="w-4 h-4 mr-2" />
                Sign Up for Free
              </Button>
            </Link>
            <Link to="/login" onClick={onClose}>
              <Button variant="outline" className="w-full text-orange-500 border-orange-500 hover:bg-orange-500 hover:text-white">
                <LogIn className="w-4 h-4 mr-2" />
                Already have an account? Sign In
              </Button>
            </Link>
          </div>
          
          <Button 
            variant="ghost" 
            onClick={onClose}
            className="w-full text-gray-400 hover:text-white"
          >
            Continue browsing
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
};

export default LimitReachedModal;
