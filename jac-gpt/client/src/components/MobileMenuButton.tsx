import { Menu } from 'lucide-react';
import { Button } from '@/components/ui/button';

interface MobileMenuButtonProps {
  onClick: () => void;
}

const MobileMenuButton = ({ onClick }: MobileMenuButtonProps) => {
  return (
    <Button
      variant="ghost"
      size="sm"
      onClick={onClick}
      className="lg:hidden fixed top-4 left-4 z-30 bg-gray-800/80 backdrop-blur-sm text-white hover:bg-gray-700 border border-gray-600"
    >
      <Menu className="w-5 h-5" />
    </Button>
  );
};

export default MobileMenuButton;
