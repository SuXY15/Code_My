% setting
clear;close all;
m=100; n=100; p=.5; iter=1e3;

% init
a=zeros(m+2,n+2);
a(2:m+1,2:n+1)=rand(m,n);
a(a>p)=1; a(a<1)=0;

% loop
for k=1:iter
    c=a;
    for x=2:m+1
    for y=2:n+1
        t=sum(sum(c([x-1,x,x+1],[y-1,y,y+1])))-c(x,y);
        a(x,y)=(t==2)*c(x,y)+(t==3);
    end
    end
    imshow(a,'InitialMagnification','fit'); pause(1e-6)
end