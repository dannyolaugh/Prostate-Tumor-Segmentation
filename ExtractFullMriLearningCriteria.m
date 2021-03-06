%this file extracts, stores, and labels patches of pixel intensity values 
%the patch intensity values are stored in patches_array
%their corresponding labels are stored in observed_response array
%only uses THREE labels: TUMOR, HEALTHY PROSTATE, or BACKGROUND (1, 0, or 6)
%this was run on entire MRI images

load('/Users/danolaughlin/Downloads/registered2b.mat');

patches_array = [];
observed_response = [];

for k=0:6  %loop determines from how many images you want to gather data from (only had 7 good ones)  

    if (k == 0)
        data_val = 1;
    elseif (k == 1)
        data_val = 16;
    elseif (k == 2)
        data_val = 19;
    elseif (k == 3)
        data_val = 20;
    elseif (k == 4)
        data_val = 34;
    elseif (k == 5)
        data_val = 37;
    elseif (k == 6)
        data_val = 46;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%Prostate Tumor Sample%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tumor_array = zeros(100, 2);
    index = 1;
    sout = zeros(256, 256);
   
    for j=1:1:size(data(data_val).slide_roi,1)
        for i=1:1:size(data(data_val).slide_roi,1)
            if (data(data_val).slide_roi(i,j) > 1.99) 
                sout(i,j) = 1;     
                new=[j i];   %col, row
                tumor_array(index,:)=new;
                index = index+1;   
            else
                sout(i,j) = 0;
            end
        end
    end

    
    %takes 100 random samples from the tumor_array
    tumor_sample = datasample(tumor_array,100,1,'Replace',false); 
    %fprintf('Displaying contents of tumor_sample: \n');
    %disp(tumor_sample);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%Normal Prostate Sample%%%%%%%%%%%%%%%%%%%%%%%%%
    healthy_prostate_array = zeros(100, 2);
    index = 1;
    sout2 = zeros(256, 256);
   
    for j=1:1:size(data(data_val).slide_roi,1)
        for i=1:1:size(data(data_val).slide_roi,1)
            if ((data(data_val).slide_roi(i,j) > 0.99) && (data(data_val).slide_roi(i,j) < 1.01)) 
                sout2(i,j) = 1;     
                new=[j i];   %col, row
                healthy_prostate_array(index,:)=new;
                index = index+1;   
            else
                sout2(i,j) = 0;
            end
        end
    end

    healthy_prostate_sample = datasample(healthy_prostate_array,100,1,'Replace',false);
    
    for i=1:100
        sub1 = healthy_prostate_sample(i, 1); %num along xaxis(col) 
        sub2 = healthy_prostate_sample(i, 2); %num along yaxis(row)
        display(data(data_val).slide_roi(sub2, sub1)); %i had to switch sub1, sub2: takes in row(y) col(x)
    end;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%BackGround Sample%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    background_array = zeros(100, 2);
    index = 1;
    sout3 = zeros(256, 256);
   
    for j=1:1:size(data(data_val).slide_roi,1)
        for i=1:1:size(data(data_val).slide_roi,1)
            if ((data(data_val).slide_roi(i,j) < 0.10) && (i > 5) && (j > 5) && (i < 250) && (j < 250)) 
                sout3(i,j) = 1;     
                new=[j i];   %col, row
                background_array(index,:)=new;
                index = index+1;   
            else
                sout3(i,j) = 0;
            end
        end
    end

    
    %takes 100 random samples from the background_array
    background_sample = datasample(background_array,100,1,'Replace',false);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    observed_response1_1 = ones(100, 1);
    observed_response1_2 = zeros(100, 1);
    observed_response1_3 = zeros(100, 1);
    for (temp_index = 1:100)
        observed_response1_3(temp_index) = 6;
    end
    
    %indexes the tumor_sample matrix and extracts patches

    pixel_array = zeros(1, 49);
    index2 = 1;
    patches_array1_1 = zeros(100, 49);

    for i = 1:100  
        ptx = tumor_sample(i,1);
        pty = tumor_sample(i,2);

        index = 1;
        for j = 0:6
            for x = 0:6  
                temp = data(data_val).t2(pty-1+x, ptx-1+j); %col, row
                pixel_array(index) = temp; %store pixel vals in array
                index = index + 1;
            end;
        end;

        patches_array1_1(index2,:) = pixel_array;    
        index2 = index2 + 1;
    end

    %indexes the healthy_prostate_sample matrix and extracts patches
    pixel_array = zeros(1, 49);
    index2 = 1;
    patches_array1_2 = zeros(100, 49);

    for i = 1:100  
        ptx = healthy_prostate_sample(i,1);
        pty = healthy_prostate_sample(i,2);
    
        index = 1;
        for j = 0:6
            for x = 0:6  
                temp = data(data_val).t2(pty-1+x, ptx-1+j); 
                pixel_array(index) = temp; %store pixel vals in array
                index = index + 1;
            end;
        end;

        patches_array1_2(index2,:) = pixel_array;
        index2 = index2 + 1;
    end

     %indexes the background_sample matrix and extracts patches
     
     pixel_array = zeros(1, 49);
    index2 = 1;
    patches_array1_3 = zeros(100, 49);

    for i = 1:100  
        ptx = background_sample(i,1);
        pty = background_sample(i,2);
    
        index = 1;
        for j = 0:6
            for x = 0:6  
                temp = data(data_val).t2(pty-1+x, ptx-1+j); 
                pixel_array(index) = temp; %store pixel vals in array
                index = index + 1;
            end;
        end;

        patches_array1_3(index2,:) = pixel_array;
        index2 = index2 + 1;
    end
     
     
    
     

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    patches_array = cat(1, patches_array, patches_array1_1, patches_array1_2, patches_array1_3);
    observed_response = cat(1, observed_response, observed_response1_1, observed_response1_2, observed_response1_3);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

my_table1 = table(patches_array, observed_response);

