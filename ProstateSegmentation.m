load('/Users/danolaughlin/Downloads/registered2b.mat');

inp = imread('output1.png');
inp = imresize(inp,[256,256]);

inp2 = imread('output2.png');
inp2 = imresize(inp2, [256,256]);

if size(inp,3)>1
    inp=rgb2gray(inp);
end

figure;
imshow(inp);title('Input Image');
ou=imresize(inp,[256,256]);

t0 = 60;
th = t0+((max(inp(:))+min(inp(:)))./2);


%%%%%%%%%%%%%%%%%%%%%%%%%%Prostate Tumor Sample%%%%%%%%%%%%%%%%%%%%%%%%%%%
tumor_array = zeros(100, 2);
index = 1;
sout = zeros(256,256);

for j=1:1:size(inp,1)
    for i=1:1:size(inp,2)
        if ((inp(i,j)>th)&& (i > 34) && (i < 225) && (j > 33) && (j < 229)) % takes away the white border of the image cause that was messing it up
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
sout2 = zeros(256,256);
index = 1;
for j=1:1:size(inp,1)
    for i=1:1:size(inp,2)
        if ((inp(i,j)>(th-70)) && (inp(i,j) < (th)) && (i > 34) && (i < 225) && (j > 33) && (j < 229))
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

%figure;
%imshow(sout2);title('Segmented Healthy Prostate Image');
%display(healthy_prostate_array);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

observed_response1 = ones(100, 1);
observed_response2 = zeros(100, 1);
observed_response = cat(1, observed_response1, observed_response2);

%indexes the tumor_sample matrix and passes in the x and y values for each row

RGB = inp2;
pixel_array = zeros(9,3);
index2 = 1;
patches_array1 = zeros(100, 9);

for i = 1:100  
    ptx = tumor_sample(i,1);
    pty = tumor_sample(i,2);
    
    pixel_array = zeros(1, 9);

    index = 1;
    for j = 0:2
        for x = 0:2  
            temp = data(1).t2(ptx-1+x, pty-1+j); %col, row
            pixel_array(index) = temp; %store pixel vals in array
            index = index + 1;
        end;
    end;

    patches_array1(index2,:) = pixel_array;    
    index2 = index2 + 1;
end

%indexes the healthy_prostate_sample matrix and passes in the x and y values for each row
RGB = inp2;
pixel_array = zeros(9,3);
index2 = 1;
patches_array2 = zeros(100, 9);

for i = 1:100  
    ptx = healthy_prostate_sample(i,1);
    pty = healthy_prostate_sample(i,2);
    
    pixel_array = zeros(1, 9);

    index = 1;
    for j = 0:2
        for x = 0:2  
            temp = data(1).t2(ptx-1+x, pty-1+j); %col, row
            pixel_array(index) = temp; %store pixel vals in array
            index = index + 1;
        end;
    end;

    patches_array2(index2,:) = pixel_array;
    index2 = index2 + 1;
end

patches_array = cat(1, patches_array1, patches_array2);
b = regress(observed_response, patches_array);  %y, X
display(healthy_prostate_sample);
display(patches_array);
display(data(1).t2(142, 147));
display(b);

