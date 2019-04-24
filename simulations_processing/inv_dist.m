function dist_inv=inv_dist(dist)
dist_inv = zeros(size(dist));
for i=1:size(dist,1)
    for j=1:size(dist,2)
        if dist(i,j)~=0
            dist_inv(i,j) = 1/dist(i,j);
        end
    end
end