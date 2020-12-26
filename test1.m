%runs comsol_model_improved as a test
format long;

%sensor locations (can be more than 4)

 
x=[0    0.5    0   -0.5    0.5;%x
   0.5  0    -0.5     0    0.5];%y


%location of the hole and radius
hole_radius=0.3;%0.15;
hole_loc_x=0;
hole_loc_y=0;

hole_loc_vec=[hole_loc_x; hole_loc_y;];




lph=10;
%freq in data
f=25000;
%pulse speed
c=3200;

pressure_threshold=0.5e8;
parameters=[f,c,pressure_threshold,lph,hole_radius,hole_loc_x,hole_loc_y];



lambda=c/f;%wavelength


%true damage location(random maybe)

%loc=0.8*[rand rand]'-0.4;%range=-0.4 to 0.4, 0.5 is too near to surface
loc=[-0.4 -0.1]';



comsol_model_improved1(loc,parameters,x);
