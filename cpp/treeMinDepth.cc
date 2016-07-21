        int minDepth(TreeNode *root) {
            // Corner case. Should never be hit unless the code is called on root = NULL
            if (root == NULL) return 0;
            // Base case : Leaf node. This accounts for height = 1.
            if (root->left == NULL && root->right == NULL) return 1;

            if (!root->left) return minDepth(root->right) + 1;
            if (!root->right) return minDepth(root->left) + 1;

            return min(minDepth(root->left), minDepth(root->right)) + 1; 
        }
