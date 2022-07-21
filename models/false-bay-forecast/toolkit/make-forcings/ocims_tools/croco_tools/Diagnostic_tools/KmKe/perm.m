function tmp = perm(tmp1)
% function tmp = perm(tmp1)
% size(a)
%     2     3     4
% size(perm(a))
%     4     3     2
%

I = length(size(tmp1)):-1:1;
tmp = squeeze(permute(tmp1,I));
