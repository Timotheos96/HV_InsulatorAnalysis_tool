classdef HV_InsulatorTool_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        HV_Insulator_Tool              matlab.ui.Figure
        TabGroup                       matlab.ui.container.TabGroup
        PreprocessTab                  matlab.ui.container.Tab
        CLEAR_2                        matlab.ui.control.Button
        num1                           matlab.ui.control.Label
        tiplabel                       matlab.ui.control.Label
        diameter                       matlab.ui.control.NumericEditField
        ProvidethediameterofshedinmmLabel  matlab.ui.control.Label
        Description                    matlab.ui.control.Label
        Author                         matlab.ui.control.Label
        Image                          matlab.ui.control.Image
        NextTab1                       matlab.ui.control.Button
        CheckBox                       matlab.ui.control.CheckBox
        IstheresparkinfirstframeLabel  matlab.ui.control.Label
        Label7                         matlab.ui.control.Label
        Label5                         matlab.ui.control.Label
        TestButton                     matlab.ui.control.Button
        Brightpixel                    matlab.ui.control.NumericEditField
        Thevalueofthebrightestpixelinthe1stFramemax255EditFieldLabel  matlab.ui.control.Label
        Label2                         matlab.ui.control.Label
        BWlevel                        matlab.ui.control.Spinner
        BlackandWhiteThresholdLabel    matlab.ui.control.Label
        Label1                         matlab.ui.control.Label
        filename1                      matlab.ui.control.EditField
        EditField_3Label               matlab.ui.control.Label
        LOAD2                          matlab.ui.control.Button
        AxesBW                         matlab.ui.control.UIAxes
        Axes1                          matlab.ui.control.UIAxes
        MainProcessTab                 matlab.ui.container.Tab
        NewVideoName                   matlab.ui.control.EditField
        SelectanameforthenewcroppedvideoEditFieldLabel  matlab.ui.control.Label
        YesNo                          matlab.ui.control.DropDown
        IncludeflashoverframeininsulatorsanalaysisLabel  matlab.ui.control.Label
        SelectedDiameter               matlab.ui.control.NumericEditField
        SelectedsheddiameterinmmLabel  matlab.ui.control.Label
        Image_2                        matlab.ui.control.Image
        SelectedvideoLabel             matlab.ui.control.Label
        SelectedBW                     matlab.ui.control.NumericEditField
        SelectedBlackandWhiteThresholdEditFieldLabel  matlab.ui.control.Label
        NextTab2_1                     matlab.ui.control.Button
        NextTab2                       matlab.ui.control.Button
        CLEAR                          matlab.ui.control.Button
        ElapsedTime                    matlab.ui.control.EditField
        ElapsedTimeHHmmssmsLabel       matlab.ui.control.Label
        CheckvideoforSparksLabel       matlab.ui.control.Label
        STARTButton                    matlab.ui.control.Button
        EditField_2                    matlab.ui.control.EditField
        EditField_2Label               matlab.ui.control.Label
        SumsPxls                       matlab.ui.control.UIAxes
        AxesVid                        matlab.ui.control.UIAxes
        PostProcessTab                 matlab.ui.container.Tab
        sparklengthpixels              matlab.ui.control.NumericEditField
        TotalaxiallengthofsparksinpixelsEditFieldLabel  matlab.ui.control.Label
        label3_1                       matlab.ui.control.Label
        AnalyseframewithSpark          matlab.ui.control.Button
        sparklengthmm                  matlab.ui.control.NumericEditField
        TotalaxiallelngthofsparksinmmLabel  matlab.ui.control.Label
        Image_3                        matlab.ui.control.Image
        NextTab3_1                     matlab.ui.control.Button
        Spinner                        matlab.ui.control.Spinner
        ChooseFrameforanalysisSpinnerLabel  matlab.ui.control.Label
        AnalyseFrame                   matlab.ui.control.UIAxes
        AxesBottom                     matlab.ui.control.UIAxes
        AxesCentral                    matlab.ui.control.UIAxes
        AxesTop                        matlab.ui.control.UIAxes
    end

    
    properties (Access = public)
        filename=""; % Description
        rotatedimg;
        Video1;
        NumberFrames;
        frameanalysisimg;
        widthpixels;
        brightestnum;
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: STARTButton
        function STARTButtonPushed(app, event)
            vid1=VideoReader(app.filename);
            tic;
            app.STARTButton.Enable='off';
            progressf = uifigure;
            proggresd = uiprogressdlg(progressf,'Title','Computing in progress','Message','Please wait...','Indeterminate','on');
    
            FrameNumber1=vid1.NumberOfFrames;
            %writerObj1 = VideoWriter('V2-crop.avi');
            writerObj1=VideoWriter(app.NewVideoName.Value);
            open(writerObj1);

            img=read(vid1,1);
            I=rgb2gray(img);
            stretched=imadjust(img,stretchlim(img));
            level=app.BWlevel.Value;
            BW=im2bw(stretched,level);
            BW=imfill(BW,'holes');
            se=strel('disk',3);% creates a disk-shaped structuring element, where r specifies the radius and n specifies the number of line structuring elements used to approximate the disk shape. Morphological operations using disk approximations run much faster when the structuring element uses approximations.
            BW=imopen(BW,se);
            ImgSize=size(BW);
            BWregion=regionprops(BW,"all");
            MaxArea=max([BWregion.Area]);
            Areas=[BWregion.Area];
            index=find(Areas==MaxArea);
            box=BWregion(index).BoundingBox;
            box(1,1)=box(1,1)-130;
            box(1,3)=box(1,3)+280;
            box(1,4)=ImgSize(1,1);
            Angle=BWregion(index).Orientation;
            if (Angle<0)
                Angle=-(90+Angle);
            else
                Angle=90-Angle;
            end
            maxBright=max(I);
            maxBright=sort(maxBright,'descend');
            maxBright=maxBright(1,3);
            simea=0;
            for i=1: FrameNumber1
              FirstFrame=read(vid1,i);
              imr1=imrotate(FirstFrame,Angle);
              imc1=imcrop(imr1,box);% The dimention of the new video
              grayimg=rgb2gray(imc1);
              I=(grayimg>maxBright);
              if (sum(sum(I))>=(0.75*min(size(I))*length(I))) && (simea==0)
                simea=i-1;
              end
              SumofPxls = sum(sum(I(:)));
              PxlsVSFrame(i)= SumofPxls;
              writeVideo(writerObj1,imc1);  
            end
            close(writerObj1);
    
            %vid2=VideoReader('V2-crop.avi');
            onoma=string(app.NewVideoName.Value+".avi");
            vid2=VideoReader(onoma);
            app.Video1=vid2;
            FrameNumber2=vid2.NumFrames;
            app.NumberFrames=FrameNumber2;
            

            img=read(vid2,1);
            RotatedImg=img;
            RotatedImg2=imrotate(RotatedImg,-90);           
            I=rgb2gray(img);
            I2=rgb2gray(RotatedImg2);
            stretched=imadjust(I2,stretchlim(I2));
            stretched2=imadjust(I,stretchlim(I));
            lv=0.35;
           % lv=app.BWlevel.Value;%%%%%%%%%%%%%%%%
            BW2=im2bw(I,lv);
            BW=im2bw(imrotate(I,-90),lv);
            %BW2=im2bw(stretched2,lv);
            %BW=im2bw(stretched,lv);
            BW=imfill(BW,'holes');
            BW2=imfill(BW2,'holes');
            se=strel('disk',3);% creates a disk-shaped structuring element, where r specifies the radius and n specifies the number of line structuring elements used to approximate the disk shape. Morphological operations using disk approximations run much faster when the structuring element uses approximations.
            BW=imopen(BW,se);
            BW2=imopen(BW2,se);
            BWregion=regionprops(BW,"all");
            [B,L] = bwboundaries(BW2,'noholes');
            imshow(RotatedImg,'Parent',app.AxesVid);
            hold(app.AxesVid,"on");
            for k = 1:length(B)
               boundary = B{k}; 
               plot(app.AxesVid,boundary(:,2), boundary(:,1), 'g', 'LineWidth', 1)
            end
            flag=0;
            [iii,j]=size(BW);
            for ii=1:iii
               for jj=1:j
                   if (BW(ii,jj)==1)
                       count=[ii jj];
                   end
               end
            end
            for ii=1:iii
               for jj=1:j
                   if (BW(ii,jj)==1)
                       count2=[ii jj];
                       flag=1;
                       break;
                   end
               end
                if (flag==1)
                     break;
                end
            end
            xline(app.AxesVid,count(1,1)-8,"b","LineWidth",2);
            xline(app.AxesVid,count2(1,1)+8,"b","LineWidth",2);
            width=count(1,1)-count2(1,1)-2;
            app.widthpixels=width;
            [iii,j]=size(BW2);
            i=1;
            index=1;
            trunk=[];
            for jj=(count2(1,1)+30):(count(1,1)-15)
             while i<=iii
                 if (BW2(i,jj)==1)
                     trunk=[trunk;i+5 jj+5];
                     yline(app.AxesVid,trunk(index,1),'r','LineWidth',2);
                     i=i+40;
                     index=index+1;
                 end
                 i=i+1;
             end
            end


            flag=0;
            midpoint=floor(((trunk(2,1)-trunk(1,1))/2)+trunk(1,1));
            %trunk2=[];
            for i=trunk(1,2):j
                if (BW2(midpoint,i)==1) && (flag==0)
                    xline(app.AxesVid,i-3,'r','LineWidth',1);
                    flag=1;
                end
                if (BW2(midpoint,i)==0) && (flag==1)
                    xline(app.AxesVid,i+3,'r','LineWidth',1);
                    flag=2;
                    break;
                end
            end
            
            box1=[1,trunk(1,1),count2(1,1),count(1,1)];
            box2=[trunk(1,1),trunk(2,1),count2(1,1),count(1,1)];
            box3=[trunk(2,1),trunk(3,1),count2(1,1),count(1,1)];
            box4=[trunk(3,1),trunk(4,1),count2(1,1),count(1,1)];
            box5=[trunk(4,1),iii,count2(1,1),count(1,1)];
            

            X1=[];
            X2=[];
            X3=[];
            X4=[];
            X5=[];
            if (app.YesNo.Value=="Yes")
                ChoiceFrms=FrameNumber2;
            else
                ChoiceFrms=simea;
            end
            for t = 1 : ChoiceFrms
                CurrentFrame = read(vid2, t);
                I1=rgb2gray(CurrentFrame);
                I=I1>maxBright;
                X1(t)=sum(sum(I(box1(1,1):box1(1,2),box1(1,3):box1(1,4)))); 
                X2(t)=sum(sum(I(box2(1,1):box2(1,2),box1(1,3):box2(1,4)))); 
                X3(t)=sum(sum(I(box3(1,1):box3(1,2),box1(1,3):box3(1,4)))); 
                X4(t)=sum(sum(I(box4(1,1):box4(1,2),box1(1,3):box4(1,4)))); 
                X5(t)=sum(sum(I(box5(1,1):box5(1,2),box1(1,3):box5(1,4)))); 
            end
            Sums=[sum(X5) sum(X4) sum(X3) sum(X2) sum(X1)];
            barh(app.SumsPxls,Sums);
            format long;
            plot(app.AxesTop,X2);
            ylim(app.AxesTop,[0 3000]);
            
            plot(app.AxesCentral,X3);
            ylim(app.AxesCentral,[0 3000]);
            
            plot(app.AxesBottom,X4);
            ylim(app.AxesBottom,[0 3000]);
              
            close(proggresd);
            close(progressf);
            ora=seconds(toc);
            ora.Format = 'hh:mm:ss.SSS';
            Elapsed=string(ora);
            app.ElapsedTime.Value=Elapsed;
            app.Spinner.Enable='on';
        end

        % Value changed function: Spinner
        function SpinnerValueChanged(app, event)
            app.Spinner.Limits=[1 app.NumberFrames];
            value = app.Spinner.Value;
            Image=read(app.Video1,value);
            imshow(Image,'Parent',app.AnalyseFrame);
            app.frameanalysisimg=Image;
            app.AnalyseframewithSpark.Enable='on';
        end

        % Button pushed function: CLEAR
        function CLEARButtonPushed(app, event)
            app.EditField_2.Value=" ";
            app.ElapsedTime.Value=" ";
            cla(app.AxesVid);
            cla(app.AnalyseFrame);
            cla(app.AxesCentral);
            cla(app.AxesTop);
            cla(app.AxesBottom);
            app.STARTButton.Enable='off';
            app.Spinner.Enable='off';
            app.filename1.Value="";
            app.BWlevel.Value=0.31;
            cla(app.AxesBW);
            cla(app.Axes1);
            app.diameter.Value=0;
            app.Brightpixel.Value=0;
            cla(app.SumsPxls);
            app.SelectedBW.Value=0.31;
            app.SelectedDiameter.Value=0;
            app.Spinner.Limits=[0 inf];
            app.Spinner.Value=0;
            app.sparklengthmm.Value=0;
            app.sparklengthpixels.Value=0;
            app.NewVideoName.Value="";
        end

        % Button pushed function: LOAD2
        function LOAD2ButtonPushed(app, event)
            % Display uigetfile dialog
            filterspec = {'*.MTS;*.mp4;*.avi;*.mj2;*.mov;*.m4v;*.asf','All Video Files'};
            [f, p] = uigetfile(filterspec);
            % Make sure user didn't cancel uigetfile dialog
            if (ischar(p))
               fname = [p f];
              app.filename=fname;
              app.EditField_2.Value=f;
              app.filename1.Value=f;
              % updateimage(app, fname);
            end
            video=VideoReader(fname);
            FirstFrm=read(video,1);
            imshow(FirstFrm,'Parent',app.AxesVid);
            imshow(FirstFrm,'Parent',app.Axes1);
            drawnow; 
            app.TestButton.Enable='on';
            I=rgb2gray(FirstFrm);
            maxBright=max(I);
            maxBright=sort(maxBright,'descend');
            maxBright=maxBright(1,1);
            app.Brightpixel.Value=double(maxBright);
            app.brightestnum=app.Brightpixel.Value;
            BWlevelValueChanged(app,event);
        end

        % Button pushed function: TestButton
        function TestButtonPushed(app, event)
            %Test button for pre processing images
            vid1=VideoReader(app.filename);
            img=read(vid1,1);
            I=rgb2gray(img);
            stretched=imadjust(I,stretchlim(I));
            level=app.BWlevel.Value;
            BW=im2bw(stretched,level);
            BWregion=regionprops(BW,"all");
            [a,b]=size(BW);
            White=sum([BWregion.Area]);
            if (White>(a*b-White))
                BW=~BW;            
            end

            BW=imfill(BW,'holes');
            se=strel('disk',3);% creates a disk-shaped structuring element, where r specifies the radius and n specifies the number of line structuring elements used to approximate the disk shape. Morphological operations using disk approximations run much faster when the structuring element uses approximations.
            BW=imopen(BW,se);
            BWregion=regionprops(BW,"all");

            MaxArea=max([BWregion.Area]);
            BW = bwareafilt(BW,[MaxArea-1 MaxArea]);
            BWregion=regionprops(BW,"all");
            Areas=[BWregion.Area];
            i=find(Areas==MaxArea);
            Angle=BWregion(i).Orientation;
            
            if (Angle<0)
                RotatedImg=imrotate(img,-(90+Angle));
                BW1=imrotate(BW,-(90+Angle));
            else
                RotatedImg=imrotate(img,90-Angle);
                BW1=imrotate(BW,90-Angle);
            end
            RotatedImg2=imrotate(RotatedImg,-90);
            BW2=imrotate(BW1,-90);
            %app.Axes1.cla;  
            cla(app.Axes1);
            imshow(RotatedImg,'Parent',app.Axes1);
            hold (app.Axes1,"on");
            flag=0;
            [iii,j]=size(BW2);
            for ii=1:iii
               for jj=1:j
                   if (BW2(ii,jj)==1)
                       count=[ii jj];
                   end
               end
            end
            for ii=1:iii
               for jj=1:j
                   if (BW2(ii,jj)==1)
                       count2=[ii jj];
                       flag=1;
                       break;
                   end
               end
                if (flag==1)
                     break;
                end
            end
            xline(app.Axes1,count(1,1)-8,"r","LineWidth",2);
            xline(app.Axes1,count2(1,1)+8,"r","LineWidth",2);
            width=count(1,1)-count2(1,1);
            [iii,j]=size(BW1);
            i=1;
            index=1;
            trunk=[];
            for jj=(count2(1,1)+30):(count(1,1)-20)
             while i<=iii
                 if (BW1(i,jj)==1)
                     trunk=[trunk;i+5 jj+5];
                     yline(app.Axes1,trunk(index,1),'r','LineWidth',2);
                     i=i+40;
                     index=index+1;
                 end
                 i=i+1;
             end
            end          
        end

        % Value changed function: BWlevel
        function BWlevelValueChanged(app, event)
            value = app.BWlevel.Value;
            app.SelectedBW.Value=value;
            vid1=VideoReader(app.filename);
            img=read(vid1,1);
            I=rgb2gray(img);
            stretched=imadjust(I,stretchlim(I));
            level=value;
            BW=im2bw(stretched,level);
            BWregion=regionprops(BW,"all");
            [a,b]=size(BW);
            White=sum([BWregion.Area]);
            if (White>(a*b-White))
                BW=~BW;
            end
            BW=imfill(BW,'holes');
            se=strel('disk',3);% creates a disk-shaped structuring element, where r specifies the radius and n specifies the number of line structuring elements used to approximate the disk shape. Morphological operations using disk approximations run much faster when the structuring element uses approximations.
            BW=imopen(BW,se);
           % imshow(BW,'Parent',app.Axes1);
            imshow(BW,'Parent',app.AxesBW);
        end

        % Value changed function: CheckBox
        function CheckBoxValueChanged(app, event)
            value = app.CheckBox.Value;
            video=VideoReader(app.filename);
            if value==1
                imshow(read(video,2),'Parent',app.Axes1);
                app.Axes1.Title.String="Second Frame";
            else
                app.Axes1.Title.String="First Frame";
            end
        end

        % Button pushed function: NextTab1
        function NextTab1Pushed(app, event)
            app.TabGroup.SelectedTab=app.MainProcessTab;
        end

        % Button pushed function: NextTab2
        function NextTab2ButtonPushed(app, event)
            app.TabGroup.SelectedTab=app.PostProcessTab;
        end

        % Button pushed function: NextTab2_1
        function NextTab2_1ButtonPushed(app, event)
            app.TabGroup.SelectedTab=app.PreprocessTab;
        end

        % Button pushed function: NextTab3_1
        function NextTab3_1ButtonPushed(app, event)
            app.TabGroup.SelectedTab=app.MainProcessTab;            
        end

        % Button pushed function: AnalyseframewithSpark
        function AnalyseframewithSparkPushed(app, event)
           img=app.frameanalysisimg;
           a=rgb2gray(img);
           b=(a>=app.Brightpixel.Value);
           BWregionB=regionprops(b,'all');
           %imshow(b,'Parent',app.AnalyseFrame);
           %Areas=[BWregionB.Area];
           %MaxAreaSparkI=find(Areas==max(Areas));
           store=0;
           storei=0;
           TF=0;
           if min(size(BWregionB))==0
               TF=1;
           end
           if (TF==1)
               SparkBox=[0 0 0 0];
           else
            for i=1:max(size(BWregionB))
                if BWregionB(i).BoundingBox(1,4)>store
                    store=BWregionB(i).BoundingBox(1,4);
                    storei=i;
                end
            end
            SparkBox=BWregionB(storei).BoundingBox;
           end
           rectangle(app.AnalyseFrame,'Position',SparkBox,'EdgeColor','r');
           hold (app.AnalyseFrame,"on");
           PixLength=SparkBox(1,4);
           %title(['The axial lenght is: ',num2str(PixLength),' Pixels']);%: ",PixLength," Pixels");
           count=0;
           [i,j]=size(b);
           for ii=1:i
              for jj=1:j
                  if (b(ii,jj)==1)
                      count=count+1;
                      plot(app.AnalyseFrame,200,ii,'.');
                     % yline(app.AnalyseFrame,ii,'r','LineWidth',1);
                      break;
                  end
              end
           end           
           app.sparklengthpixels.Value=count;
           app.sparklengthmm.Value=(count*app.diameter.Value)/(app.widthpixels);
        end

        % Value changed function: diameter
        function diameterValueChanged(app, event)
            value = app.diameter.Value;
            app.SelectedDiameter.Value=double(value);
            if value==0
               app.STARTButton.Enable='off'; 
            else
                app.STARTButton.Enable='on';
            end
        end

        % Value changed function: Brightpixel
        function BrightpixelValueChanged(app, event)
            value = app.Brightpixel.Value;
            app.brightestnum=value;
        end

        % Button pushed function: CLEAR_2
        function CLEAR_2ButtonPushed(app, event)
            app.EditField_2.Value=" ";
            app.ElapsedTime.Value=" ";
            cla(app.AxesVid);
            cla(app.AnalyseFrame);
            cla(app.AxesCentral);
            cla(app.AxesTop);
            cla(app.AxesBottom);
            app.STARTButton.Enable='off';
            app.Spinner.Enable='off';
            app.filename1.Value="";
            app.BWlevel.Value=0.31;
            cla(app.AxesBW);
            cla(app.Axes1);
            app.diameter.Value=0;
            app.Brightpixel.Value=0;
            cla(app.SumsPxls);
            app.SelectedBW.Value=0.31;
            app.SelectedDiameter.Value=0;
            app.Spinner.Limits=[0 inf];
            app.Spinner.Value=0;
            app.sparklengthmm.Value=0;
            app.sparklengthpixels.Value=0;
            app.NewVideoName.Value="";
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create HV_Insulator_Tool and hide until all components are created
            app.HV_Insulator_Tool = uifigure('Visible', 'off');
            app.HV_Insulator_Tool.Position = [100 100 902 640];
            app.HV_Insulator_Tool.Name = 'HV Insulator Analysis tool';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.HV_Insulator_Tool);
            app.TabGroup.Position = [1 1 902 640];

            % Create PreprocessTab
            app.PreprocessTab = uitab(app.TabGroup);
            app.PreprocessTab.Tooltip = {''};
            app.PreprocessTab.Title = 'Pre-process ';
            app.PreprocessTab.BackgroundColor = [0.9412 0.9412 0.9412];

            % Create Axes1
            app.Axes1 = uiaxes(app.PreprocessTab);
            title(app.Axes1, 'First Frame')
            app.Axes1.PlotBoxAspectRatio = [1.57894736842105 1 1];
            app.Axes1.XTick = [];
            app.Axes1.YTick = [];
            app.Axes1.Position = [509 216 385 277];

            % Create AxesBW
            app.AxesBW = uiaxes(app.PreprocessTab);
            app.AxesBW.PlotBoxAspectRatio = [1.75 1 1];
            app.AxesBW.XTick = [];
            app.AxesBW.YTick = [];
            app.AxesBW.Position = [58 163 334 208];

            % Create LOAD2
            app.LOAD2 = uibutton(app.PreprocessTab, 'push');
            app.LOAD2.ButtonPushedFcn = createCallbackFcn(app, @LOAD2ButtonPushed, true);
            app.LOAD2.Position = [199 481 53 22];
            app.LOAD2.Text = 'LOAD';

            % Create EditField_3Label
            app.EditField_3Label = uilabel(app.PreprocessTab);
            app.EditField_3Label.HorizontalAlignment = 'right';
            app.EditField_3Label.Position = [292 447 25 22];
            app.EditField_3Label.Text = '';

            % Create filename1
            app.filename1 = uieditfield(app.PreprocessTab, 'text');
            app.filename1.Editable = 'off';
            app.filename1.Position = [271 481 141 22];

            % Create Label1
            app.Label1 = uilabel(app.PreprocessTab);
            app.Label1.Position = [44 481 84 22];
            app.Label1.Text = 'Load the video';

            % Create BlackandWhiteThresholdLabel
            app.BlackandWhiteThresholdLabel = uilabel(app.PreprocessTab);
            app.BlackandWhiteThresholdLabel.HorizontalAlignment = 'right';
            app.BlackandWhiteThresholdLabel.Position = [172 414 157 22];
            app.BlackandWhiteThresholdLabel.Text = 'Black and White Threshold';

            % Create BWlevel
            app.BWlevel = uispinner(app.PreprocessTab);
            app.BWlevel.Step = 0.01;
            app.BWlevel.Limits = [0 1];
            app.BWlevel.ValueDisplayFormat = '%.2f';
            app.BWlevel.ValueChangedFcn = createCallbackFcn(app, @BWlevelValueChanged, true);
            app.BWlevel.Position = [344 414 59 22];
            app.BWlevel.Value = 0.31;

            % Create Label2
            app.Label2 = uilabel(app.PreprocessTab);
            app.Label2.Position = [38 414 142 22];
            app.Label2.Text = '   Set the B&W threshold';

            % Create Thevalueofthebrightestpixelinthe1stFramemax255EditFieldLabel
            app.Thevalueofthebrightestpixelinthe1stFramemax255EditFieldLabel = uilabel(app.PreprocessTab);
            app.Thevalueofthebrightestpixelinthe1stFramemax255EditFieldLabel.HorizontalAlignment = 'right';
            app.Thevalueofthebrightestpixelinthe1stFramemax255EditFieldLabel.Position = [459 186 320 22];
            app.Thevalueofthebrightestpixelinthe1stFramemax255EditFieldLabel.Text = 'The value of the brightest pixel in the 1st Frame (max 255)';

            % Create Brightpixel
            app.Brightpixel = uieditfield(app.PreprocessTab, 'numeric');
            app.Brightpixel.Limits = [0 255];
            app.Brightpixel.RoundFractionalValues = 'on';
            app.Brightpixel.ValueChangedFcn = createCallbackFcn(app, @BrightpixelValueChanged, true);
            app.Brightpixel.Editable = 'off';
            app.Brightpixel.Position = [794 186 100 22];

            % Create TestButton
            app.TestButton = uibutton(app.PreprocessTab, 'push');
            app.TestButton.ButtonPushedFcn = createCallbackFcn(app, @TestButtonPushed, true);
            app.TestButton.Enable = 'off';
            app.TestButton.Position = [212 39 100 22];
            app.TestButton.Text = 'Test';

            % Create Label5
            app.Label5 = uilabel(app.PreprocessTab);
            app.Label5.Position = [41 39 132 22];
            app.Label5.Text = '   Run the test scenario ';

            % Create Label7
            app.Label7 = uilabel(app.PreprocessTab);
            app.Label7.Position = [344 88 536 22];
            app.Label7.Text = 'If the sheds are not being identified restart test by clearing everything and change B&W threshold.';

            % Create IstheresparkinfirstframeLabel
            app.IstheresparkinfirstframeLabel = uilabel(app.PreprocessTab);
            app.IstheresparkinfirstframeLabel.Position = [49 130 164 22];
            app.IstheresparkinfirstframeLabel.Text = '   Is there spark in first frame?';

            % Create CheckBox
            app.CheckBox = uicheckbox(app.PreprocessTab);
            app.CheckBox.ValueChangedFcn = createCallbackFcn(app, @CheckBoxValueChanged, true);
            app.CheckBox.Text = '';
            app.CheckBox.Position = [222 129 22 25];

            % Create NextTab1
            app.NextTab1 = uibutton(app.PreprocessTab, 'push');
            app.NextTab1.ButtonPushedFcn = createCallbackFcn(app, @NextTab1Pushed, true);
            app.NextTab1.Icon = 'pointers-icon-arrows-icon-right-arrow-icon-next-icon-logo-material-property-symbol-png-clip-art.png';
            app.NextTab1.Position = [816 45 35 22];
            app.NextTab1.Text = '';

            % Create Image
            app.Image = uiimage(app.PreprocessTab);
            app.Image.Position = [794 513 100 100];
            app.Image.ImageSource = 'logo.png';

            % Create Author
            app.Author = uilabel(app.PreprocessTab);
            app.Author.FontSize = 11;
            app.Author.Position = [28 560 132 22];
            app.Author.Text = 'Author: Timotheos Savva ';

            % Create Description
            app.Description = uilabel(app.PreprocessTab);
            app.Description.FontSize = 14;
            app.Description.Position = [28 581 430 22];
            app.Description.Text = 'Description: An interactive tool for analysing polluted HV insulators.';

            % Create ProvidethediameterofshedinmmLabel
            app.ProvidethediameterofshedinmmLabel = uilabel(app.PreprocessTab);
            app.ProvidethediameterofshedinmmLabel.HorizontalAlignment = 'right';
            app.ProvidethediameterofshedinmmLabel.Position = [38 79 206 22];
            app.ProvidethediameterofshedinmmLabel.Text = '   Provide the diameter of shed in mm';

            % Create diameter
            app.diameter = uieditfield(app.PreprocessTab, 'numeric');
            app.diameter.Limits = [0 Inf];
            app.diameter.ValueDisplayFormat = '%.0f';
            app.diameter.ValueChangedFcn = createCallbackFcn(app, @diameterValueChanged, true);
            app.diameter.Position = [252 79 46 22];

            % Create tiplabel
            app.tiplabel = uilabel(app.PreprocessTab);
            app.tiplabel.FontSize = 11;
            app.tiplabel.Position = [41 378 419 26];
            app.tiplabel.Text = '*make sure the trunk and sheds are well defined .Try key levels(0.3-0.4 etc.) ';

            % Create num1
            app.num1 = uilabel(app.PreprocessTab);
            app.num1.FontWeight = 'bold';
            app.num1.FontColor = [1 0 0];
            app.num1.Position = [20 37 25 465];
            app.num1.Text = {'1)'; ''; ''; ''; ''; '2)'; ''; ''; ''; ''; ''; ''; ''; ''; ''; ''; ''; ''; ''; ''; ''; ''; ''; ''; ''; ''; ''; '3)'; ''; ''; ''; '4)'; ''; ''; '5)'};

            % Create CLEAR_2
            app.CLEAR_2 = uibutton(app.PreprocessTab, 'push');
            app.CLEAR_2.ButtonPushedFcn = createCallbackFcn(app, @CLEAR_2ButtonPushed, true);
            app.CLEAR_2.Position = [391 39 100 22];
            app.CLEAR_2.Text = 'CLEAR';

            % Create MainProcessTab
            app.MainProcessTab = uitab(app.TabGroup);
            app.MainProcessTab.Title = 'Main Process';

            % Create AxesVid
            app.AxesVid = uiaxes(app.MainProcessTab);
            title(app.AxesVid, 'First Frame')
            app.AxesVid.PlotBoxAspectRatio = [1.79423868312757 1 1];
            app.AxesVid.XTick = [];
            app.AxesVid.YTick = [];
            app.AxesVid.Position = [1 282 461 329];

            % Create SumsPxls
            app.SumsPxls = uiaxes(app.MainProcessTab);
            title(app.SumsPxls, 'Area with more bright pixels through all frames')
            xlabel(app.SumsPxls, 'Total of Bright Pixels')
            app.SumsPxls.PlotBoxAspectRatio = [1.29059829059829 1 1];
            app.SumsPxls.Position = [419 261 350 341];

            % Create EditField_2Label
            app.EditField_2Label = uilabel(app.MainProcessTab);
            app.EditField_2Label.HorizontalAlignment = 'right';
            app.EditField_2Label.Position = [150 195 25 22];
            app.EditField_2Label.Text = '';

            % Create EditField_2
            app.EditField_2 = uieditfield(app.MainProcessTab, 'text');
            app.EditField_2.Editable = 'off';
            app.EditField_2.Position = [129 229 141 22];

            % Create STARTButton
            app.STARTButton = uibutton(app.MainProcessTab, 'push');
            app.STARTButton.ButtonPushedFcn = createCallbackFcn(app, @STARTButtonPushed, true);
            app.STARTButton.Enable = 'off';
            app.STARTButton.Position = [703 167 100 22];
            app.STARTButton.Text = 'START';

            % Create CheckvideoforSparksLabel
            app.CheckvideoforSparksLabel = uilabel(app.MainProcessTab);
            app.CheckvideoforSparksLabel.Position = [547 167 130 22];
            app.CheckvideoforSparksLabel.Text = 'Check video for Sparks';

            % Create ElapsedTimeHHmmssmsLabel
            app.ElapsedTimeHHmmssmsLabel = uilabel(app.MainProcessTab);
            app.ElapsedTimeHHmmssmsLabel.HorizontalAlignment = 'right';
            app.ElapsedTimeHHmmssmsLabel.Position = [523 125 165 22];
            app.ElapsedTimeHHmmssmsLabel.Text = 'Elapsed Time (HH:mm:ss.ms)';

            % Create ElapsedTime
            app.ElapsedTime = uieditfield(app.MainProcessTab, 'text');
            app.ElapsedTime.Editable = 'off';
            app.ElapsedTime.Position = [703 125 100 22];

            % Create CLEAR
            app.CLEAR = uibutton(app.MainProcessTab, 'push');
            app.CLEAR.ButtonPushedFcn = createCallbackFcn(app, @CLEARButtonPushed, true);
            app.CLEAR.Position = [45 32 100 22];
            app.CLEAR.Text = 'CLEAR';

            % Create NextTab2
            app.NextTab2 = uibutton(app.MainProcessTab, 'push');
            app.NextTab2.ButtonPushedFcn = createCallbackFcn(app, @NextTab2ButtonPushed, true);
            app.NextTab2.Icon = 'pointers-icon-arrows-icon-right-arrow-icon-next-icon-logo-material-property-symbol-png-clip-art.png';
            app.NextTab2.Position = [816 45 35 22];
            app.NextTab2.Text = '';

            % Create NextTab2_1
            app.NextTab2_1 = uibutton(app.MainProcessTab, 'push');
            app.NextTab2_1.ButtonPushedFcn = createCallbackFcn(app, @NextTab2_1ButtonPushed, true);
            app.NextTab2_1.Icon = 'copy.jpg';
            app.NextTab2_1.Position = [768 45 35 22];
            app.NextTab2_1.Text = '';

            % Create SelectedBlackandWhiteThresholdEditFieldLabel
            app.SelectedBlackandWhiteThresholdEditFieldLabel = uilabel(app.MainProcessTab);
            app.SelectedBlackandWhiteThresholdEditFieldLabel.HorizontalAlignment = 'right';
            app.SelectedBlackandWhiteThresholdEditFieldLabel.Position = [23 195 200 22];
            app.SelectedBlackandWhiteThresholdEditFieldLabel.Text = 'Selected Black and White Threshold';

            % Create SelectedBW
            app.SelectedBW = uieditfield(app.MainProcessTab, 'numeric');
            app.SelectedBW.Limits = [0 1];
            app.SelectedBW.Editable = 'off';
            app.SelectedBW.Position = [235 195 40 22];
            app.SelectedBW.Value = 0.31;

            % Create SelectedvideoLabel
            app.SelectedvideoLabel = uilabel(app.MainProcessTab);
            app.SelectedvideoLabel.Position = [30 229 84 22];
            app.SelectedvideoLabel.Text = 'Selected video';

            % Create Image_2
            app.Image_2 = uiimage(app.MainProcessTab);
            app.Image_2.Position = [794 513 100 100];
            app.Image_2.ImageSource = 'logo.png';

            % Create SelectedsheddiameterinmmLabel
            app.SelectedsheddiameterinmmLabel = uilabel(app.MainProcessTab);
            app.SelectedsheddiameterinmmLabel.HorizontalAlignment = 'right';
            app.SelectedsheddiameterinmmLabel.Position = [23 158 168 22];
            app.SelectedsheddiameterinmmLabel.Text = 'Selected shed diameter in mm';

            % Create SelectedDiameter
            app.SelectedDiameter = uieditfield(app.MainProcessTab, 'numeric');
            app.SelectedDiameter.Limits = [0 Inf];
            app.SelectedDiameter.Editable = 'off';
            app.SelectedDiameter.Position = [235 158 40 22];

            % Create IncludeflashoverframeininsulatorsanalaysisLabel
            app.IncludeflashoverframeininsulatorsanalaysisLabel = uilabel(app.MainProcessTab);
            app.IncludeflashoverframeininsulatorsanalaysisLabel.HorizontalAlignment = 'right';
            app.IncludeflashoverframeininsulatorsanalaysisLabel.Position = [459 208 263 22];
            app.IncludeflashoverframeininsulatorsanalaysisLabel.Text = 'Include flashover frame in insulator''s analaysis?';

            % Create YesNo
            app.YesNo = uidropdown(app.MainProcessTab);
            app.YesNo.Items = {'Yes', 'No'};
            app.YesNo.Position = [732 208 63 22];
            app.YesNo.Value = 'Yes';

            % Create SelectanameforthenewcroppedvideoEditFieldLabel
            app.SelectanameforthenewcroppedvideoEditFieldLabel = uilabel(app.MainProcessTab);
            app.SelectanameforthenewcroppedvideoEditFieldLabel.HorizontalAlignment = 'right';
            app.SelectanameforthenewcroppedvideoEditFieldLabel.Position = [23 112 226 22];
            app.SelectanameforthenewcroppedvideoEditFieldLabel.Text = 'Select a name for the new cropped video';

            % Create NewVideoName
            app.NewVideoName = uieditfield(app.MainProcessTab, 'text');
            app.NewVideoName.Position = [264 112 167 22];
            app.NewVideoName.Value = 'CroppedVideo01';

            % Create PostProcessTab
            app.PostProcessTab = uitab(app.TabGroup);
            app.PostProcessTab.Title = 'Post-Process';

            % Create AxesTop
            app.AxesTop = uiaxes(app.PostProcessTab);
            title(app.AxesTop, 'Top Trunk All Frames')
            xlabel(app.AxesTop, 'Frames')
            ylabel(app.AxesTop, 'Pixels')
            app.AxesTop.PlotBoxAspectRatio = [2.34615384615385 1 1];
            app.AxesTop.Position = [439 412 356 185];

            % Create AxesCentral
            app.AxesCentral = uiaxes(app.PostProcessTab);
            title(app.AxesCentral, 'Central Trunk All Frames')
            xlabel(app.AxesCentral, 'Frames')
            ylabel(app.AxesCentral, 'Pixels')
            app.AxesCentral.PlotBoxAspectRatio = [2.34615384615385 1 1];
            app.AxesCentral.Position = [439 216 356 185];

            % Create AxesBottom
            app.AxesBottom = uiaxes(app.PostProcessTab);
            title(app.AxesBottom, 'Bottom Trunk All Frames')
            xlabel(app.AxesBottom, 'Frames')
            ylabel(app.AxesBottom, 'Pixels')
            app.AxesBottom.PlotBoxAspectRatio = [2.34615384615385 1 1];
            app.AxesBottom.Position = [439 14 356 185];

            % Create AnalyseFrame
            app.AnalyseFrame = uiaxes(app.PostProcessTab);
            app.AnalyseFrame.PlotBoxAspectRatio = [1.19047619047619 1 1];
            app.AnalyseFrame.XTick = [];
            app.AnalyseFrame.YTick = [];
            app.AnalyseFrame.Position = [30 304 384 293];

            % Create ChooseFrameforanalysisSpinnerLabel
            app.ChooseFrameforanalysisSpinnerLabel = uilabel(app.PostProcessTab);
            app.ChooseFrameforanalysisSpinnerLabel.HorizontalAlignment = 'right';
            app.ChooseFrameforanalysisSpinnerLabel.Position = [42 252 85 28];
            app.ChooseFrameforanalysisSpinnerLabel.Text = {'Choose Frame'; 'for analysis'};

            % Create Spinner
            app.Spinner = uispinner(app.PostProcessTab);
            app.Spinner.Limits = [0 Inf];
            app.Spinner.ValueDisplayFormat = '%.0f';
            app.Spinner.ValueChangedFcn = createCallbackFcn(app, @SpinnerValueChanged, true);
            app.Spinner.Enable = 'off';
            app.Spinner.Position = [142 258 100 22];

            % Create NextTab3_1
            app.NextTab3_1 = uibutton(app.PostProcessTab, 'push');
            app.NextTab3_1.ButtonPushedFcn = createCallbackFcn(app, @NextTab3_1ButtonPushed, true);
            app.NextTab3_1.Icon = 'copy.jpg';
            app.NextTab3_1.Position = [31 45 35 22];
            app.NextTab3_1.Text = '';

            % Create Image_3
            app.Image_3 = uiimage(app.PostProcessTab);
            app.Image_3.Position = [794 513 100 100];
            app.Image_3.ImageSource = 'logo.png';

            % Create TotalaxiallelngthofsparksinmmLabel
            app.TotalaxiallelngthofsparksinmmLabel = uilabel(app.PostProcessTab);
            app.TotalaxiallelngthofsparksinmmLabel.HorizontalAlignment = 'right';
            app.TotalaxiallelngthofsparksinmmLabel.Position = [42 131 186 22];
            app.TotalaxiallelngthofsparksinmmLabel.Text = 'Total axial lelngth of sparks in mm';

            % Create sparklengthmm
            app.sparklengthmm = uieditfield(app.PostProcessTab, 'numeric');
            app.sparklengthmm.Editable = 'off';
            app.sparklengthmm.Position = [252 130 75 22];

            % Create AnalyseframewithSpark
            app.AnalyseframewithSpark = uibutton(app.PostProcessTab, 'push');
            app.AnalyseframewithSpark.ButtonPushedFcn = createCallbackFcn(app, @AnalyseframewithSparkPushed, true);
            app.AnalyseframewithSpark.Enable = 'off';
            app.AnalyseframewithSpark.Position = [42 197 152 22];
            app.AnalyseframewithSpark.Text = 'Analyse frame with Spark';

            % Create label3_1
            app.label3_1 = uilabel(app.PostProcessTab);
            app.label3_1.Position = [42 165 296 22];
            app.label3_1.Text = 'The red box represends the longest continuous spark ';

            % Create TotalaxiallengthofsparksinpixelsEditFieldLabel
            app.TotalaxiallengthofsparksinpixelsEditFieldLabel = uilabel(app.PostProcessTab);
            app.TotalaxiallengthofsparksinpixelsEditFieldLabel.HorizontalAlignment = 'right';
            app.TotalaxiallengthofsparksinpixelsEditFieldLabel.Position = [42 95 195 22];
            app.TotalaxiallengthofsparksinpixelsEditFieldLabel.Text = 'Total axial length of sparks in pixels';

            % Create sparklengthpixels
            app.sparklengthpixels = uieditfield(app.PostProcessTab, 'numeric');
            app.sparklengthpixels.Editable = 'off';
            app.sparklengthpixels.Position = [252 95 75 22];

            % Show the figure after all components are created
            app.HV_Insulator_Tool.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = HV_InsulatorTool_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.HV_Insulator_Tool)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.HV_Insulator_Tool)
        end
    end
end