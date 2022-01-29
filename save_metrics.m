%% Analysis 4: call filtBankRespir with N = 251

N=251;
Nb = 101; 
Nmu1 = 101;
Navg = 21;
Fs = fs_d;

for v = 1:nDir
    dir = directions{v};
    data_chest = nldat_chest_ACCEL.dataSet;
    Z_chest = data_chest(:,v);
    data_abd = nldat_abd_ACCEL.dataSet;
    Z_abd = data_abd(:,v);

    [stat.TotPWR_RR.(dir),stat.TotPWR_MV_A.(dir),stat.MaxPWR_MV_A.(dir),stat.MaxPWR_RR_A.(dir),stat.FMAX_A.(dir),stat.FMAXi_A.(dir)] = filtBankRespir(Z_chest,N,Fs);
    [stat.TotPWR_RR_C.(dir),stat.TotPWR_MV_C.(dir),stat.MaxPWR_MV_C.(dir),stat.MaxPWR_RR_C.(dir),stat.FMAX_C.(dir),stat.FMAXi_C.(dir)] = filtBankRespir(Z_abd,N,Fs);

    [stat.PHI.(dir),stat.FMAXi_ABD.(dir)] = asynchStat(Z_chest,Z_abd,N,Fs);

    [stat.BRC.(dir),stat.BAB.(dir),stat.BSU.(dir),stat.BDI.(dir),stat.BPH.(dir)] = breathStat(Z_chest,Z_abd,Nb,Nmu1,Navg,Fs);

end

save([savepath 'features_stats'], stat)



