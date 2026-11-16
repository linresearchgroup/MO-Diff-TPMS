function [d] = BdryNodes(Node)
b = max(Node(:,1))-min(Node(:,1));
BdBox = [0 b 0 b 0 b];
eps =10*((BdBox(2)-BdBox(1))*(BdBox(4)-BdBox(3))*...
         (BdBox(6)-BdBox(5)))^(1/3)/size(Node,1);
        
% DEFINE NODES AT FACES
ABCD = find((abs(Node(:,3))<eps)&(abs(Node(:,1))>eps)&...
    (abs(Node(:,1))<b-eps)&(abs(Node(:,2))>eps)&...
    (abs(Node(:,2))<b-eps)); % Node IDs (XY PLANE, Z=0, interior nodes)

EFGH = find((abs(Node(:,3)-b)<eps)&(abs(Node(:,1))>eps)&...
    (abs(Node(:,1))<b-eps)&(abs(Node(:,2))>eps)&...
    (abs(Node(:,2))<b-eps)); % Node IDs (XY PLANE, Z=Lz, interior nodes)

EFBA = find((abs(Node(:,1))<eps)&(abs(Node(:,2))>eps)&...
    (abs(Node(:,2))<b-eps)&(abs(Node(:,3))>eps)&...
    (abs(Node(:,3))<b-eps)); % Node IDs (YZ PLANE, X=0, interior nodes)

HGCD = find((abs(Node(:,1)-b)<eps)&(abs(Node(:,2))>eps)&...
    (abs(Node(:,2))<b-eps)&(abs(Node(:,3))>eps)&...
    (abs(Node(:,3))<b-eps)); % Node IDs (YZ PLANE, X=Lx, interior nodes)

ADHE = find((abs(Node(:,2))<eps)&(abs(Node(:,1))>eps)&...
    (abs(Node(:,1))<b-eps)&(abs(Node(:,3))>eps)&...
    (abs(Node(:,3))<b-eps)); % Node IDs (XZ PLANE, Y=0, interior nodes)

BCGF = find((abs(Node(:,2)-b)<eps)&(abs(Node(:,1))>eps)&...
    (abs(Node(:,1))<b-eps)&(abs(Node(:,3))>eps)&...
    (abs(Node(:,3))<b-eps)); % Node IDs (XZ PLANE, Y=Ly, interior nodes)

% DEFINE NODES AT EDGES (EXCLUDING CORNERS)
AB = find((sqrt((Node(:,2)-0).^2+(Node(:,3)-0).^2)<eps)&...
    ((abs(Node(:,1))>eps)&(abs(Node(:,1))<b-eps)));
DC = find((sqrt((Node(:,2)-b).^2+(Node(:,3)-0).^2)<eps)&...
    ((abs(Node(:,1))>eps)&(abs(Node(:,1))<b-eps)));
EF = find((sqrt((Node(:,2)-0).^2+(Node(:,3)-b).^2)<eps)&...
    ((abs(Node(:,1))>eps)&(abs(Node(:,1))<b-eps)));
HG = find((sqrt((Node(:,2)-b).^2+(Node(:,3)-b).^2)<eps)&...
    ((abs(Node(:,1))>eps)&(abs(Node(:,1))<b-eps)));
AD = find((sqrt((Node(:,1)-0).^2+(Node(:,3)-0).^2)<eps)&...
    ((abs(Node(:,2))>eps)&(abs(Node(:,2))<b-eps)));
BC = find((sqrt((Node(:,1)-b).^2+(Node(:,3)-0).^2)<eps)&...
    ((abs(Node(:,2))>eps)&(abs(Node(:,2))<b-eps)));
EH = find((sqrt((Node(:,1)-0).^2+(Node(:,3)-b).^2)<eps)&...
    ((abs(Node(:,2))>eps)&(abs(Node(:,2))<b-eps)));
FG = find((sqrt((Node(:,1)-b).^2+(Node(:,3)-b).^2)<eps)&...
    ((abs(Node(:,2))>eps)&(abs(Node(:,2))<b-eps)));
