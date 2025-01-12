import { db } from '../lib/Firebase';
import { doc, getDoc } from 'firebase/firestore';
import { UserData } from '../hooks/userData';

export const fetchUserEmail = async (email: string): Promise<UserData | null> => {
  try {
    const userRef = doc(db, 'users', email);
    const userSnap = await getDoc(userRef);
    
    if (!userSnap.exists()) {
      return null;
    }
 console.log("hello");
    return {
        id: userSnap.id,
        ...userSnap.data()
    } as unknown as UserData;
  } catch (error) {
    console.error('Error fetching user:', error);
    throw error;
  }
};

fetchUserEmail('example@example.com');