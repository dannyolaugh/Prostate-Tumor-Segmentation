t0 = 60;
th = t0+((max(inp(:))+min(inp(:)))./2);

patches_array = [];
observed_response = [];

for k=0:6

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

    %takes 100 random samples from the healthy_prostate_array
    healthy_prostate_sample = datasample(healthy_prostate_array,100,1,'Replace',false);
    
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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%the loop below is specifically taylored for image 1

my_output = zeros(53,15);
my_output2 = zeros(53,15);
new_array = zeros(1,2);
index = 1;

for i=96:163
    for j=97:149
        my_output2(j-96,i-95) = data(1).slide_roi(j, i); %row, col
        new=[i, j];
        new_array(index,:)=new;
        index = index+1;
    end
end

%this creates the picture with padding so we can take the 7*7 patches
for i=93:166
    for j=94:152
        my_output(j-93,i-92) = data(1).t2(j, i); %row, col
    end
end

pixel_array = zeros(1, 49);
index2 = 1;
patches_array = zeros(100, 49);

for i = 1:3604  
    ptx = new_array(i,1);
    pty = new_array(i,2);

    index = 1;
    for j = 0:6
       for x = 0:6  
          temp = my_output(pty-3-93+x, ptx-3-92+j); %col, row
          pixel_array(index) = temp; %store pixel vals in array
          index = index + 1;
       end;
    end;

    patches_array(index2,:) = pixel_array;    
    index2 = index2 + 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

my_table1 = table(patches_array);
yfit = trainedModel2.predictFcn(my_table1);

index = 1;
final_image = zeros(53, 15);
for i=96:163
    for j=97:149
       final_image(j-96,i-95) = yfit(index)
        index = index + 1;
    end
end

%{
index = 1;
final_image = zeros(53, 15);
for i=96:163
    for j=97:149
        if(yfit(index) > 2 && yfit(index) < 3)
            temp = 130;
        elseif(yfit(index) > 3)
            temp = 20;
        elseif((yfit(index) > 0) && (yfit(index) < 2))
            temp = 60;
        end
        final_image(j-96,i-95) = temp; %row, col
        index = index + 1;
    end
end

T = [0,   0,   0          %// dark
     101, 67,  33         %// brown
     255, 105, 180        %// pink
     255, 255, 255        %// white
     255, 255, 255]./255;

x = [0
     50
     120
     160
     255];

map = interp1(x/255,T,linspace(0,1,255));
 
RGB = ind2rgb(final_image, map)
 %}
figure;
imagesc(final_image);
figure;
imagesc(my_output);