AE = find((sqrt((Node(:,1)-0).^2+(Node(:,2)-0).^2)<eps)&...
    ((abs(Node(:,3))>eps)&(abs(Node(:,3))<b-eps)));
HD = find((sqrt((Node(:,1)-0).^2+(Node(:,2)-b).^2)<eps)&...
    ((abs(Node(:,3))>eps)&(abs(Node(:,3))<b-eps)));
FB = find((sqrt((Node(:,1)-b).^2+(Node(:,2)-0).^2)<eps)&...
    ((abs(Node(:,3))>eps)&(abs(Node(:,3))<b-eps)));
CG = find((sqrt((Node(:,1)-b).^2+(Node(:,2)-b).^2)<eps)&...
    ((abs(Node(:,3))>eps)&(abs(Node(:,3))<b-eps)));

% DEFINE NODES AT CORNERS
A = find(sqrt((Node(:,1)-0).^2+(Node(:,2)-0).^2+(Node(:,3)-0).^2)<eps);
B = find(sqrt((Node(:,1)-b).^2+(Node(:,2)-0).^2+(Node(:,3)-0).^2)<eps);
C = find(sqrt((Node(:,1)-b).^2+(Node(:,2)-b).^2+(Node(:,3)-0).^2)<eps);
D = find(sqrt((Node(:,1)-0).^2+(Node(:,2)-b).^2+(Node(:,3)-0).^2)<eps);
E = find(sqrt((Node(:,1)-0).^2+(Node(:,2)-0).^2+(Node(:,3)-b).^2)<eps);
F = find(sqrt((Node(:,1)-b).^2+(Node(:,2)-0).^2+(Node(:,3)-b).^2)<eps);
G = find(sqrt((Node(:,1)-b).^2+(Node(:,2)-b).^2+(Node(:,3)-b).^2)<eps);
H = find(sqrt((Node(:,1)-0).^2+(Node(:,2)-b).^2+(Node(:,3)-b).^2)<eps);

% DEOFS AT FACES
d1(1:3:3*length(EFBA(:)),1) = 3*EFBA(:)-2; d1(2:3:3*length(EFBA(:)),1) = 3*EFBA(:)-1; d1(3:3:3*length(EFBA(:)),1) = 3*EFBA(:);
d2(1:3:3*length(HGCD(:)),1) = 3*HGCD(:)-2; d2(2:3:3*length(HGCD(:)),1) = 3*HGCD(:)-1; d2(3:3:3*length(HGCD(:)),1) = 3*HGCD(:); 
d3(1:3:3*length(ADHE(:)),1) = 3*ADHE(:)-2; d3(2:3:3*length(ADHE(:)),1) = 3*ADHE(:)-1; d3(3:3:3*length(ADHE(:)),1) = 3*ADHE(:); 
d4(1:3:3*length(BCGF(:)),1) = 3*BCGF(:)-2; d4(2:3:3*length(BCGF(:)),1) = 3*BCGF(:)-1; d4(3:3:3*length(BCGF(:)),1) = 3*BCGF(:);
d5(1:3:3*length(ABCD(:)),1) = 3*ABCD(:)-2; d5(2:3:3*length(ABCD(:)),1) = 3*ABCD(:)-1; d5(3:3:3*length(ABCD(:)),1) = 3*ABCD(:); 
d6(1:3:3*length(EFGH(:)),1) = 3*EFGH(:)-2; d6(2:3:3*length(EFGH(:)),1) = 3*EFGH(:)-1; d6(3:3:3*length(EFGH(:)),1) = 3*EFGH(:); 

