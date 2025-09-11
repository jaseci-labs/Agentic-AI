import { useState, useEffect, useRef } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import { Camera, Users, Heart, Edit, Save, Loader2, Upload } from "lucide-react";
import { AuthApi, ProfileData, UpdateProfileRequest } from "@/lib/api";
import { toast } from "@/hooks/use-toast";

const ProfileSection = ({ token }: { token: string; user: any }) => {
  const [profileData, setProfileData] = useState<ProfileData | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [showEditDialog, setShowEditDialog] = useState(false);
  const [editForm, setEditForm] = useState({
    first_name: "",
    last_name: "",
    profile_picture_url: ""
  });
  const [isSaving, setIsSaving] = useState(false);
  const [isUploadingImage, setIsUploadingImage] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const fetchProfile = async () => {
    try {
      setIsLoading(true);
      const profile = await AuthApi.getProfile(token);
      setProfileData(profile);
      setEditForm({
        first_name: profile.first_name || "",
        last_name: profile.last_name || "",
        profile_picture_url: profile.profile_picture_url || ""
      });
    } catch (error) {
      console.error('Failed to fetch profile:', error);
      toast({
        title: "Error",
        description: "Failed to load profile data.",
        variant: "destructive",
      });
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    if (token) {
      fetchProfile();
    }
  }, [token]);

  const handleEditProfile = () => {
    setShowEditDialog(true);
  };

  const handleSaveProfile = async () => {
    setIsSaving(true);
    try {
      const response = await AuthApi.updateProfile(token, editForm);
      setProfileData(response.profile);
      setShowEditDialog(false);
      
      toast({
        title: "Profile updated!",
        description: response.message,
      });
    } catch (error) {
      console.error('Failed to update profile:', error);
      toast({
        title: "Error",
        description: "Failed to update profile. Please try again.",
        variant: "destructive",
      });
    } finally {
      setIsSaving(false);
    }
  };

  const handleInputChange = (field: keyof UpdateProfileRequest, value: string) => {
    setEditForm(prev => ({
      ...prev,
      [field]: value
    }));
  };

  const handleImageUpload = async (file: File) => {
    setIsUploadingImage(true);
    try {
      // Get presigned URL
      const presignedData = await AuthApi.generatePresignedUrl(token);
      
      // Upload to S3 using XMLHttpRequest
      const xhr = new XMLHttpRequest();
      xhr.open('PUT', presignedData.upload_url);
      xhr.setRequestHeader('Content-Type', file.type);
      
      xhr.onload = () => {
        if (xhr.status === 200) {
          // Update the form with the new image URL
          setEditForm(prev => ({
            ...prev,
            profile_picture_url: presignedData.public_url
          }));
          
          toast({
            title: "Image uploaded!",
            description: "Profile picture has been uploaded successfully.",
          });
        } else {
          throw new Error(`Upload failed with status: ${xhr.status}`);
        }
        setIsUploadingImage(false);
      };
      
      xhr.onerror = () => {
        console.error('Upload error:', xhr.statusText);
        toast({
          title: "Upload failed",
          description: "There was an error uploading your image. Please try again.",
          variant: "destructive",
        });
        setIsUploadingImage(false);
      };
      
      xhr.send(file);
      
    } catch (error) {
      console.error('Upload error:', error);
      toast({
        title: "Upload failed",
        description: "There was an error uploading your image. Please try again.",
        variant: "destructive",
      });
      setIsUploadingImage(false);
    }
  };

  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      if (file.type.startsWith('image/')) {
        handleImageUpload(file);
      } else {
        toast({
          title: "Invalid file type",
          description: "Please select an image file (PNG, JPG, etc.)",
          variant: "destructive",
        });
      }
    }
  };

  const triggerFileSelect = () => {
    fileInputRef.current?.click();
  };

  const getDisplayName = () => {
    if (!profileData) return "Loading...";
    if (profileData.first_name || profileData.last_name) {
      return `${profileData.first_name || ''} ${profileData.last_name || ''}`.trim();
    }
    return profileData.email.split('@')[0];
  };

  const getInitials = () => {
    if (!profileData) return "L";
    if (profileData.first_name || profileData.last_name) {
      const firstInitial = profileData.first_name?.charAt(0) || "";
      const lastInitial = profileData.last_name?.charAt(0) || "";
      return `${firstInitial}${lastInitial}`.toUpperCase() || "U";
    }
    return profileData.email.charAt(0).toUpperCase();
  };

  if (isLoading) {
    return (
      <div className="space-y-6">
        <Card className="shadow-soft">
          <CardContent className="p-6">
            <div className="flex items-center justify-center py-8">
              <Loader2 className="w-8 h-8 animate-spin text-primary" />
            </div>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Profile Header Card */}
      <Card className="shadow-soft">
        <CardContent className="p-6">
          <div className="flex flex-col sm:flex-row items-center sm:items-start space-y-4 sm:space-y-0 sm:space-x-6">
            {/* Avatar */}
            <div className="relative">
              <Avatar className="w-24 h-24 border-4 border-primary-soft shadow-medium">
                {profileData?.profile_picture_url ? (
                  <AvatarImage src={profileData.profile_picture_url} />
                ) : null}
                <AvatarFallback className="bg-gradient-hero text-white text-2xl">
                  {getInitials()}
                </AvatarFallback>
              </Avatar>
            </div>

            {/* Profile Info */}
            <div className="flex-1 text-center sm:text-left">
              <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between mb-4">
                <div>
                  <h1 className="text-2xl font-bold mb-1">{getDisplayName()}</h1>
                  <p className="text-muted-foreground">{profileData?.email}</p>
                </div>
                <Button variant="outline" size="sm" className="mt-2 sm:mt-0" onClick={handleEditProfile}>
                  <Edit className="w-4 h-4 mr-2" />
                  Edit Profile
                </Button>
              </div>

              <p className="text-sm text-muted-foreground mb-4 max-w-md">
                Welcome to FriendZone! Start creating and sharing your memories.
              </p>

              {/* Stats - These would need separate API endpoints */}
              <div className="flex justify-center sm:justify-start space-x-6">
                <div className="text-center">
                  <p className="text-lg font-semibold">-</p>
                  <p className="text-xs text-muted-foreground">Memories</p>
                </div>
                <div className="text-center">
                  <p className="text-lg font-semibold">-</p>
                  <p className="text-xs text-muted-foreground">Friends</p>
                </div>
                <div className="text-center">
                  <p className="text-lg font-semibold">-</p>
                  <p className="text-xs text-muted-foreground">Shared</p>
                </div>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Quick Actions */}
      <div className="grid grid-cols-2 gap-4">
        <Card className="hover:shadow-medium transition-shadow cursor-pointer">
          <CardContent className="p-4">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-hero rounded-lg flex items-center justify-center">
                <Users className="w-5 h-5 text-white" />
              </div>
              <div>
                <h3 className="font-semibold">Friends</h3>
                <p className="text-xs text-muted-foreground">Manage connections</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="hover:shadow-medium transition-shadow cursor-pointer">
          <CardContent className="p-4">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-hero rounded-lg flex items-center justify-center">
                <Heart className="w-5 h-5 text-white" />
              </div>
              <div>
                <h3 className="font-semibold">Memories</h3>
                <p className="text-xs text-muted-foreground">Your collection</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Edit Profile Dialog */}
      <Dialog open={showEditDialog} onOpenChange={setShowEditDialog}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <Edit className="w-5 h-5" />
              Edit Profile
            </DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label htmlFor="first_name">First Name</Label>
              <Input
                id="first_name"
                value={editForm.first_name}
                onChange={(e) => handleInputChange('first_name', e.target.value)}
                placeholder="Enter your first name"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="last_name">Last Name</Label>
              <Input
                id="last_name"
                value={editForm.last_name}
                onChange={(e) => handleInputChange('last_name', e.target.value)}
                placeholder="Enter your last name"
              />
            </div>
            <div className="space-y-2">
              <Label>Profile Picture</Label>
              <div className="flex items-center space-x-4">
                <Avatar className="w-16 h-16">
                  {editForm.profile_picture_url ? (
                    <AvatarImage src={editForm.profile_picture_url} />
                  ) : null}
                  <AvatarFallback className="bg-gradient-hero text-white">
                    {getInitials()}
                  </AvatarFallback>
                </Avatar>
                <div className="flex-1">
                  <Button
                    type="button"
                    variant="outline"
                    onClick={triggerFileSelect}
                    disabled={isUploadingImage}
                    className="w-full"
                  >
                    {isUploadingImage ? (
                      <>
                        <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                        Uploading...
                      </>
                    ) : (
                      <>
                        <Upload className="w-4 h-4 mr-2" />
                        Upload New Picture
                      </>
                    )}
                  </Button>
                  {editForm.profile_picture_url && (
                    <Button
                      type="button"
                      variant="ghost"
                      size="sm"
                      onClick={() => handleInputChange('profile_picture_url', '')}
                      className="w-full mt-2 text-xs"
                    >
                      Remove Picture
                    </Button>
                  )}
                </div>
              </div>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowEditDialog(false)} disabled={isSaving}>
              Cancel
            </Button>
            <Button onClick={handleSaveProfile} disabled={isSaving} className="bg-gradient-hero hover:opacity-90">
              {isSaving ? (
                <>
                  <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                  Saving...
                </>
              ) : (
                <>
                  <Save className="w-4 h-4 mr-2" />
                  Save Changes
                </>
              )}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Hidden File Input */}
      <input
        ref={fileInputRef}
        type="file"
        accept="image/*"
        onChange={handleFileChange}
        className="hidden"
      />
    </div>
  );
};

export default ProfileSection;