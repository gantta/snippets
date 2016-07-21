/* 

2 trees T1 and T2 are symmetric if 
1) value of T1’s root is same as T2’s root
2) T1’s left and T2’s right are symmetric. 
3) T2’s left and T1’s right are symmetric.

3 1 -1 -1
Returns True

*/

class Solution {
    public:
        bool isSymmetricHelper(TreeNode *leftTree, TreeNode *rightTree) {
            if (leftTree == NULL || rightTree == NULL) return leftTree == rightTree;
            if (leftTree->val != rightTree->val) return false;
            return isSymmetricHelper(leftTree->left, rightTree->right) && isSymmetricHelper(leftTree->right, rightTree->left);
        }
        bool isSymmetric(TreeNode *root) {
            return root == NULL || isSymmetricHelper(root->left, root->right);
        }
};
