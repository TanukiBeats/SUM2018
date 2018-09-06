--Link1--
%chk=molecule
#HF/6-31G* SCF=tight Test Pop=MK iop(6/33=2) NoSymm iop(6/42=6) opt

remark line goes here

-1   1
    B     -0.0000         -0.0000          0.0000     
    F     -0.2750         -1.0610         -0.9550     
    F     -0.6250          1.2330         -0.4520     
    F      1.4370          0.1960          0.1070     
    F     -0.5370         -0.3670          1.3000     

