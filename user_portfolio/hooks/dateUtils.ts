// src/hooks/dateUtils.ts
import { Timestamp } from 'firebase/firestore';

export const formatTimestamp = (timestamp: Timestamp): string => {
  return timestamp.toDate().toLocaleDateString('en-IN', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    hour12: true
  });
};

export const calculateStreak = (streaks: Timestamp[]): number => {
  if (!streaks || streaks.length === 0) return 0;
  
  // Sort streaks by most recent first
  const sortedStreaks = [...streaks].sort((a, b) => b.seconds - a.seconds);
  const lastStreakDate = sortedStreaks[0].toDate();
  const today = new Date();
  
  // Reset time portions for date comparison
  lastStreakDate.setHours(0, 0, 0, 0);
  today.setHours(0, 0, 0, 0);
  
  const diffTime = Math.abs(today.getTime() - lastStreakDate.getTime());
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  
  // If last streak is more than a day old, streak is broken
  if (diffDays > 1) {
    return 0;
  }
  
  return streaks.length;
};