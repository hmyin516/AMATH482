clear; close all; clc;
load Testdata
L=15; % spatial domain
n=64; % Fourier modes
x2=linspace(-L,L,n+1); 
x=x2(1:n); y=x; z=x;
k=(2*pi/(2*L))*[0:(n/2-1) -n/2:-1]; ks=fftshift(k);

[X,Y,Z]=meshgrid(x,y,z);
[Kx,Ky,Kz]=meshgrid(ks,ks,ks); %shifted

%%
%plotting
%data at time t = 10
for j= 10
    Un(:,:,:)=reshape(Undata(j,:),n,n,n);
    close all, isosurface(X,Y,Z,abs(Un),0.4)
    title("Raw Ultrasound Data");
    xlabel("x");ylabel("y");zlabel("z");
    axis([-20 20 -20 20 -20 20]), grid on, drawnow
    pause(0.1)
end

%%
%part 1
%averaging of spectrum to determine  center frequency generated by marble
figure(1)
ave = zeros(64,64,64);
for i = 1:20
     Un(:,:,:)=reshape(Undata(i,:),n,n,n);
     utn = fftn(Un);
     ave = ave + utn;
end

%plots, figure 1-3 corresponds to different isovalues
figure(1)
ave = abs(fftshift(ave))/20;
maxAve = max(max(max(abs(ave))));
close all, isosurface(Kx,Ky,Kz,ave/maxAve,0.4)
title("Data Averaged Over 20 Times in the Frequency Domain: Isovalue = 0.4")
figure(2)
isosurface(Kx,Ky,Kz,ave/maxAve,0.5)
title("Data Averaged Over 20 Times in the Frequency Domain: Isovalue = 0.5")
figure(3)
isosurface(Kx,Ky,Kz,ave/maxAve,0.6)
title("Data Averaged Over 20 Times in the Frequency Domain: Isovalue = 0.6");
clear xlabel; clear ylabel; clear zlabel;
xlabel("Kx");ylabel("Ky");zlabel("Kz");
    
    
%note particular big spot in the back -> center frequency of marble

%Finding Coordinates of Maximum Signal
[xs,ys,zs] = ind2sub([n,n,n], find(ave == maxAve));
maxK = [Kx(xs,ys,zs), Ky(xs,ys,zs), Kz(xs,ys,zs)]; %coordinates of max signal
%%
%part 2
%filtering data around center frequency to denoise using Gaussian filter 
%and get path
[kx,ky,kz] = meshgrid(k,k,k); %unshifted for plotting
marble = zeros(20,3); %create array of zeroes to store marble coordinate at differnent time periods
tau = 0.4;
k1 = maxK(1);
k2 = maxK(2);
k3 = maxK(3);
filter = exp(-tau*((kx - k1).^2+(ky-k2).^2+(kz-k3).^2)); %define gaussian filter function

for m = 1:20
    Un(:,:,:)=reshape(Undata(m,:),n,n,n); %3d matrix of raw data
    utn = fftn(Un); %fft of raw data
    unft = utn.*filter; %apply filter to transformed data
    unf = (ifftn(unft)); %return filtered data to spatial domain
    maxunf = max(max(max(abs(unf))));    %max of filtered data of each time
    [xm,ym,zm] = ind2sub([n,n,n], find(abs(unf) == maxunf));    %coordinates of marble center at differnet times
    marble(m,:) = [X(xm,ym,zm), Y(xm,ym,zm), Z(xm,ym,zm)];
end

%plotting marble trajectory
figure(4)
plot3(marble(:,1), marble(:,2), marble(:,3), '.--','MarkerSize',30)
xlim([-L,L]);ylim([-L,L]);zlim([-L,L]);
title("Tracjetory of a Marble over 20 Time Period");
xlabel("x");ylabel("y");zlabel("z");

%%
%part3
acoustic = marble(end,:) %coresponds to -5.625, 4.2118, -6.0938


