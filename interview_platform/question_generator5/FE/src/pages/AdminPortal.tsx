import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Header } from '@/components/Layout/Header';
import { PlatformButton } from '@/components/ui/platform-button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Check, Copy, Plus, Minus } from 'lucide-react';
import { useToast } from '@/hooks/use-toast';
import { registerCandidates, JobContext, Candidate as APICandidateType, RegisteredCandidate, APIError } from '@/services/api';

interface Candidate {
  name: string;
  email: string;
  password: string;
}

const AdminPortal = () => {
  const navigate = useNavigate();
  const { toast } = useToast();
  
  // Step 1: Job Details
  const [companyName, setCompanyName] = useState('QuantumLeap AI');
  const [companyInfo, setCompanyInfo] = useState('We build foundational AI models.');
  const [jobRole, setJobRole] = useState('Research Scientist');
  const [jobDescription, setJobDescription] = useState('Seeking a PhD-level Research Scientist...');
  const [numQuestions, setNumQuestions] = useState('5');
  const [jobDetailsLocked, setJobDetailsLocked] = useState(false);
  
  // Step 2: Candidates
  const [numCandidates, setNumCandidates] = useState(1);
  const [candidates, setCandidates] = useState<Candidate[]>([
    { name: '', email: '', password: '' }
  ]);
  const [candidatesRegistered, setCandidatesRegistered] = useState(false);
  const [registeredCandidates, setRegisteredCandidates] = useState<RegisteredCandidate[]>([]);
  const [loading, setLoading] = useState(false);

  const handleLogout = () => {
    navigate('/');
  };

  const handleLockJobDetails = () => {
    if (!companyName || !jobRole || !jobDescription) {
      toast({
        variant: "destructive",
        title: "Error",
        description: "Please fill in all required job details."
      });
      return;
    }
    
    setJobDetailsLocked(true);
    toast({
      title: "Job Details Locked",
      description: "You can now proceed to register candidates."
    });
  };

  const updateNumCandidates = (num: number) => {
    setNumCandidates(Math.max(1, num));
    const newCandidates = [...candidates];
    
    if (num > candidates.length) {
      // Add more candidates
      for (let i = candidates.length; i < num; i++) {
        newCandidates.push({ name: '', email: '', password: '' });
      }
    } else if (num < candidates.length) {
      // Remove excess candidates
      newCandidates.splice(num);
    }
    
    setCandidates(newCandidates);
  };

  const updateCandidate = (index: number, field: keyof Candidate, value: string) => {
    const newCandidates = [...candidates];
    newCandidates[index] = { ...newCandidates[index], [field]: value };
    setCandidates(newCandidates);
  };

  const generatePassword = () => {
    return Math.random().toString(36).substring(2, 10);
  };

  const handleRegisterCandidates = async () => {
    // Validate all candidates have name and email
    const isValid = candidates.every(c => c.name.trim() && c.email.trim());
    if (!isValid) {
      toast({
        variant: "destructive",
        title: "Error",
        description: "Please fill in name and email for all candidates."
      });
      return;
    }

    setLoading(true);
    
    try {
      // Prepare job context exactly like Streamlit
      const jobContext: JobContext = {
        company_name: companyName,
        company_info: companyInfo,
        job_role: jobRole,
        job_description: jobDescription,
        number_of_questions: parseInt(numQuestions)
      };

      // Prepare candidates with auto-generated passwords if empty
      const candidatesData: APICandidateType[] = candidates.map(candidate => ({
        name: candidate.name.trim(),
        email: candidate.email.trim(),
        password: candidate.password.trim() || generatePassword()
      }));

      // Call the API (matches Streamlit logic exactly)
      const result = await registerCandidates(jobContext, candidatesData);
      
      setRegisteredCandidates(result);
      setCandidatesRegistered(true);
      
      toast({
        title: "Candidates Registered",
        description: `Successfully registered ${result.length} candidate(s) with session IDs.`
      });
    } catch (error) {
      const errorMessage = error instanceof APIError ? error.message : 'An unexpected error occurred';
      toast({
        variant: "destructive",
        title: "Registration Failed",
        description: errorMessage
      });
    } finally {
      setLoading(false);
    }
  };

  const copyToClipboard = (text: string, label: string) => {
    navigator.clipboard.writeText(text);
    toast({
      title: "Copied",
      description: `${label} copied to clipboard.`
    });
  };

  return (
    <div className="min-h-screen bg-background">
      <Header 
        showAuth={false} 
        showLogout={true} 
        title="Admin Dashboard" 
        onLogout={handleLogout} 
      />
      
      <div className="container mx-auto px-6 py-8">
        <div className="grid gap-8 lg:grid-cols-2">
          {/* Step 1: Define Job Context */}
          <Card className="card-shadow-lg border-0">
            <CardHeader>
              <CardTitle className="flex items-center space-x-2">
                <span className="flex h-8 w-8 items-center justify-center rounded-full bg-primary text-primary-foreground text-sm font-bold">
                  1
                </span>
                <span>Define Job Context</span>
                {jobDetailsLocked && <Check className="h-5 w-5 text-success" />}
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="companyName">Company Name *</Label>
                <Input
                  id="companyName"
                  value={companyName}
                  onChange={(e) => setCompanyName(e.target.value)}
                  placeholder="Tech Corp Inc."
                  disabled={jobDetailsLocked}
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="companyInfo">Company Info</Label>
                <Textarea
                  id="companyInfo"
                  value={companyInfo}
                  onChange={(e) => setCompanyInfo(e.target.value)}
                  placeholder="Brief description of your company..."
                  disabled={jobDetailsLocked}
                  rows={3}
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="jobRole">Job Role *</Label>
                <Input
                  id="jobRole"
                  value={jobRole}
                  onChange={(e) => setJobRole(e.target.value)}
                  placeholder="Senior Software Engineer"
                  disabled={jobDetailsLocked}
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="jobDescription">Job Description *</Label>
                <Textarea
                  id="jobDescription"
                  value={jobDescription}
                  onChange={(e) => setJobDescription(e.target.value)}
                  placeholder="Detailed job requirements and responsibilities..."
                  disabled={jobDetailsLocked}
                  rows={4}
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="numQuestions">Number of Questions</Label>
                <Input
                  id="numQuestions"
                  type="number"
                  min="1"
                  max="20"
                  value={numQuestions}
                  onChange={(e) => setNumQuestions(e.target.value)}
                  disabled={jobDetailsLocked}
                />
              </div>
              
              <PlatformButton
                variant={jobDetailsLocked ? "success" : "secondary"}
                onClick={handleLockJobDetails}
                disabled={jobDetailsLocked}
                className="w-full"
              >
                {jobDetailsLocked ? (
                  <>
                    <Check className="mr-2 h-4 w-4" />
                    Locked
                  </>
                ) : (
                  'Lock Job Details'
                )}
              </PlatformButton>
            </CardContent>
          </Card>

          {/* Step 2: Register Candidates */}
          <Card className={`card-shadow-lg border-0 ${!jobDetailsLocked ? 'opacity-50' : ''}`}>
            <CardHeader>
              <CardTitle className="flex items-center space-x-2">
                <span className="flex h-8 w-8 items-center justify-center rounded-full bg-primary text-primary-foreground text-sm font-bold">
                  2
                </span>
                <span>Register Candidates</span>
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {jobDetailsLocked ? (
                <>
                  <div className="flex items-center space-x-4">
                    <Label>Number of Candidates:</Label>
                    <div className="flex items-center space-x-2">
                      <PlatformButton
                        variant="outline"
                        size="icon"
                        onClick={() => updateNumCandidates(numCandidates - 1)}
                        disabled={candidatesRegistered}
                      >
                        <Minus className="h-4 w-4" />
                      </PlatformButton>
                      <span className="w-8 text-center font-semibold">{numCandidates}</span>
                      <PlatformButton
                        variant="outline"
                        size="icon"
                        onClick={() => updateNumCandidates(numCandidates + 1)}
                        disabled={candidatesRegistered}
                      >
                        <Plus className="h-4 w-4" />
                      </PlatformButton>
                    </div>
                  </div>

                  <div className="space-y-4 max-h-96 overflow-y-auto">
                    {candidates.map((candidate, index) => (
                      <Card key={index} className="border">
                        <CardContent className="pt-4 space-y-3">
                          <h4 className="font-medium">Candidate {index + 1}</h4>
                          <div className="grid gap-3 sm:grid-cols-2">
                            <div className="space-y-1">
                              <Label>Name *</Label>
                              <Input
                                value={candidate.name}
                                onChange={(e) => updateCandidate(index, 'name', e.target.value)}
                                placeholder="John Doe"
                                disabled={candidatesRegistered}
                              />
                            </div>
                            <div className="space-y-1">
                              <Label>Email *</Label>
                              <Input
                                type="email"
                                value={candidate.email}
                                onChange={(e) => updateCandidate(index, 'email', e.target.value)}
                                placeholder="john@email.com"
                                disabled={candidatesRegistered}
                              />
                            </div>
                          </div>
                          <div className="space-y-1">
                            <Label>Password (optional - will generate if empty)</Label>
                            <Input
                              type="password"
                              value={candidate.password}
                              onChange={(e) => updateCandidate(index, 'password', e.target.value)}
                              placeholder="Leave empty to auto-generate"
                              disabled={candidatesRegistered}
                            />
                          </div>
                        </CardContent>
                      </Card>
                    ))}
                  </div>

                  <PlatformButton
                    onClick={handleRegisterCandidates}
                    disabled={candidatesRegistered}
                    loading={loading}
                    className="w-full"
                  >
                    Register Candidates & Generate IDs
                  </PlatformButton>
                </>
              ) : (
                <p className="text-muted-foreground text-center py-8">
                  Please lock job details first to enable candidate registration.
                </p>
              )}
            </CardContent>
          </Card>
        </div>

        {/* Step 3: Generated Interview Sessions */}
        {candidatesRegistered && (
          <Card className="mt-8 card-shadow-lg border-0">
            <CardHeader>
              <CardTitle className="flex items-center space-x-2">
                <span className="flex h-8 w-8 items-center justify-center rounded-full bg-success text-success-foreground text-sm font-bold">
                  3
                </span>
                <span>Generated Interview Sessions</span>
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead>
                    <tr className="border-b">
                      <th className="text-left py-3 px-4 font-semibold">Name</th>
                      <th className="text-left py-3 px-4 font-semibold">Email</th>
                      <th className="text-left py-3 px-4 font-semibold">Candidate ID</th>
                      <th className="text-left py-3 px-4 font-semibold">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {registeredCandidates.map((candidate, index) => (
                      <tr key={index} className="border-b">
                        <td className="py-3 px-4">{candidate.candidate_name}</td>
                        <td className="py-3 px-4">{candidate.candidate_email}</td>
                        <td className="py-3 px-4 font-mono text-sm font-semibold text-primary">
                          {candidate.candidate_id}
                        </td>
                        <td className="py-3 px-4">
                          <PlatformButton
                            variant="ghost"
                            size="sm"
                            onClick={() => copyToClipboard(candidate.candidate_id, 'Candidate ID')}
                          >
                            <Copy className="h-4 w-4" />
                          </PlatformButton>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </CardContent>
          </Card>
        )}
      </div>
    </div>
  );
};

export default AdminPortal;