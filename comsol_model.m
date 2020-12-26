function comsol_model(loc,parameters,x)

%outputs sensor data as csv files
%loc=fault location, x=sensor locations
size_of_x=size(x);
f=num2str(parameters(1));%frequncy
c=num2str(parameters(2));%speed of sound in concrete

lph = parameters(4); % elements per wavelength

%internal void parameters (2string as comsol wants):
hole_radius=num2str(parameters(5));
hole_loc_x=num2str(parameters(6));
hole_loc_y=num2str(parameters(7));

%fault location
fault_x=num2str(loc(1));
fault_y=num2str(loc(2));

matlab_path_string=pwd;





%
% comsol_model_aftertest.m
%
% Model exported on Dec 25 2020, 20:22 by COMSOL 5.1.0.234.

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath(matlab_path_string);

model.label('testrun2.mph');

model.comments('Concrete block with void');

model.modelNode.create('comp1');

model.file.clear;

model.geom.create('geom1', 2);

model.mesh.create('mesh1', 'geom1');

model.geom('geom1').create('sq1', 'Square');
model.geom('geom1').feature('sq1').set('pos', {'-0.5' '-0.5'});


model.geom('geom1').create('c1', 'Circle');
model.geom('geom1').feature('c1').set('r', hole_radius);
model.geom('geom1').feature('c1').set('pos', {hole_loc_x hole_loc_y});
model.geom('geom1').create('dif1', 'Difference');
model.geom('geom1').feature('dif1').selection('input').set({'sq1'});
model.geom('geom1').feature('dif1').selection('input2').set({'c1'});

model.geom('geom1').create('pt1', 'Point');
model.geom('geom1').feature('pt1').setIndex('p', fault_x, 0, 0);
model.geom('geom1').feature('pt1').setIndex('p', fault_y, 1, 0);
model.geom('geom1').run;
model.geom('geom1').run('fin');

model.material.create('mat1', 'Common', 'comp1');
model.material('mat1').propertyGroup.create('Enu', 'Young''s modulus and Poisson''s ratio');

model.physics.create('actd', 'TransientPressureAcoustics', 'geom1');
model.physics('actd').create('mls1', 'TransientMonopoleLineSource', 0);
model.physics('actd').feature('mls1').selection.set([3]);



for i=1:size_of_x(2)
    domstring=strcat('pdom',num2str(i));
    model.probe.create(domstring, 'DomainPoint');
    model.probe(domstring).model('comp1');
end






model.view('view1').axis.set('abstractviewxscale', '0.0033112582750618458');
model.view('view1').axis.set('ymin', '-0.831125795841217');
model.view('view1').axis.set('xmax', '0.7682119011878967');
model.view('view1').axis.set('abstractviewyscale', '0.0033112585078924894');
model.view('view1').axis.set('abstractviewbratio', '-0.46523183584213257');
model.view('view1').axis.set('abstractviewtratio', '0.46523183584213257');
model.view('view1').axis.set('abstractviewrratio', '0.862582802772522');
model.view('view1').axis.set('xmin', '-0.7682119011878967');
model.view('view1').axis.set('abstractviewlratio', '-0.862582802772522');
model.view('view1').axis.set('ymax', '0.831125795841217');

model.material('mat1').label('Concrete');
model.material('mat1').set('family', 'concrete');
model.material('mat1').propertyGroup('def').set('thermalexpansioncoefficient', {'10e-6[1/K]' '0' '0' '0' '10e-6[1/K]' '0' '0' '0' '10e-6[1/K]'});
model.material('mat1').propertyGroup('def').set('density', '2300[kg/m^3]');
model.material('mat1').propertyGroup('def').set('thermalconductivity', {'1.8[W/(m*K)]' '0' '0' '0' '1.8[W/(m*K)]' '0' '0' '0' '1.8[W/(m*K)]'});
model.material('mat1').propertyGroup('def').set('heatcapacity', '880[J/(kg*K)]');


model.material('mat1').propertyGroup('def').set('soundspeed', c);
model.material('mat1').propertyGroup('Enu').set('youngsmodulus', '25e9[Pa]');
model.material('mat1').propertyGroup('Enu').set('poissonsratio', '0.33');

