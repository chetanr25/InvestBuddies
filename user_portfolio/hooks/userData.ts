export interface UserData {
    id: any;
    createdAt: { seconds: number; nanoseconds: number };
    email: string;
    name: string;
    phoneNumber: string;
    profileCompleted: boolean;
    profileImageUrl: string;
    role: string;
    streaks: Array<{ seconds: number; nanoseconds: number }>;
  }