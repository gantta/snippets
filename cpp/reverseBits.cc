/* 
Reverse bits of an 32 bit unsigned integer
Example 1:
x = 0,
          00000000000000000000000000000000  
=>        00000000000000000000000000000000
return 0
Example 2:
x = 3,
          00000000000000000000000000000011 
=>        11000000000000000000000000000000
return 3221225472
*/


class Solution {
    public:
        unsigned int swapBits(unsigned int x, unsigned int i, unsigned int j) {
            unsigned int lo = ((x >> i) & 1);
            unsigned int hi = ((x >> j) & 1);
            if (lo ^ hi) {
                x ^= ((1U << i) | (1U << j));
            }
            return x;
        }

        unsigned int reverse(unsigned int x) {
            unsigned int n = sizeof(x) * 8;
            for (unsigned int i = 0; i < n/2; i++) {
                x = swapBits(x, i, n-i-1);
            }
            return x;
        }
};
