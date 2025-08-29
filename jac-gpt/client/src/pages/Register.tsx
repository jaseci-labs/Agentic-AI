import { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Loader2, MapPin } from 'lucide-react';

interface LocationData {
  latitude: number;
  longitude: number;
  city?: string;
  country?: string;
  ip?: string;
}

const Register = () => {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    confirmPassword: '',
  });
  const [error, setError] = useState('');
  const [location, setLocation] = useState<LocationData | null>(null);
  const [locationError, setLocationError] = useState('');
  const [gettingLocation, setGettingLocation] = useState(false);
  const { register, isLoading } = useAuth();
  const navigate = useNavigate();

  // Get user's location on component mount
  useEffect(() => {
    getUserLocation();
  }, []);

  const getUserLocation = async () => {
    setGettingLocation(true);
    try {
      // Try to get precise location from browser first
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
          async (position) => {
            const locationData: LocationData = {
              latitude: position.coords.latitude,
              longitude: position.coords.longitude,
            };
            
            // Get city/country from coordinates using reverse geocoding
            try {
              const response = await fetch(
                `https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=${locationData.latitude}&longitude=${locationData.longitude}&localityLanguage=en`
              );
              const geoData = await response.json();
              locationData.city = geoData.city || geoData.locality;
              locationData.country = geoData.countryName;
            } catch (geoError) {
              console.warn('Could not get city/country from coordinates:', geoError);
            }
            
            setLocation(locationData);
            setGettingLocation(false);
          },
          async (geoError) => {
            console.warn('Geolocation failed, falling back to IP location:', geoError);
            // Fallback to IP-based location
            await getLocationFromIP();
          }
        );
      } else {
        // Fallback to IP-based location
        await getLocationFromIP();
      }
    } catch (err) {
      console.error('Location detection failed:', err);
      setLocationError('Could not detect location');
      setGettingLocation(false);
    }
  };

  const getLocationFromIP = async () => {
    try {
      const response = await fetch('https://ipapi.co/json/');
      const data = await response.json();
      
      setLocation({
        latitude: data.latitude,
        longitude: data.longitude,
        city: data.city,
        country: data.country_name,
        ip: data.ip
      });
    } catch (ipError) {
      console.error('IP location failed:', ipError);
      setLocationError('Could not detect location');
    }
    setGettingLocation(false);
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData(prev => ({
      ...prev,
      [e.target.name]: e.target.value
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    // Validate passwords match
    if (formData.password !== formData.confirmPassword) {
      setError('Passwords do not match');
      return;
    }

    // Validate password strength
    if (formData.password.length < 6) {
      setError('Password must be at least 6 characters long');
      return;
    }

    try {
      // Include location data in registration
      await register(formData.email, formData.password, formData.name, location);
      navigate('/', { replace: true });
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred during registration');
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-900 px-4">
      <Card className="w-full max-w-md bg-gray-800 border-gray-700">
        <CardHeader className="space-y-1">
          <div className="flex justify-center mb-4">
            <img src="/logo.png" alt="JAC GPT" className="h-12 w-12" />
          </div>
          <CardTitle className="text-2xl text-center text-white">Create an account</CardTitle>
          <CardDescription className="text-center text-gray-400">
            Enter your details to get started
          </CardDescription>
        </CardHeader>
        <form onSubmit={handleSubmit}>
          <CardContent className="space-y-4">
            {error && (
              <Alert variant="destructive">
                <AlertDescription>{error}</AlertDescription>
              </Alert>
            )}
            <div className="space-y-2">
              <Label htmlFor="name" className="text-gray-300">Full Name</Label>
              <Input
                id="name"
                name="name"
                type="text"
                placeholder="Enter your full name"
                value={formData.name}
                onChange={handleChange}
                required
                disabled={isLoading}
                className="bg-gray-700 border-gray-600 text-white placeholder-gray-400"
              />
            </div>
            
            {/* Location Information */}
            <div className="space-y-2">
              <div className="flex items-center space-x-2">
                <MapPin className="h-4 w-4 text-orange-500" />
                <Label className="text-gray-300">Location</Label>
              </div>
              {gettingLocation ? (
                <div className="flex items-center space-x-2 text-sm text-gray-400">
                  <Loader2 className="h-3 w-3 animate-spin" />
                  <span>Detecting location...</span>
                </div>
              ) : location ? (
                <div className="text-sm text-gray-400 bg-gray-700 p-2 rounded border border-gray-600">
                  <div className="flex items-center space-x-1">
                    <span>📍</span>
                    <span>{location.city && location.country ? `${location.city}, ${location.country}` : 'Location detected'}</span>
                  </div>
                  <div className="text-xs text-gray-500 mt-1">
                    This helps us provide location-relevant features
                  </div>
                </div>
              ) : locationError ? (
                <div className="text-sm text-gray-500 bg-gray-700 p-2 rounded border border-gray-600">
                  <span>⚠️ {locationError}</span>
                </div>
              ) : null}
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="email" className="text-gray-300">Email</Label>
              <Input
                id="email"
                name="email"
                type="email"
                placeholder="Enter your email"
                value={formData.email}
                onChange={handleChange}
                required
                disabled={isLoading}
                className="bg-gray-700 border-gray-600 text-white placeholder-gray-400"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="password" className="text-gray-300">Password</Label>
              <Input
                id="password"
                name="password"
                type="password"
                placeholder="Create a password"
                value={formData.password}
                onChange={handleChange}
                required
                disabled={isLoading}
                className="bg-gray-700 border-gray-600 text-white placeholder-gray-400"
              />
              <p className="text-xs text-gray-400">
                Password must be at least 6 characters long
              </p>
            </div>
            <div className="space-y-2">
              <Label htmlFor="confirmPassword" className="text-gray-300">Confirm Password</Label>
              <Input
                id="confirmPassword"
                name="confirmPassword"
                type="password"
                placeholder="Confirm your password"
                value={formData.confirmPassword}
                onChange={handleChange}
                required
                disabled={isLoading}
                className="bg-gray-700 border-gray-600 text-white placeholder-gray-400"
              />
            </div>
          </CardContent>
          <CardFooter className="flex flex-col space-y-4">
            <Button 
              type="submit" 
              className="w-full bg-orange-600 hover:bg-orange-700 text-white" 
              disabled={isLoading}
            >
              {isLoading ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Creating account...
                </>
              ) : (
                'Create account'
              )}
            </Button>
            <div className="text-center text-sm">
              <span className="text-gray-400">Already have an account? </span>
              <Link 
                to="/login" 
                className="text-orange-500 hover:text-orange-400 hover:underline font-medium"
              >
                Sign in
              </Link>
            </div>
          </CardFooter>
        </form>
      </Card>
    </div>
  );
};

export default Register;
