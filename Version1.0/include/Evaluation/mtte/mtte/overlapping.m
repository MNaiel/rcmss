function valOverlap = overlapping(estBbox,gtBbox)
%Input:
%   - rect1 and rect2 = [Xtopleft,Ytopleft,Xbottomright,Ybottomright]

rect1 = [estBbox(1:2) estBbox(1:2)+estBbox(3:4)];
rect2 = [gtBbox(1:2) gtBbox(1:2)+gtBbox(3:4)];

%Calculate the coordinates of the overlapping
x1 = max(rect1(1),rect2(1));
y1 = max(rect1(2),rect2(2));
x2 = min(rect1(3),rect2(3));
y2 = min(rect1(4),rect2(4));

%are they overlapping?
if (x1 <= x2) && (y1 <= y2)
    valOverlap = (x2-x1)*(y2-y1);    
else
    valOverlap = 0.0;
end

valOverlap = valOverlap/(estBbox(3)*estBbox(4)+gtBbox(3)*gtBbox(4)-valOverlap);