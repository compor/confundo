
#include <vector>
#include <memory>

#ifndef NODE_H
#define NODE_H

class Bar;

class Node {
public:
  Node();

private:
  //std::vector<Bar *> v;
  std::vector<std::shared_ptr<Bar>> v;

  // this creates a circular dep because the constructor of vector needs
  // to know how to create and allocate space for this object
  //std::vector<Bar> v;
};


#endif // NODE_H