model.physics('actd').feature('mls1').set('Type', 'GaussianPulse');
model.physics('actd').feature('mls1').set('AperLength', '10');


model.physics('actd').feature('mls1').set('f0', f);
model.physics('actd').feature('mls1').set('tp', '0.0012[s]');

model.mesh('mesh1').run;



for i=1:size_of_x(2)
    domstring=strcat('pdom',num2str(i));
    pstring=strcat('ppb',num2str(i));
    x_string=num2str(x(1,i));
    y_string=num2str(x(2,i));
    model.probe(domstring).setIndex('coords2', x_string, 0, 0);
    model.probe(domstring).setIndex('coords2', y_string, 0, 1);
    model.probe(domstring).feature(pstring).set('window', 'window1');
    
end






model.study.create('std1');
model.study('std1').create('time', 'Transient');

model.sol.create('sol1');
model.sol('sol1').study('std1');
model.sol('sol1').attach('std1');
model.sol('sol1').create('st1', 'StudyStep');
model.sol('sol1').create('v1', 'Variables');
model.sol('sol1').create('t1', 'Time');
model.sol('sol1').feature('t1').create('fc1', 'FullyCoupled');
model.sol('sol1').feature('t1').feature.remove('fcDef');

model.study('std1').feature('time').set('initstudyhide', 'on');
model.study('std1').feature('time').set('initsolhide', 'on');
model.study('std1').feature('time').set('solnumhide', 'on');
model.study('std1').feature('time').set('notstudyhide', 'on');
model.study('std1').feature('time').set('notsolhide', 'on');
model.study('std1').feature('time').set('notsolnumhide', 'on');



for i=2:size_of_x(2)
    solstring=strcat('sol',num2str(i));
    model.sol.create(solstring);
    model.sol(solstring).study('std1');
end




for i=1:size_of_x(2)
    datastring=strcat('dset',num2str(i));
    model.result.dataset.remove(datastring);
end




for i=1:size_of_x(2)
    domstring=strcat('pdom',num2str(i));
    model.probe(domstring).genResult([]);
end




model.study('std1').feature('time').set('tlist', 'range(0,0.0001,0.002)');

model.sol('sol1').attach('std1');
model.sol('sol1').feature('t1').set('timemethod', 'genalpha');
model.sol('sol1').feature('t1').set('tlist', 'range(0,0.0001,0.002)');
model.sol('sol1').runAll;




for i=2:size_of_x(2)
    solstring=strcat('sol',num2str(i));
    parstring=strcat('Parametric Solutions',num2str(i-1));
    model.sol(solstring).label(parstring);
end



model.result.dataset.remove('dset1');
model.result.remove('pg1');
model.result.dataset.create('dset1', 'Solution');
model.result.dataset('dset1').set('solution', 'sol1');
model.result.create('pg1', 'PlotGroup2D');
model.result('pg1').label('Acoustic Pressure (actd)');
model.result('pg1').set('oldanalysistype', 'noneavailable');
model.result('pg1').set('solvertype', 'none');
model.result('pg1').set('solnum', 1);
model.result('pg1').set('showlooplevel', {'off' 'off' 'off'});
model.result('pg1').set('oldanalysistype', 'noneavailable');
model.result('pg1').set('data', 'dset1');
model.result('pg1').feature.create('surf1', 'Surface');
model.result('pg1').feature('surf1').set('oldanalysistype', 'noneavailable');
model.result('pg1').feature('surf1').set('solvertype', 'none');
model.result('pg1').feature('surf1').set('data', 'parent');



for i=1:size_of_x(2)
    domstring=strcat('pdom',num2str(i));
    model.probe(domstring).genResult('none');
end



model.sol('sol1').runAll;

model.result('pg1').run;

result_path=strcat(pwd,'\probedata.csv');

model.result.table('tbl1').save(result_path);

%use following two commands to get .mph (regular comsol) file of system
%model_path=strcat(pwd,'\physicalmodel.mph');
%model.save(model_path)


