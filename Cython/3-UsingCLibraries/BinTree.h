#ifndef BINNODE_H
#define BINNODE_H

#define BinNodePosi(T) BinNode<T>*
#define stature(p) ((p)? (p)->height : -1)
#define isRoot(x) (!((x).parent))
#define isLChild(x) (!isRoot(x) && (&(x) == (x).parent->lc))
#define isRChild(x) (!isRoot(x) && (&(x) == (x).parent->rc))

template <typename T>
struct BinNode
{
	T data;
	BinNodePosi(T) parent;
	BinNodePosi(T) lc;
	BinNodePosi(T) rc;
	bool isOnRPath; // true if on the rightmost path of the tree

	BinNode() : parent(NULL), lc(NULL), rc(NULL), isOnRPath(false)
	{
	}

	BinNode(T e,BinNodePosi(T) p = NULL,BinNodePosi(T) lc = NULL, BinNodePosi(T) rc = NULL):
		data(e), parent(p), lc(lc), rc(rc), isOnRPath(false)
	{
	}

	BinNodePosi(T) insertAsLC(T const&); // overwrite the left child of *this
	BinNodePosi(T) insertAsRC(T const&); // overwrite the right child of *this

	template <typename VST>
	void travPost(BinNodePosi(T) x, VST visit); // postorder traverse the tree rooted at x

	template <typename VST>
	void travPost(VST visit) { this->travPost(this, visit); }
};

template <typename T>
BinNode<T>* BinNode<T>::insertAsLC(T const& e)
{
	return lc = new BinNode(e, this);
}

template <typename T>
BinNode<T>* BinNode<T>::insertAsRC(T const& e)
{
	rc = new BinNode(e, this);
	if (this->isOnRPath)
		rc->isOnRPath = true;
	return rc;
}

template <typename T>
template <typename VST>
void BinNode<T>::travPost(BinNode<T>* x, VST visit) // O(n)
{
	if (!x) return;
	travPost(x->lc, visit);
	travPost(x->rc, visit);
	visit(x->data);
}

template <typename T>
class BinTree
{
protected:
	int _size;
	BinNodePosi(T) _root;

public:
	BinTree(): _size(0), _root(NULL)
	{
	}

	//	~BinTree() { if (0 < _size) this->remove(_root); }

	int size() const { return _size; }
	bool empty() const { return !_root; }
	BinNodePosi(T) root() const { return _root; }
	BinNodePosi(T) insertAsRoot(T const& e);
	BinNodePosi(T) insertAsLC(BinNodePosi(T) x, T const& e);
	BinNodePosi(T) insertAsRC(BinNodePosi(T) x, T const& e);
	BinNodePosi(T) attachAsLC(BinNodePosi(T) x, BinTree<T>* & S);
	BinNodePosi(T) attachAsRC(BinNodePosi(T) x, BinTree<T>* & S);

	template <typename VST>
	void travPost(VST visit) { if (_root) _root->travPost(visit); } // postorder traversal
};

template <typename T>
BinNode<T>* BinTree<T>::insertAsRoot(T const& e)
{
	_size = 1;
	_root = new BinNode<T>(e);
	_root->isOnRPath = true;
	return _root;
}

template <typename T>
BinNode<T>* BinTree<T>::insertAsLC(BinNode<T>* x, T const& e)
{
	_size++;
	x->insertAsLC(e);
	return x->lc;
}

template <typename T>
BinNode<T>* BinTree<T>::insertAsRC(BinNode<T>* x, T const& e)
{
	_size++;
	x->insertAsRC(e); // will set e's isOnRPath true if x->isOnRPath == true
	return x->rc;
}

template <typename T>
BinNode<T>* BinTree<T>::attachAsLC(BinNode<T>* x, BinTree<T>*& S)
{
	if ((x->lc = S->_root)) // if S->_root is NOT NULL
	{
		x->lc->parent = x;
		/* set all nodes on rightmost path of S to be NOT on rPath of (*this) */
		BinNodePosi(T) temp = S->_root;
		do
		{
			temp->isOnRPath = false;
			temp = temp->rc;
		}
		while (!temp);
	}
	_size += S->_size; // assume that in the beginning x doesn't have the left child
	S->_root = NULL;
	S->_size = 0;
	//	release(S);
	S = NULL;
	return x;
}


template <typename T>
BinNode<T>* BinTree<T>::attachAsRC(BinNode<T>* x, BinTree<T>*& S)
{
	if ((x->rc = S->_root)) // if S->_root is NOT NULL
	{
		x->rc->parent = x;
		if (!x->isOnRPath)
		{
			/* set all nodes on rightmost path of S to be NOT on rPath of (*this) */
			BinNodePosi(T) temp = S->_root;
			do
			{
				temp->isOnRPath = false;
				temp = temp->rc;
			}
			while (!temp);
		}
	}
	_size += S->_size; // assume that in the beginning x doesn't have the right child
	S->_root = NULL;
	S->_size = 0;
	//	release(S);
	S = NULL;
	return x;
}

#endif /*BINNODE_H*/
