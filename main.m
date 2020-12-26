%calculates failure location in concrete structure with internal circ void
%uses perturbation+gauss-newton numerical algorithms



%sensor locations (any amount,but more the better and too much is too much)

 


 x=[  0    0.5       0   -0.5    0.5    -0.5   -0.5    0.5;%x
    0.5      0    -0.5      0    0.5    -0.5    0.5   -0.5];%y
  

%location of the hole and radius
hole_radius=0.23;%0.15;
hole_loc_x=0;
hole_loc_y=0.1;

hole_loc_vec=[hole_loc_x; hole_loc_y;];

%grid constant for calculating contours
gridc=3;



%iterations
k=5;



lph=10;%element per wavelenght
%freq in data
f=25000;
%pulse speed
c=3200;
%model 3=circle off system
pressure_threshold=0.5e8;%pressure where signal is registered
parameters=[f,c,pressure_threshold,lph,hole_radius,hole_loc_x,hole_loc_y];



lambda=c/f;%wavelength


%true damage location(random maybe)

%loc=0.8*[rand rand]'-0.4;%range=-0.4 to 0.4, 0.5 is too near to surface
loc=[-0.4 -0.1]';




%get z i.e data from sensors
z=getz(loc,parameters,x);


%lph->6 and f->10000 to prevent inverse crime, update parameters
lph=6;
%freq in inversion
f=25000;
parameters=[f,c,pressure_threshold,lph,hole_radius,hole_loc_x,hole_loc_y];
%step lenght
alpha=1;
%perturbation epsilon=a*lambda+b
epsa=0;%1/6;%0.1
epsb=0.065;%0.125
eps=epsa*lambda+epsb;
%breaking constant
s=0.5;

history_of_iterations=zeros(2,k);



NN=size(x);%amoutn of sensors
NN=NN(2);
n=[0.4 0.4]';%initial guess to algorithm


  
J1=zeros(NN,1);
J2=zeros(NN,1);

fig1=figure;
%fig2=figure;


figure(fig1);



t = linspace(0,2*pi);
plot(hole_loc_x+hole_radius*cos(t),hole_loc_y+hole_radius*sin(t),'color','black') 
hold on




scatter(loc(1),loc(2),'red')
axis([-0.5 0.5 -0.5 0.5 ])
hold on 
drawnow







    h=zeros(NN,1);

A=linspace(-0.45,0.45,gridc);    
 B=linspace(-0.45,0.45,gridc);       
  [A,B]=meshgrid(A,B);  
    C=zeros(gridc,gridc);
    
    
%%%build meshgrid C
for ix=1:gridc
    for iy=1:gridc
        nn1=[A(ix,iy) B(ix,iy)]';

        if (norm(nn1-hole_loc_vec)<hole_radius )
            C(ix,iy)=NaN;%NaN if inside void
        else

            figure(fig1);


            scatter(nn1(1),nn1(2),2,'blue')
            drawnow
            hold on


            h=getz(nn1,parameters,x);
            fun=norm(z-h);
            C(ix,iy)=fun;

        end

    end
end

figure(fig1);

contour(A,B,C)
colorbar

hold on

scatter(loc(1),loc(2),'red')
drawnow















for index=1:k


%update h

h=getz(n,parameters,x);
%check if forward or backward difference due limitations

varx=1;
vary=1;

%perturbation
nx=n+varx*[eps; 0];
ny=n+vary*[0; eps];
    
hx=getz(nx,parameters,x);
hy=getz(ny,parameters,x);




%update J (jacobian)
J=[varx*(hx-h)/eps    varx*(hy-h)/eps ];




%G-N iteration step
lastn=n;%remember last position

% n=n+alpha*pinv(J)*(z-h);
step=pinv(J)*(z-h);


%this cond does not accept too small step at beginning
if norm(step)<2*(eps/k) 
    step=eps*[rand rand]';
end

%update location
n=n+step; 






%geometrical limitations goes here

%angle relative to center of void
phi=angle((-hole_loc_x+n(1))+((-hole_loc_y+n(2))*1i));

%if going too near void, push away
if norm(n-hole_loc_vec)<hole_radius+eps/2
    n(1)=hole_loc_vec(1)+(hole_radius+eps*2)*cos(phi+2*pi*20/360);
    n(2)=hole_loc_vec(2)+(hole_radius+eps*2)*sin(phi+2*pi*20/360);
end

%if too near edges    
if n(1)>0.5-eps/2 
    n(1)=0.5-eps*2;
end   
    
    
if n(2)>0.5-eps/2 
    n(2)=0.5-eps*2;
end   

if n(1)<-0.5+eps/2 
    n(1)=-0.5+eps*2;
end   

if n(2)<-0.5+eps/2 
    n(2)=-0.5+eps*2;
end  
    
    










history_of_iterations(:,index)=n;
figure(fig1);
line([n(1) lastn(1)], [n(2) lastn(2)],'Color','green')
hold on
drawnow


end

 

scatter(n(1),n(2),[],'green')

axis([-0.5 0.5 -0.5 0.5 ])
hold on



xlabel('x [m]');
ylabel('y [m]');

titlestr=strcat('Location by algorithm:(',num2str(n(1)),';', num2str(n(2)),')');


titlestr=strcat(titlestr,' Location by grid:(',num2str(A(C==min(min(C)))),';',num2str(B(C==min(min(C)))) ,')');
title(titlestr);
