close all;
clear;
A=input('Tasiyici Genligini Giriniz (1-5 arasi): ');
Tasiyici Genligini Giriniz (1-5 arasi): 5
Fc=input('Tasiyici Frekansini Giriniz (10000-20000 arasi): ');	% hertz 
Tasiyici Frekansini Giriniz (10000-20000 arasi): 10000

Fs=8e3;%input('Ornekleme Frekansini Giriniz: ');
x =input('Kayit Suresini Giriniz (saniye, 5-10 arasi): ');
Kayit Suresini Giriniz (saniye, 5-10 arasi): 7
dt = 1/Fs;	% Ornekler arasi sure
StopTime = x;
t = (0:dt:StopTime-dt)'; 
N=size(t,1);
%% Mesaj Sinyalinin Kaydi 
recObj = audiorecorder(Fs,8,1);
disp('Kayit basladi, adinizi, soyadinizi ve öðrenci numaranizi soyleyiniz.') 
Kayit basladi, adinizi, soyadinizi ve öðrenci numaranizi soyleyiniz.
recordblocking(recObj, x);
disp('Kayit bitti.'); 
Kayit bitti.
Input_Signal=(getaudiodata(recObj))';
%% Sesi Kaydet
audiowrite('Ses.wav',Input_Signal,8000)
%% Zaman Alanýnda Ses 
figure; 
subplot(2,2,1); 
plot(t,Input_Signal);
title('Zaman Alanýnda Ses');
%% Frekans Alanýnda Ses 
datafftm=fft(Input_Signal); 
datafftm_abs=fftshift(abs:(datafftm/N)'); 
Error using abs
Not enough input arguments.
 
datafftm_abs=fftshift(abs(datafftm/N))'; 
f=Fs*(-N/2:N/2-1)/N;
subplot(2,2,2); 
plot(f,datafftm_abs) 
title('Frekans Alanýnda Ses');


%% Demodule Sinyali Kaydet 
audiowrite('Moduleli_Ses.wav',Modulated,8000)
Undefined function or variable 'Modulated'.
 
%% Alcak Geciren Filtre Tasarimi 
N_f	= 120;
Fs_f = 48e3;
Fp = 5000;	%%Kesim frekansý 
Ap = 0.01;
Ast = 80;
LP_FIR = dsp.LowpassFilter('SampleRate',Fs_f,... 
'DesignForMinimumOrder',false,'FilterOrder',N_f,... 
'PassbandFrequency',Fp,'PassbandRipple',Ap,'StopbandAttenuation',Ast); 
Undefined variable "dsp" or class "dsp.LowpassFilter".
 
NUM_LP = tf(LP_FIR);
Undefined function or variable 'LP_FIR'.
 
N   = 120;        
Fs  = 48e3;      
Fp  = 8e3;       
Ap  = 0.01;      
Ast = 80;
Rp  = (10^(Ap/20) - 1)/(10^(Ap/20) + 1); 
Rst = 10^(-Ast/20);
NUM = firceqrip(N,Fp/(Fs/2),[Rp Rst],'passedge');
fvtool(NUM,'Fs',Fs)

Fst     = 10e3;
NumMin = firgr('minorder',[0 Fp/(Fs/2) Fst/(Fs/2) 1], [1 1 0 0],[Rp,Rst]);
hvft = fvtool(NUM,1,NumMin,1,'Fs',Fs);
legend(hvft,'N = 120','N = 100')
LP_FIR = dsp.FIRFilter('Numerator',NUM);
SA     = dsp.SpectrumAnalyzer('SampleRate',Fs,'SpectralAverages',5);
tic
while toc < 10
x = randn(256,1);  
y = LP_FIR(x); 
  step(SA,y);
end
LP_FIR = dsp.LowpassFilter('SampleRate',Fs,...
'DesignForMinimumOrder',false,'FilterOrder',N,...
 'PassbandFrequency',Fp,'PassbandRipple',Ap,'StopbandAttenuation',Ast);
Undefined variable "dsp" or class "dsp.LowpassFilter".
 
NUM_LP = tf(LP_FIR);
fvtool(LP_FIR,'Fs',Fs);
%% Filtreyi Uygula 
filtreli_ses=filter(NUM_LP,1,Input_Signal);
%% Zaman Alanýnda Filtreli Ses 
len_y=length(filtreli_ses); 
subplot(2,2,3); 
plot(t,filtreli_ses);
title('Zaman Alanýnda Filtreli Ses');
%% Frekans Alanýnda Filtreli Ses 
datafftm=fft(filtreli_ses); 
datafftm_abs=fftshift(abs(datafftm/N)); 
f=Fs*(-N/2:N/2-1)/N;
subplot(2,2,4); 
plot(f,datafftm_abs)
Error using plot
Vectors must be the same lengths.
 
title('Frekans Alanýnda Filtreli Ses');
%% Filtreli Sesi Kaydet 
audiowrite('Filtreli_Ses.wav',filtreli_ses,8000)
%% Tasiyici Sinyal
Carrier = (A*cos(2*pi*Fc*t)');
%% Mesajin DSB-SC Modulasyonu 
Modulated = filtreli_ses.*Carrier;
%% Zaman Alanýnda Moduleli Sinyal 
figure;
subplot(2,2,1); 
plot(t,Modulated);
 

title('Zaman Alanýnda Moduljeli Sinyal');

%% Frekans Alanýnda Moduleli Sinyal 
datafftm=fft(Modulated); 
datafftm_abs=fftshift(abs(datafftm/N));
f=(-(Fc+Fs):2*(Fc+Fs)/N:(Fc+Fs)-(2*(Fc+Fs)/N));
if (length(f)~=length(datafftm_abs)) 
f=(-(Fc+Fs):2*(Fc+Fs)/N:(Fc+Fs));
end
subplot(2,2,2); 
plot(f,datafftm_abs);
Error using plot
Vectors must be the same lengths.
 
title('Frekans Alanýnda Moduleli Sinyal');
%% Demodule Sinyali Kaydet 
audiowrite('Moduleli_Ses.wav',Modulated,8000)
%% DSB-SC Moduleli Sinyalin Demodulasyonu
Demodulated = Modulated.*Carrier; 
filtreli_Demodulated=filter(NUM_LP,1,Demodulated);
%% Zaman Alanýnda Demodule Sinyal 
subplot(2,2,3); 
plot(t,filtreli_Demodulated); 
title('Zaman Alanýnda Demodule Sinyal');
%% Frekans Alanýnda Demodule Sinyal 
datafftm=fft(filtreli_Demodulated); 
datafftm_abs=fftshift(abs(datafftm/N)); 
f=Fs*(-N/2:N/2-1)/N;
subplot(2,2,4); 
plot(f,datafftm_abs)
Error using plot
Vectors must be the same lengths.
 
title('Frekans Alanýnda Demodule Sinyal');
%% Demodule Sinyali Kaydet 
audiowrite('Demodule_Ses.wav',filtreli_Demodulated,8000)
