%------------------------------ PolyTop3D ----------------------------------%
function [Node,Element,Supp,Load,ElemCtrd] = RegMesher(Domain,NElemX,NElemY,NElemZ)
BdBox = Domain('BdBox',[]);
x = linspace(BdBox(1),BdBox(2),NElemX+1);
y = linspace(BdBox(3),BdBox(4),NElemY+1);
z = linspace(BdBox(5),BdBox(6),NElemZ+1);
[X,Y,Z] = meshgrid(x,y,z); Node = [X(:),Y(:),Z(:)];
Element = cell(NElemX*NElemY*NElemZ,1);
n=zeros(1,8); dn=(NElemX+1)*(NElemY+1);
for i=1:NElemX
  for j=1:NElemY
    n(1)=(i-1)*(NElemY+1)+j;
    n(2)=  i  *(NElemY+1)+j;
    n(3)=n(2)+1;
    n(4)=n(1)+1;
    n(5:8)=n(1:4)+dn;
    for k=1:NElemZ
      Element{(k-1)*NElemX*NElemY+(i-1)*NElemY+j}=n+(k-1)*dn;
    end
  end
end
ElemCtrd = zeros(NElemX*NElemY*NElemZ,3);
for el = 1:NElemX*NElemY*NElemZ       %Compute the centroids of all the elements
  ElemCtrd(el,:) = [sum(Node(Element{el},1))/8 ...
                    sum(Node(Element{el},2))/8 ...
                    sum(Node(Element{el},3))/8];
end
d = Domain('Dist',ElemCtrd);
%%
Holes = d(:,end)>0;
if sum(Holes)>1
  Element0 = Element(Holes==0);
  Map = unique([Element0{:}]);
  CNode = [1:size(Node,1)];
  CNode(setdiff(CNode,Map)) = max(Map);
  [Node,Element] = RegMshr_RbldLists(Node,Element0,CNode);
end
%%
ElemCtrd = zeros(length(Element),3);
for el = 1:length(Element)       %Compute the centroids of all the elements
  ElemCtrd(el,:) = [sum(Node(Element{el},1))/8 ...
                    sum(Node(Element{el},2))/8 ...
                    sum(Node(Element{el},3))/8];
end
%%
BC = Domain('BC',{Node,Element});  %Recover BC
Supp = BC{1}; Load = BC{2};
%------------------------------------------------------------ REBUILD LISTS
function [Node,Element] = RegMshr_RbldLists(Node0,Element0,cNode)
Element = cell(size(Element0,1),1);
[foo,ix,jx] = unique(cNode);
if ~isequal(size(jx),size(cNode)), jx=jx'; end % +R2013a compatibility fix
if size(Node0,1)>length(ix), ix(end)=max(cNode); end
Node = Node0(ix,:); 
for i=1:size(Element0,1)
  Element{i} = jx(Element0{i});
end
%-------------------------------------------------------------------------%