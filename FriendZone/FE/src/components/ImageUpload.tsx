import React, { useState, useRef } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Upload, X, Loader2, ImageIcon } from "lucide-react";
import { AuthApi, InitSessionResponse } from "@/lib/api";
import { toast } from "@/hooks/use-toast";
import MemoryChat from "./MemoryChat";

interface ImageUploadProps {
  token: string;
  onImageUploaded?: (publicUrl: string) => void;
  onMemoryCreated?: () => void;
}

export const ImageUpload: React.FC<ImageUploadProps> = ({ token, onImageUploaded, onMemoryCreated }) => {
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [isUploading, setIsUploading] = useState(false);
  const [isDragOver, setIsDragOver] = useState(false);
  const [showChat, setShowChat] = useState(false);
  const [sessionData, setSessionData] = useState<InitSessionResponse | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFileSelect = (file: File) => {
    if (file && file.type.startsWith('image/')) {
      setSelectedFile(file);
      const reader = new FileReader();
      reader.onload = (e) => {
        setPreviewUrl(e.target?.result as string);
      };
      reader.readAsDataURL(file);
    } else {
      toast({
        title: "Invalid file type",
        description: "Please select an image file (PNG, JPG, etc.)",
        variant: "destructive",
      });
    }
  };

  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      handleFileSelect(file);
    }
  };

  const handleDrop = (event: React.DragEvent<HTMLDivElement>) => {
    event.preventDefault();
    setIsDragOver(false);
    const file = event.dataTransfer.files[0];
    if (file) {
      handleFileSelect(file);
    }
  };

  const handleDragOver = (event: React.DragEvent<HTMLDivElement>) => {
    event.preventDefault();
    setIsDragOver(true);
  };

  const handleDragLeave = (event: React.DragEvent<HTMLDivElement>) => {
    event.preventDefault();
    setIsDragOver(false);
  };

  const handleUpload = async () => {
    if (!selectedFile) return;

    setIsUploading(true);
    try {
      const presignedData = await AuthApi.generatePresignedUrl(token);
      
      // Use XMLHttpRequest to avoid CORS issues with fetch
      const xhr = new XMLHttpRequest();
      
      xhr.open('PUT', presignedData.upload_url);
      xhr.setRequestHeader('Content-Type', selectedFile.type);
      
      xhr.onload = async () => {
        if (xhr.status === 200) {
          try {
            // Call init_session after successful upload
            const sessionResponse = await AuthApi.initSession(token, {
              image_url: presignedData.public_url,
              // Add location and date if available
              location: undefined, // Could get from browser geolocation
              date: new Date().toISOString().slice(0, 19).replace('T', ' ')
            });

            // Show chat interface instead of toast
            setSessionData(sessionResponse);
            setShowChat(true);
            
            onImageUploaded?.(presignedData.public_url);
            handleClear();
          } catch (error) {
            console.error('Failed to initialize session:', error);
            toast({
              title: "Image uploaded but session failed",
              description: "Your image was uploaded but we couldn't start the memory session.",
              variant: "destructive",
            });
            
            onImageUploaded?.(presignedData.public_url);
            handleClear();
          }
        } else {
          throw new Error(`Upload failed with status: ${xhr.status}`);
        }
        setIsUploading(false);
      };
      
      xhr.onerror = () => {
        console.error('Upload error:', xhr.statusText);
        toast({
          title: "Upload failed",
          description: "There was an error uploading your image. Please try again.",
          variant: "destructive",
        });
        setIsUploading(false);
      };
      
      xhr.send(selectedFile);
      
    } catch (error) {
      console.error('Upload error:', error);
      toast({
        title: "Upload failed",
        description: "There was an error uploading your image. Please try again.",
        variant: "destructive",
      });
      setIsUploading(false);
    }
  };

  const handleClear = () => {
    setSelectedFile(null);
    setPreviewUrl(null);
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  const handleCloseChat = () => {
    setShowChat(false);
    setSessionData(null);
  };

  const handleMemorySaved = () => {
    onMemoryCreated?.();
    handleCloseChat();
  };

  return (
    <>
      <Card className="mb-6">
        <CardContent className="p-6">
        <div className="space-y-4">
          <div className="flex items-center space-x-2 mb-4">
            <ImageIcon className="w-5 h-5 text-primary" />
            <h3 className="text-lg font-semibold">Share a Memory</h3>
          </div>

          {/* File Drop Zone */}
          <div
            className={`relative border-2 border-dashed rounded-lg p-8 text-center transition-colors ${
              isDragOver
                ? 'border-primary bg-primary/5'
                : selectedFile
                ? 'border-green-300 bg-green-50'
                : 'border-muted-foreground/25 hover:border-primary/50'
            }`}
            onDrop={handleDrop}
            onDragOver={handleDragOver}
            onDragLeave={handleDragLeave}
          >
            <input
              ref={fileInputRef}
              type="file"
              accept="image/*"
              onChange={handleFileChange}
              className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
            />
            
            {previewUrl ? (
              <div className="space-y-4">
                <div className="relative inline-block">
                  <img
                    src={previewUrl}
                    alt="Preview"
                    className="max-w-full max-h-48 rounded-lg shadow-md"
                  />
                  <Button
                    variant="destructive"
                    size="sm"
                    className="absolute -top-2 -right-2 rounded-full w-6 h-6 p-0"
                    onClick={handleClear}
                  >
                    <X className="w-3 h-3" />
                  </Button>
                </div>
                <p className="text-sm text-muted-foreground">
                  {selectedFile?.name}
                </p>
              </div>
            ) : (
              <div className="space-y-4">
                <div className="w-16 h-16 mx-auto rounded-full bg-muted flex items-center justify-center">
                  <Upload className="w-8 h-8 text-muted-foreground" />
                </div>
                <div>
                  <p className="text-lg font-medium">
                    {isDragOver ? 'Drop your image here' : 'Upload an image'}
                  </p>
                  <p className="text-sm text-muted-foreground mt-1">
                    Drag and drop or click to select a file
                  </p>
                  <p className="text-xs text-muted-foreground mt-2">
                    PNG, JPG, JPEG up to 10MB
                  </p>
                </div>
              </div>
            )}
          </div>

          {/* Upload Button */}
          {selectedFile && (
            <div className="flex justify-end space-x-2">
              <Button
                variant="outline"
                onClick={handleClear}
                disabled={isUploading}
              >
                Cancel
              </Button>
              <Button
                onClick={handleUpload}
                disabled={isUploading}
                className="min-w-[100px]"
              >
                {isUploading ? (
                  <>
                    <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                    Uploading...
                  </>
                ) : (
                  <>
                    <Upload className="w-4 h-4 mr-2" />
                    Upload
                  </>
                )}
              </Button>
            </div>
          )}
        </div>
      </CardContent>
    </Card>

    {/* Memory Chat Interface */}
    {showChat && sessionData && (
      <MemoryChat
        sessionData={sessionData}
        token={token}
        onClose={handleCloseChat}
        onMemorySaved={handleMemorySaved}
      />
    )}
    </>
  );
};

export default ImageUpload;