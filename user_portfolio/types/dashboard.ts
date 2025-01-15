import { Timestamp } from 'firebase/firestore';

export interface UserData {
  id?: string;
  createdAt: Timestamp;
  email: string;
  name: string;
  phoneNumber: string;
  profileCompleted: boolean;
  profileImageUrl: string;
  role: string;
  streaks: Timestamp[];
}