% DOFS AT EDGES
d7(1:3:3*length(AE(:)),1) = 3*AE(:)-2; d7(2:3:3*length(AE(:)),1) = 3*AE(:)-1; d7(3:3:3*length(AE(:)),1) = 3*AE(:);
d8(1:3:3*length(CG(:)),1) = 3*CG(:)-2; d8(2:3:3*length(CG(:)),1) = 3*CG(:)-1; d8(3:3:3*length(CG(:)),1) = 3*CG(:);
d9(1:3:3*length(AB(:)),1) = 3*AB(:)-2; d9(2:3:3*length(AB(:)),1) = 3*AB(:)-1; d9(3:3:3*length(AB(:)),1) = 3*AB(:); 
d10(1:3:3*length(HG(:)),1) = 3*HG(:)-2; d10(2:3:3*length(HG(:)),1) = 3*HG(:)-1; d10(3:3:3*length(HG(:)),1) = 3*HG(:); 
d11(1:3:3*length(AD(:)),1) = 3*AD(:)-2; d11(2:3:3*length(AD(:)),1) = 3*AD(:)-1; d11(3:3:3*length(AD(:)),1) = 3*AD(:); 
d12(1:3:3*length(FG(:)),1) = 3*FG(:)-2; d12(2:3:3*length(FG(:)),1) = 3*FG(:)-1; d12(3:3:3*length(FG(:)),1) = 3*FG(:); 
d13(1:3:3*length(FB(:)),1) = 3*FB(:)-2; d13(2:3:3*length(FB(:)),1) = 3*FB(:)-1; d13(3:3:3*length(FB(:)),1) = 3*FB(:); 
d14(1:3:3*length(HD(:)),1) = 3*HD(:)-2; d14(2:3:3*length(HD(:)),1) = 3*HD(:)-1; d14(3:3:3*length(HD(:)),1) = 3*HD(:); 
d15(1:3:3*length(EF(:)),1) = 3*EF(:)-2; d15(2:3:3*length(EF(:)),1) = 3*EF(:)-1; d15(3:3:3*length(EF(:)),1) = 3*EF(:); 
d16(1:3:3*length(DC(:)),1) = 3*DC(:)-2; d16(2:3:3*length(DC(:)),1) = 3*DC(:)-1; d16(3:3:3*length(DC(:)),1) = 3*DC(:); 
d17(1:3:3*length(EH(:)),1) = 3*EH(:)-2; d17(2:3:3*length(EH(:)),1) = 3*EH(:)-1; d17(3:3:3*length(EH(:)),1) = 3*EH(:); 
d18(1:3:3*length(BC(:)),1) = 3*BC(:)-2; d18(2:3:3*length(BC(:)),1) = 3*BC(:)-1; d18(3:3:3*length(BC(:)),1) = 3*BC(:); 

% DOFS AT VERTICES
d19(1:3:3*length(A),1) = 3*A-2; d19(2:3:3*length(A),1) = 3*A-1; d19(3:3:3*length(A),1) = 3*A; 
d20(1:3:3*length(B),1) = 3*B-2; d20(2:3:3*length(B),1) = 3*B-1; d20(3:3:3*length(B),1) = 3*B;
d21(1:3:3*length(C),1) = 3*C-2; d21(2:3:3*length(C),1) = 3*C-1; d21(3:3:3*length(C),1) = 3*C; 
d22(1:3:3*length(D),1) = 3*D-2; d22(2:3:3*length(D),1) = 3*D-1; d22(3:3:3*length(D),1) = 3*D; 
d23(1:3:3*length(E),1) = 3*E-2; d23(2:3:3*length(E),1) = 3*E-1; d23(3:3:3*length(E),1) = 3*E; 
d24(1:3:3*length(F),1) = 3*F-2; d24(2:3:3*length(F),1) = 3*F-1; d24(3:3:3*length(F),1) = 3*F; 
d25(1:3:3*length(G),1) = 3*G-2; d25(2:3:3*length(G),1) = 3*G-1; d25(3:3:3*length(G),1) = 3*G; 
d26(1:3:3*length(H),1) = 3*H-2; d26(2:3:3*length(H),1) = 3*H-1; d26(3:3:3*length(H),1) = 3*H; 

