function myprogress
    progressf = uifigure;
    proggresd = uiprogressdlg(progressf,'Title','Computing in progress','Message','Please wait...','Indeterminate','on');
    
    % close the dialog box
close(proggresd);
close(progressf);

end