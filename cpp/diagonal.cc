/* 
Give a N*N square matrix, return an array of its anti-diagonals. Look at the example for more details.
Example:
		
Input: 	

1 2 3
4 5 6
7 8 9

Return the following :

[ 
  [1],
  [2, 4],
  [3, 5, 7],
  [6, 8],
  [9]
]

*/

class Solution {
    public:
    vector<vector<int> > diagonal(vector<vector<int> > Vec) {
        int N = Vec.size();
        if(N == 1)
                return Vec;
        
        vector<pair<int, int> > search_space;
        for(int i = 0; i < N; ++i) {
            search_space.push_back(make_pair(0, i));
        }
        for(int i = 1; i < N; ++i) {
            search_space.push_back(make_pair(i, N - 1));
        }

        vector<vector<int> > Ans;
        for(int i = 0; i < search_space.size(); ++i) {
            vector<int> Temp;
            int x = search_space[i].first;
            int y = search_space[i].second;
            while(x < N && y >= 0) {
                Temp.push_back(Vec[x][y]);
                x += 1;
                y -= 1;
            }
            Ans.push_back(Temp);
        }

        return Ans;
    }
};