d{1} = [d1; d3; d5; d7; d9; d11; d13; d15; d17]; % DOF for odd di's
d{2} = [d2; d4; d6; d8; d10; d12; d14; d16; d18]; % DOF for even di's
d{3} = [d19; d20; d21; d22; d23; d24; d25; d26]; % DOF at vertices
d{4} = setdiff((1:3*size(Node,1))',[d{1};d{2};d{3}]); % DOF for rest of interior nodes



% function [d] = BdryNodes(Node)
% b = max(Node(:,1))-min(Node(:,1));
% BdBox = [0 b 0 b 0 b];
% eps =10*((BdBox(2)-BdBox(1))*...
%              (BdBox(4)-BdBox(3))*...
%              (BdBox(6)-BdBox(5)))^(1/3)/size(Node,1);
%         
% % DEFINE NODES AT FACES
% ABCD = find((abs(Node(:,3))<eps)&(abs(Node(:,1))>eps)&...
%     (abs(Node(:,1))<b-eps)&(abs(Node(:,2))>eps)&...
%     (abs(Node(:,2))<b-eps)); % Node IDs (XY PLANE, Z=0, interior nodes)
% 
% EFGH = find((abs(Node(:,3)-b)<eps)&(abs(Node(:,1))>eps)&...
%     (abs(Node(:,1))<b-eps)&(abs(Node(:,2))>eps)&...
%     (abs(Node(:,2))<b-eps)); % Node IDs (XY PLANE, Z=Lz, interior nodes)
% 
% EFBA = find((abs(Node(:,1))<eps)&(abs(Node(:,2))>eps)&...
%     (abs(Node(:,2))<b-eps)&(abs(Node(:,3))>eps)&...
%     (abs(Node(:,3))<b-eps)); % Node IDs (YZ PLANE, X=0, interior nodes)
% 
% HGCD = find((abs(Node(:,1)-b)<eps)&(abs(Node(:,2))>eps)&...
%     (abs(Node(:,2))<b-eps)&(abs(Node(:,3))>eps)&...
%     (abs(Node(:,3))<b-eps)); % Node IDs (YZ PLANE, X=Lx, interior nodes)
% 
% ADHE = find((abs(Node(:,2))<eps)&(abs(Node(:,1))>eps)&...
%     (abs(Node(:,1))<b-eps)&(abs(Node(:,3))>eps)&...
%     (abs(Node(:,3))<b-eps)); % Node IDs (XZ PLANE, Y=0, interior nodes)
% 
% BCGF = find((abs(Node(:,2)-b)<eps)&(abs(Node(:,1))>eps)&...
%     (abs(Node(:,1))<b-eps)&(abs(Node(:,3))>eps)&...
%     (abs(Node(:,3))<b-eps)); % Node IDs (XZ PLANE, Y=Ly, interior nodes)
% 
% % DEFINE NODES AT EDGES (EXCLUDING CORNERS)
% AB = find((sqrt((Node(:,2)-0).^2+(Node(:,3)-0).^2)<eps)&...
%     ((abs(Node(:,1))>eps)&(abs(Node(:,1))<b-eps)));
% DC = find((sqrt((Node(:,2)-b).^2+(Node(:,3)-0).^2)<eps)&...
%     ((abs(Node(:,1))>eps)&(abs(Node(:,1))<b-eps)));
% EF = find((sqrt((Node(:,2)-0).^2+(Node(:,3)-b).^2)<eps)&...
%     ((abs(Node(:,1))>eps)&(abs(Node(:,1))<b-eps)));
% HG = find((sqrt((Node(:,2)-b).^2+(Node(:,3)-b).^2)<eps)&...
%     ((abs(Node(:,1))>eps)&(abs(Node(:,1))<b-eps)));
% AD = find((sqrt((Node(:,1)-0).^2+(Node(:,3)-0).^2)<eps)&...
%     ((abs(Node(:,2))>eps)&(abs(Node(:,2))<b-eps)));
% BC = find((sqrt((Node(:,1)-b).^2+(Node(:,3)-0).^2)<eps)&...
%     ((abs(Node(:,2))>eps)&(abs(Node(:,2))<b-eps)));
% EH = find((sqrt((Node(:,1)-0).^2+(Node(:,3)-b).^2)<eps)&...
%     ((abs(Node(:,2))>eps)&(abs(Node(:,2))<b-eps)));
% FG = find((sqrt((Node(:,1)-b).^2+(Node(:,3)-b).^2)<eps)&...
%     ((abs(Node(:,2))>eps)&(abs(Node(:,2))<b-eps)));
% AE = find((sqrt((Node(:,1)-0).^2+(Node(:,2)-0).^2)<eps)&...
%     ((abs(Node(:,3))>eps)&(abs(Node(:,3))<b-eps)));
% HD = find((sqrt((Node(:,1)-0).^2+(Node(:,2)-b).^2)<eps)&...
%     ((abs(Node(:,3))>eps)&(abs(Node(:,3))<b-eps)));
% FB = find((sqrt((Node(:,1)-b).^2+(Node(:,2)-0).^2)<eps)&...
%     ((abs(Node(:,3))>eps)&(abs(Node(:,3))<b-eps)));
% CG = find((sqrt((Node(:,1)-b).^2+(Node(:,2)-b).^2)<eps)&...
%     ((abs(Node(:,3))>eps)&(abs(Node(:,3))<b-eps)));
% 
% % DEFINE NODES AT CORNERS
% A = find(sqrt((Node(:,1)-0).^2+(Node(:,2)-0).^2+(Node(:,3)-0).^2)<eps);
% B = find(sqrt((Node(:,1)-b).^2+(Node(:,2)-0).^2+(Node(:,3)-0).^2)<eps);
% C = find(sqrt((Node(:,1)-b).^2+(Node(:,2)-b).^2+(Node(:,3)-0).^2)<eps);
% D = find(sqrt((Node(:,1)-0).^2+(Node(:,2)-b).^2+(Node(:,3)-0).^2)<eps);
% E = find(sqrt((Node(:,1)-0).^2+(Node(:,2)-0).^2+(Node(:,3)-b).^2)<eps);
% F = find(sqrt((Node(:,1)-b).^2+(Node(:,2)-0).^2+(Node(:,3)-b).^2)<eps);
% G = find(sqrt((Node(:,1)-b).^2+(Node(:,2)-b).^2+(Node(:,3)-b).^2)<eps);
% H = find(sqrt((Node(:,1)-0).^2+(Node(:,2)-b).^2+(Node(:,3)-b).^2)<eps);
% 
% % DEOFS AT FACES
% d1(1:3:3*length(EFBA(:)),1) = 3*EFBA(:)-2; d1(2:3:3*length(EFBA(:)),1) = 3*EFBA(:)-1; d1(3:3:3*length(EFBA(:)),1) = 3*EFBA(:);
% d2(1:3:3*length(HGCD(:)),1) = 3*HGCD(:)-2; d2(2:3:3*length(HGCD(:)),1) = 3*HGCD(:)-1; d2(3:3:3*length(HGCD(:)),1) = 3*HGCD(:); 
% d3(1:3:3*length(ADHE(:)),1) = 3*ADHE(:)-2; d3(2:3:3*length(ADHE(:)),1) = 3*ADHE(:)-1; d3(3:3:3*length(ADHE(:)),1) = 3*ADHE(:); 
% d4(1:3:3*length(BCGF(:)),1) = 3*BCGF(:)-2; d4(2:3:3*length(BCGF(:)),1) = 3*BCGF(:)-1; d4(3:3:3*length(BCGF(:)),1) = 3*BCGF(:);
% d5(1:3:3*length(ABCD(:)),1) = 3*ABCD(:)-2; d5(2:3:3*length(ABCD(:)),1) = 3*ABCD(:)-1; d5(3:3:3*length(ABCD(:)),1) = 3*ABCD(:); 
% d6(1:3:3*length(EFGH(:)),1) = 3*EFGH(:)-2; d6(2:3:3*length(EFGH(:)),1) = 3*EFGH(:)-1; d6(3:3:3*length(EFGH(:)),1) = 3*EFGH(:); 
% 
% % DOFS AT EDGES
% d7(1:3:3*length(AE(:)),1) = 3*AE(:)-2; d7(2:3:3*length(AE(:)),1) = 3*AE(:)-1; d7(3:3:3*length(AE(:)),1) = 3*AE(:);
% d8(1:3:3*length(CG(:)),1) = 3*CG(:)-2; d8(2:3:3*length(CG(:)),1) = 3*CG(:)-1; d8(3:3:3*length(CG(:)),1) = 3*CG(:);
% d9(1:3:3*length(AB(:)),1) = 3*AB(:)-2; d9(2:3:3*length(AB(:)),1) = 3*AB(:)-1; d9(3:3:3*length(AB(:)),1) = 3*AB(:); 
% d10(1:3:3*length(HG(:)),1) = 3*HG(:)-2; d10(2:3:3*length(HG(:)),1) = 3*HG(:)-1; d10(3:3:3*length(HG(:)),1) = 3*HG(:); 
% d11(1:3:3*length(AD(:)),1) = 3*AD(:)-2; d11(2:3:3*length(AD(:)),1) = 3*AD(:)-1; d11(3:3:3*length(AD(:)),1) = 3*AD(:); 
% d12(1:3:3*length(FG(:)),1) = 3*FG(:)-2; d12(2:3:3*length(FG(:)),1) = 3*FG(:)-1; d12(3:3:3*length(FG(:)),1) = 3*FG(:); 
% d13(1:3:3*length(FB(:)),1) = 3*FB(:)-2; d13(2:3:3*length(FB(:)),1) = 3*FB(:)-1; d13(3:3:3*length(FB(:)),1) = 3*FB(:); 
% d14(1:3:3*length(HD(:)),1) = 3*HD(:)-2; d14(2:3:3*length(HD(:)),1) = 3*HD(:)-1; d14(3:3:3*length(HD(:)),1) = 3*HD(:); 
% d15(1:3:3*length(EF(:)),1) = 3*EF(:)-2; d15(2:3:3*length(EF(:)),1) = 3*EF(:)-1; d15(3:3:3*length(EF(:)),1) = 3*EF(:); 
% d16(1:3:3*length(DC(:)),1) = 3*DC(:)-2; d16(2:3:3*length(DC(:)),1) = 3*DC(:)-1; d16(3:3:3*length(DC(:)),1) = 3*DC(:); 
% d17(1:3:3*length(EH(:)),1) = 3*EH(:)-2; d17(2:3:3*length(EH(:)),1) = 3*EH(:)-1; d17(3:3:3*length(EH(:)),1) = 3*EH(:); 
% d18(1:3:3*length(BC(:)),1) = 3*BC(:)-2; d18(2:3:3*length(BC(:)),1) = 3*BC(:)-1; d18(3:3:3*length(BC(:)),1) = 3*BC(:); 
% 
% % DOFS AT VERTICES
% d19(1:3:3*length(A),1) = 3*A-2; d19(2:3:3*length(A),1) = 3*A-1; d19(3:3:3*length(A),1) = 3*A; 
% d20(1:3:3*length(B),1) = 3*B-2; d20(2:3:3*length(B),1) = 3*B-1; d20(3:3:3*length(B),1) = 3*B;
% d21(1:3:3*length(C),1) = 3*C-2; d21(2:3:3*length(C),1) = 3*C-1; d21(3:3:3*length(C),1) = 3*C; 
% d22(1:3:3*length(D),1) = 3*D-2; d22(2:3:3*length(D),1) = 3*D-1; d22(3:3:3*length(D),1) = 3*D; 
% d23(1:3:3*length(E),1) = 3*E-2; d23(2:3:3*length(E),1) = 3*E-1; d23(3:3:3*length(E),1) = 3*E; 
% d24(1:3:3*length(F),1) = 3*F-2; d24(2:3:3*length(F),1) = 3*F-1; d24(3:3:3*length(F),1) = 3*F; 
% d25(1:3:3*length(G),1) = 3*G-2; d25(2:3:3*length(G),1) = 3*G-1; d25(3:3:3*length(G),1) = 3*G; 
% d26(1:3:3*length(H),1) = 3*H-2; d26(2:3:3*length(H),1) = 3*H-1; d26(3:3:3*length(H),1) = 3*H; 
% 
% d{1} = [d1; d3; d5; d7; d9; d11; d13; d15; d17]; % DOF for odd di's
% d{2} = [d2; d4; d6; d8; d10; d12; d14; d16; d18]; % DOF for even di's
% d{3} = [d19; d20; d21; d22; d23; d24; d25; d26]; % DOF at vertices
% d{4} = setdiff((1:3*size(Node,1))',[d{1};d{2};d{3}]); % DOF for rest of interior nodes