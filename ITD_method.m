function [Fre,d] = ITD_method(N1,move,dt,F)

m = move;
Y = N1(1:end-2*m);
YT = N1(1+m:end-m);
YH = N1(1+2*m:end);
U = [Y;YT]; V = [YT;YH];
ev = eig(V*U'*inv(U*U'));
alpha = 1/(2*m*dt)*log((real(ev).^2)+(imag(ev).^2)); 
theta = 2*pi*m*dt/(1/F);
while(1)
    if theta > 2*pi
        theta = theta-2*pi;
    elseif  theta < 0
         theta = theta+2*pi;
    end
    if theta <= 2*pi && theta >= 0, break, end
end
if theta < pi 
    b = abs(imag(ev(1)));
    beta = 1/(m*dt)*atan(b/real(ev(1)));
else
    b = -abs(imag(ev(1)));
    beta = 1/(m*dt)*atan(b/real(ev(1)));
end

wo = sqrt((alpha(1)^2)+beta^2); Fre = wo/(2*pi);
d = -alpha(1)/wo*100;