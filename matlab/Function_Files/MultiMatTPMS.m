function z = MultiMatTPMS(t1,t2,ElemCtrd,NMat,b)
ElemCtrd = ElemCtrd - [b/2,b/2,b/2];
NElem = size(ElemCtrd,1); all = (1:NElem)';
z = ones(NElem,NMat);

d1 = SchwarzP(ElemCtrd,t1);
d2 = SchwarzP(ElemCtrd,t2);
d = dDiff(d2,d1);

idx1 = find(d1<0); idx2 = find(d<0); idx3 = setdiff(all,[idx1;idx2]);
z(idx1,1) = 1; z(idx1,[2,3]) = 0; % Phase 1 = SchwarzP 1
z(idx2,2) = 1; z(idx2,[1,3]) = 0; % Phase 2 = Between SchwarzP 1 and SchwarzP 2
z(idx3,3) = 1; z(idx3,[1,2]) = 0; % Phase 3 = Rest of space

% X = ElemCtrd(:,1); Y = ElemCtrd(:,2); Z = ElemCtrd(:,3);
% figure; plot3(X,Y,Z,'k.',X(idx1),Y(idx1),Z(idx1),'r.'); axis equal
% figure; plot3(X,Y,Z,'k.',X(idx2),Y(idx2),Z(idx2),'g.'); axis equal
% figure; plot3(X,Y,Z,'k.',X(idx3),Y(idx3),Z(idx3),'b.'); axis equal

function d = SchwarzP(ElemCtrd,t)
x = ElemCtrd(:,1); y = ElemCtrd(:,2); z = ElemCtrd(:,3);
d = -(cos(x) + cos(y) + cos(z) + t);