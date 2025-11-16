function y = A_ReadVelocityASCII_Data(filename,pathname)
work_ori = cd;
cd(pathname);
fid=fopen(filename, 'r'); 
 open = 1; kk = 0;
while open == 1 
    kk = kk + 1;
    fgets(fid);
    if kk >= 8 %%%資料讀檔起始點
         y = fscanf(fid,'%f');
         open = 0;
         
    end    
end 
fclose(fid);
cd(work_ori)