"use client";

import { useEffect, useState } from "react";
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from "recharts";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { 
  Download, TrendingUp, Users, Trophy, Brain, 
  Wallet, Calendar, Briefcase, DollarSign, Target,
  Star 
} from "lucide-react";
import Link from "next/link";
import { fetchUserEmail } from "@/api/fetchUserEmail";

// Types based on Firestore data
interface UserData {
  name: string;
  email: string;
  profileImageUrl: string;
  ageGroup: string;
  employmentStatus: string;
  incomeRange: string;
  riskLevel: string;
  streaks: { seconds: number; nanoseconds: number; }[];
}

export default function Dashboard() {
  const [userData, setUserData] = useState<UserData | null>(null);
  const [currentStreak, setCurrentStreak] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);


  useEffect(() => {
    // Mock fetching user data - replace with actual Firebase fetch
    const mockUserData: UserData = {
      name: "chetan",
      email: "chetan@gmail.com",
      profileImageUrl: "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
      ageGroup: "26-35",
      employmentStatus: "Student",
      incomeRange: "Less than ₹25,000",
      riskLevel: "Low Risk - Savings accounts, bonds",
      streaks: [
        { seconds: 1705001321, nanoseconds: 0 },
        { seconds: 1705087740, nanoseconds: 0 },
        { seconds: 1705174159, nanoseconds: 0 }
      ]
    };

    setUserData(mockUserData);
    setCurrentStreak(mockUserData.streaks.length);
  }, []);

  // useEffect(() => {
  //   const getUserData = async () => {
  //     try {
  //       setIsLoading(true);
  //       const email = "chetan@gmail.com"; // Replace with actual user email
  //       const data = await fetchUserEmail(email);
        
  //       if (data) {
  //         setUserData(data);
  //         setCurrentStreak(data.streaks?.length || 0);
  //       }
  //     } catch (err) {
  //       console.error('Error fetching user data:', err);
  //       setError('Failed to load user data');
  //     } finally {
  //       setIsLoading(false);
  //     }
  //   };

  //   getUserData();
  // }, []);

  // if (isLoading) return <div>Loading...</div>;
  // if (error) return <div>{error}</div>;

  return (
    <div className="min-h-screen bg-background p-8">
      {/* Profile Section */}
      <Card className="mb-8">
        <CardContent className="pt-6">
          <div className="flex items-start gap-6">
            <Avatar className="h-24 w-24">
              <AvatarImage src={userData?.profileImageUrl} />
              <AvatarFallback>{userData?.name?.[0]?.toUpperCase()}</AvatarFallback>
            </Avatar>
            <div className="grid gap-1">
              <h2 className="text-2xl font-bold">{userData?.name}</h2>
              <p className="text-muted-foreground">{userData?.email}</p>
              <div className="flex flex-wrap gap-4 mt-2">
                <Badge variant="secondary" className="flex gap-1">
                  <Calendar className="h-4 w-4" />
                  {userData?.ageGroup}
                </Badge>
                <Badge variant="secondary" className="flex gap-1">
                  <Briefcase className="h-4 w-4" />
                  {userData?.employmentStatus}
                </Badge>
                <Badge variant="secondary" className="flex gap-1">
                  <DollarSign className="h-4 w-4" />
                  {userData?.incomeRange}
                </Badge>
                <Badge variant="secondary" className="flex gap-1">
                  <Target className="h-4 w-4" />
                  {userData?.riskLevel}
                </Badge>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Stats Grid */}
      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4 mb-8">
        <StatsCard
          title="Portfolio Value"
          value="₹18,000"
          description="+12% from last month"
          icon={<Wallet className="h-6 w-6" />}
        />
        <StatsCard
          title="Current Streak"
          value={`${currentStreak} days`}
          description="Keep it going!"
          icon={<Trophy className="h-6 w-6" />}
        />
        <StatsCard
          title="Knowledge Score"
          value="850"
          description="Top 10% of users"
          icon={<Brain className="h-6 w-6" />}
        />
        <StatsCard
          title="Investment Buddies"
          value="8"
          description="4 new this month"
          icon={<Users className="h-6 w-6" />}
        />
      </div>

      {/* Main Content Grid */}
      <div className="grid gap-6 md:grid-cols-2">
        {/* Learning Progress Chart */}
        <Card>
          <CardHeader>
            <CardTitle>Learning Progress</CardTitle>
            <CardDescription>Your knowledge growth over time</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="h-[300px]">
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={[
                  { day: "Mon", score: 65 },
                  { day: "Tue", score: 70 },
                  { day: "Wed", score: 85 },
                  { day: "Thu", score: 75 },
                  { day: "Fri", score: 90 },
                ]}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="day" />
                  <YAxis />
                  <Tooltip />
                  <Line 
                    type="monotone" 
                    dataKey="score" 
                    stroke="hsl(var(--primary))" 
                    strokeWidth={2}
                  />
                </LineChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>

        {/* Quiz Streaks */}
        <Card>
          <CardHeader>
            <CardTitle>Quiz Achievements</CardTitle>
            <CardDescription>Your learning milestones</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div className="flex items-center gap-4 p-4 bg-secondary/50 rounded-lg">
                <Trophy className="h-8 w-8 text-primary" />
                <div>
                  <h4 className="font-semibold">Current Streak: {currentStreak} days</h4>
                  <p className="text-sm text-muted-foreground">
                    Last quiz completed: {new Date((userData?.streaks?.[currentStreak - 1]?.seconds ?? 0) * 1000).toLocaleDateString()}
                  </p>
                </div>
              </div>
              <div className="grid grid-cols-7 gap-2">
                {Array.from({ length: 7 }).map((_, i) => (
                  <div
                    key={i}
                    className={`h-12 flex items-center justify-center transition-all duration-300 hover:scale-110`}
                  >
                    <Star
                      className={`w-8 h-8 ${
                        i < currentStreak 
                          ? 'text-yellow-500 dark:text-yellow-400 fill-current animate-pulse'
                          : 'text-muted-foreground fill-current opacity-30'
                      }`}
                    />
                  </div>
                ))}
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Investment Buddies */}
        <Card className="col-span-2">
          <CardHeader>
            <CardTitle>Investment Buddies</CardTitle>
            <CardDescription>Your investment partners</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
              {[
                { id: "1", name: "Alfiya", investments: 3, totalAmount: "₹15,000" },
                { id: "2", name: "Yuktha", investments: 2, totalAmount: "₹8,000" },
                { id: "3", name: "Varsha", investments: 4, totalAmount: "₹20,000" },
              ].map((buddy) => (
                <Link 
                  href={`/`} 
                  key={buddy.id}
                  className="block"
                >
                  <div className="p-4 rounded-lg bg-secondary/50 hover:bg-secondary transition-colors">
                    <div className="flex items-center gap-3 mb-2">
                      <Avatar className="h-8 w-8">
                        <AvatarFallback>{buddy.name[0]}</AvatarFallback>
                      </Avatar>
                      <h4 className="font-medium">{buddy.name}</h4>
                    </div>
                    <div className="text-sm text-muted-foreground">
                      <p>{buddy.investments} joint investments</p>
                      <p>Total: {buddy.totalAmount}</p>
                    </div>
                  </div>
                </Link>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}

// StatsCard component
interface StatsCardProps {
  title: string;
  value: string;
  description: string;
  icon: React.ReactNode;
}

function StatsCard({ title, value, description, icon }: StatsCardProps) {
  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between pb-2">
        <CardTitle className="text-sm font-medium text-muted-foreground">
          {title}
        </CardTitle>
        {icon}
      </CardHeader>
      <CardContent>
        <div className="text-2xl font-bold">{value}</div>
        <p className="text-xs text-muted-foreground">{description}</p>
      </CardContent>
    </Card>
  );
}