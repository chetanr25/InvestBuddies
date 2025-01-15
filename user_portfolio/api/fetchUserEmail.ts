import { db } from '../lib/Firebase';
import { collection, getDocs } from 'firebase/firestore';
import { UserData } from '../hooks/userData';

export const fetchAllUsers = async (): Promise<UserData[]> => {
  try {
    const usersRef = collection(db, 'users');
    const snapshot = await getDocs(usersRef);
    
    const users: UserData[] = snapshot.docs.map(doc => {
      const data = doc.data();
      return {
        id: doc.id,
        createdAt: data.createdAt,
        email: data.email,
        name: data.name,
        phoneNumber: data.phoneNumber,
        profileCompleted: data.profileCompleted,
        profileImageUrl: data.profileImageUrl,
        role: data.role,
        streaks: data.streaks
      } as UserData;
    });

    console.log('Fetched users:', users);
    return users;
  } catch (error) {
    console.error('Error fetching users:', error);
    throw error;
  }
};

// Test the function
fetchAllUsers().then(users => {
  users.forEach(user => {
    console.log(`Document ID: ${user.id}, Name: ${user.name}`);
  });
}).catch(error => {
  console.error('Error:', error);
});