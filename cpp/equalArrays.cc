/* 
Given an array A of integers, find the index of values that satisfy A + B = C + D, where A,B,C & D are integers values in the array

Note:

1) Return the indices `A1 B1 C1 D1`, so that 
  A[A1] + A[B1] = A[C1] + A[D1]
  A1 < B1, C1 < D1
  A1 < C1, B1 != D1, B1 != C1 

2) If there are more than one solutions, 
   then return the tuple of values which are lexicographical smallest. 

Assume we have two solutions
S1 : A1 B1 C1 D1 ( these are values of indices int the array )  
S2 : A2 B2 C2 D2

S1 is lexicographically smaller than S2 iff
  A1 < A2 OR
  A1 = A2 AND B1 < B2 OR
  A1 = A2 AND B1 = B2 AND C1 < C2 OR 
  A1 = A2 AND B1 = B2 AND C1 = C2 AND D1 < D2
Example:

Input: [3, 4, 7, 1, 2, 9, 8]
Output: [0, 2, 3, 5] (O index)

*/

class Solution {
    public:
    vector<int> equal(vector<int> &vec)
    {
        int N = vec.size();
        // With every sum, we store the lexicographically first occuring pair of integers. 
        map<int, pair<int, int> > Hash;
        vector<int> Ans;
        
        for(int i = 0; i < N; ++i) {
            for(int j = i + 1; j < N; ++j) {
                
                int Sum = vec[i] + vec[j];

                if (Hash.find(Sum) == Hash.end()) {
                    Hash[Sum] = make_pair(i, j);
                    continue;
                }
                
                pair<int, int> p1 = Hash[Sum];
                if(p1.first != i && p1.first != j && p1.second != i && p1.second != j) {
                    vector<int> ans;
                    ans.push_back(p1.first);
                    ans.push_back(p1.second);
                    ans.push_back(i);
                    ans.push_back(j);
                    
                    if (Ans.size() == 0) Ans = ans;
                    else {
                        // compare and assign Ans
                        bool shouldReplace = false;
                        for (int i1 = 0; i1 < Ans.size(); i1++) {
                            if (Ans[i1] < ans[i1]) break;
                            if (Ans[i1] > ans[i1]) {
                                shouldReplace = true;
                                break;
                            }
                        }
                        if (shouldReplace) Ans = ans;
                    }
                }
            }
        }

        return Ans;
    }
};